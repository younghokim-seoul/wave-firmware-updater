import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:win32/win32.dart';

typedef WifiSearchEventCallback = void Function(String ssid, String rssi);

class WifiScanner {
  Future<List<ScanDevice>> performNetworkScan() async {
    return await compute(scanNetworks, null);
  }

  List<ScanDevice> scanNetworks(_) {
    final List<ScanDevice> results = [];

    final hr = CoInitializeEx(nullptr, COINIT.COINIT_APARTMENTTHREADED);
    if (FAILED(hr)) {
      throw Exception('Failed to initialize COM library. Error code: $hr');
    }

    // WLAN 클라이언트 핸들 열기
    final hClientHandle = calloc<HANDLE>();
    final pdwNegotiatedVersion = calloc<DWORD>();
    if (hClientHandle == nullptr || pdwNegotiatedVersion == nullptr) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, null, null, null);
      CoUninitialize();
      throw Exception('Memory allocation failed.');
    }

    final dwResult = WlanOpenHandle(2, nullptr, pdwNegotiatedVersion, hClientHandle);
    if (dwResult != ERROR_SUCCESS) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, null, null, null);
      CoUninitialize();
      throw Exception('WlanOpenHandle failed with error: $dwResult');
    }

    // 무선 LAN 인터페이스 열거
    final ppInterfaceList = calloc<Pointer<WLAN_INTERFACE_INFO_LIST>>();
    if (ppInterfaceList == nullptr) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, null, null, null);
      CoUninitialize();
      throw Exception('Memory allocation failed.');
    }

    final dwResultEnum = WlanEnumInterfaces(hClientHandle.value, nullptr, ppInterfaceList);
    if (dwResultEnum != ERROR_SUCCESS) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, null, null);
      CoUninitialize();
      throw Exception('WlanEnumInterfaces failed with error: $dwResultEnum');
    }

    final interfaceList = ppInterfaceList.value.ref;
    if (interfaceList.dwNumberOfItems == 0) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, null, null);
      CoUninitialize();
      throw Exception('No WLAN interfaces found.');
    }

    // 첫 번째 WLAN 인터페이스 선택 및 스캔 수행
    final interfaceInfo = interfaceList.InterfaceInfo[0];
    final pInterfaceGuid = calloc<GUID>();
    if (pInterfaceGuid == nullptr) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, null, null);
      CoUninitialize();
      throw Exception('Memory allocation failed.');
    }

    pInterfaceGuid.ref.setGUIDFromComponents(
      interfaceInfo.InterfaceGuid.Data1,
      interfaceInfo.InterfaceGuid.Data2,
      interfaceInfo.InterfaceGuid.Data3,
      interfaceInfo.InterfaceGuid.Data4,
    );

    final dwResultScan = WlanScan(hClientHandle.value, pInterfaceGuid, nullptr, nullptr, nullptr);
    if (dwResultScan != ERROR_SUCCESS) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, pInterfaceGuid, null);
      CoUninitialize();
      throw Exception('WlanScan failed with error: $dwResultScan');
    }

    // 가용 네트워크 목록 가져오기
    final ppAvailableNetworkList = calloc<Pointer<WLAN_AVAILABLE_NETWORK_LIST>>();
    if (ppAvailableNetworkList == nullptr) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, pInterfaceGuid, null);
      CoUninitialize();
      throw Exception('Memory allocation failed.');
    }

    final dwResultGetNetworkList = WlanGetAvailableNetworkList(
      hClientHandle.value,
      pInterfaceGuid,
      0,
      nullptr,
      ppAvailableNetworkList,
    );
    if (dwResultGetNetworkList != ERROR_SUCCESS) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, pInterfaceGuid, ppAvailableNetworkList);
      CoUninitialize();
      throw Exception('WlanGetAvailableNetworkList failed with error: $dwResultGetNetworkList');
    }

    final availableNetworkList = ppAvailableNetworkList.value.ref;
    final numberOfItems = availableNetworkList.dwNumberOfItems;

    for (int i = 0; i < numberOfItems; i++) {
      // 가변 길이 배열 접근
      final networkAddress = ppAvailableNetworkList.value.address +
          sizeOf<WLAN_AVAILABLE_NETWORK_LIST>() +
          i * sizeOf<WLAN_AVAILABLE_NETWORK>();
      final network = Pointer<WLAN_AVAILABLE_NETWORK>.fromAddress(networkAddress).ref;

      // SSID를 출력
      final ssid = network.dot11Ssid.toRawString();
      final rssi = network.wlanSignalQuality;

      if (ssid.contains("WAVE")) results.add(ScanDevice(deviceName: ssid, macAddress: ssid, rssi: rssi.toString()));
    }

    _removeDuplicateSsid(results);

    // 할당된 메모리 해제 및 COM 비활성화
    _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, pInterfaceGuid, ppAvailableNetworkList);
    CoUninitialize();

    return results;
  }

  void _removeDuplicateSsid(List<ScanDevice> results) {
    var distinctResults =
        groupBy(results, (ScanDevice device) => device.deviceName).values.map((devices) => devices.first).toList();

    results.clear();
    results.addAll(distinctResults);
  }

  void _freeResources(
    Pointer<HANDLE>? hClientHandle,
    Pointer<DWORD>? pdwNegotiatedVersion,
    Pointer<Pointer<WLAN_INTERFACE_INFO_LIST>>? ppInterfaceList,
    Pointer<GUID>? pInterfaceGuid,
    Pointer<Pointer<WLAN_AVAILABLE_NETWORK_LIST>>? ppAvailableNetworkList,
  ) {
    if (ppAvailableNetworkList != null) {
      WlanFreeMemory(ppAvailableNetworkList.value);
      free(ppAvailableNetworkList);
    }
    if (ppInterfaceList != null) {
      WlanFreeMemory(ppInterfaceList.value);
      free(ppInterfaceList);
    }
    if (pInterfaceGuid != null) {
      free(pInterfaceGuid);
    }
    if (hClientHandle != null) {
      WlanCloseHandle(hClientHandle.value, nullptr);
      free(hClientHandle);
    }
    if (pdwNegotiatedVersion != null) {
      free(pdwNegotiatedVersion);
    }
  }
}

extension on DOT11_SSID {
  String toRawString() {
    return String.fromCharCodes(Uint8List.fromList(
      List<int>.generate(uSSIDLength, (index) => ucSSID[index]),
    ));
  }
}
