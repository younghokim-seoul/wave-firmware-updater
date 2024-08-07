import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:win32/win32.dart';

typedef WifiSearchEventCallback = void Function(String ssid, String rssi);

@lazySingleton
class SystemWifiUtils {
  Future<List<ScanDevice>> performNetworkScan() async {
    return await compute(scanNetworks, null);
  }

  Future<void> disconnect(String ssid) async {
    String disconnectCommand = 'netsh wlan disconnect';

    ProcessResult disconnectResult = await Process.run('cmd', ['/c', disconnectCommand]);
    if (disconnectResult.exitCode == 0) {
      Log.d('Disconnected from Wi-Fi successfully:');
    } else {
      Log.d('Failed to disconnect from Wi-Fi with exit code ${disconnectResult.exitCode}:');
    }
  }

  Future<bool> connect(String ssid) async {

    final isExistProfile = await isSsidInProfiles(ssid);

    if (!isExistProfile) {
      Log.d("::프로파일 없으므로 신규 등록");
      String filePath = 'wifi_profile.xml';
      await File(filePath).writeAsString(createProfileXml(ssid), encoding: utf8);

      String command = 'netsh wlan add profile filename="$filePath"';

      // Process.run을 사용하여 명령어 실행
      ProcessResult result = await Process.run('cmd', ['/c', command]);

      if (result.exitCode == 0) {
        Log.d('Profile added successfully:');
        Log.d(result.stdout);
        return await pairWifiProfile(ssid);
      } else {
        Log.d('Failed to add profile with exit code ${result.exitCode}:');
        Log.d(result.stderr);
        return false;
      }
    } else {
      realLog.info('::Already Wifi Profile Exist');
      if (await isDesiredSsidConnected(ssid) == true) {
        return true;
      }
      return await pairWifiProfile(ssid);
    }
  }

  Future<bool> isDesiredSsidConnected(String desiredSsid) async {
    ProcessResult result = await Process.run('cmd', ['/c', 'netsh wlan show interfaces']);

    List<String> lines = result.stdout.split('\n');

    for (String line in lines) {
      if (line.contains('SSID') && line.contains(desiredSsid)) {
        return true;
      }
    }
    return false;
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
    if (dwResult != WIN32_ERROR.ERROR_SUCCESS) {
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
    if (dwResultEnum != WIN32_ERROR.ERROR_SUCCESS) {
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
    if (dwResultScan != WIN32_ERROR.ERROR_SUCCESS) {
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
    if (dwResultGetNetworkList != WIN32_ERROR.ERROR_SUCCESS) {
      _freeResources(hClientHandle, pdwNegotiatedVersion, ppInterfaceList, pInterfaceGuid, ppAvailableNetworkList);
      CoUninitialize();
      throw Exception('WlanGetAvailableNetworkList failed with error: $dwResultGetNetworkList');
    }

    final availableNetworkList = ppAvailableNetworkList.value.ref;
    final numberOfItems = availableNetworkList.dwNumberOfItems;

    for (int i = 0; i < numberOfItems; i++) {
      // 가변 길이 배열 접근

      try {
        final networkAddress = ppAvailableNetworkList.value.address +
            sizeOf<WLAN_AVAILABLE_NETWORK_LIST>() +
            i * sizeOf<WLAN_AVAILABLE_NETWORK>();
        final networkPtr = Pointer<WLAN_AVAILABLE_NETWORK>.fromAddress(networkAddress);
        final network = networkPtr.ref;
        if (network.dot11Ssid.uSSIDLength == 13) {
          final ssid = network.dot11Ssid.toRawString();
          final rssi = network.wlanSignalQuality;

          if (ssid.contains('WAVE')) {
            results.add(ScanDevice(deviceName: ssid, macAddress: ssid, rssi: rssi.toString(), status: ConnectionStatus.disconnected));
          }
        }
      } catch (e) {
        Log.e('Wifi array Exception');
        continue;
      }
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

Future<bool> pairWifiProfile(String ssid) async {
  String connectCommand = 'netsh wlan connect name="$ssid"';
  ProcessResult connectResult = await Process.run('cmd', ['/c', connectCommand]);
  return connectResult.exitCode == 0;
}

Future<bool> isSsidInProfiles(String ssid) async {
  ProcessResult result = await Process.run('cmd', ['/c', 'netsh wlan show profiles']);

  // 명령어 실행 결과를 줄 단위로 분리
  List<String> lines = result.stdout.split('\n');

  // 각 줄을 확인하여 원하는 SSID가 있는지 검사
  for (String line in lines) {
    if (line.contains(ssid)) {
      return true;
    }
  }
  return false;
  // 모든 줄을 확인
}

String _asciiToHex(String asciiString) {
  return asciiString.codeUnits.map((char) => char.toRadixString(16).padLeft(2, '0')).join();
}

String createProfileXml(String ssid) {
  return '''<?xml version="1.0" encoding="Windows-1252"?>
      <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <name>$ssid</name>
        <SSIDConfig>
          <SSID>
            <hex>${_asciiToHex(ssid)}</hex>
            <name>$ssid</name>
          </SSID>
        </SSIDConfig>
        <connectionType>ESS</connectionType>
        <connectionMode>auto</connectionMode>
        <MSM>
          <security>
            <authEncryption>
              <authentication>WPA2PSK</authentication>
              <encryption>AES</encryption>
              <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
              <keyType>passPhrase</keyType>
              <protected>false</protected>
              <keyMaterial>wave1234</keyMaterial>
            </sharedKey>
          </security>
        </MSM>
        <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
            <enableRandomization>false</enableRandomization>
        </MacRandomization>
      </WLANProfile>''';
}
