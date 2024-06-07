import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class ConnectionViewModel {
  ConnectionViewModel(this._wifiRepository, this._bluetoothRepository);

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bluetoothRepository;

  final connectionUiState = ArcSubject<ConnectionEvent>();

  StreamSubscription? _scanSubscription;

  ConnectionMode _connectionMode = ConnectionMode.wifi;

  Future<void> subscribeToMessages() async {
    _scanSubscription ??= _wifiRepository.scanMessage.listen((response) {
      final state = response
          .map((e) => ScanUiModel(
              connectionMode: _connectionMode,
              model: e,
              isExpanded: false,
              status: ConnectionStatus.disconnected))
          .toList();
      connectionUiState.val =
          NearByDevicesUpdate(data: ConnectionUiState(scanDevices: state));
    });
  }

  Future<void> dispose() async {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> startScan(ConnectionMode mode) async {
    connectionUiState.val = const NearByDevicesRequested();
    _connectionMode = mode;
    await _resetAndSubscribeToScan();
    try {
      if (mode == ConnectionMode.wifi) {
        await _wifiRepository.startScan();
      } else {}
    } catch (e, t) {
      Log.e('[startScan Error] $e');

      List<ScanUiModel> dummyScanUiModels = [
        const ScanUiModel(
            connectionMode: ConnectionMode.wifi,
            // 더미 데이터
            model: ScanDevice(
                deviceName: "mode1", macAddress: "macAddress", rssi: "rssi"),
            // 더미 데이터
            isExpanded: false,
            status: ConnectionStatus.disconnected),
        const ScanUiModel(
            connectionMode: ConnectionMode.wifi,
            // 더미 데이터
            model: ScanDevice(
                deviceName: "mode3",
                macAddress: "asdsadasd",
                rssi: "asdasdasd"),
            // 데이터
            isExpanded: false,
            status: ConnectionStatus.disconnected),
        const ScanUiModel(
            connectionMode: ConnectionMode.bluetooth,
            // 더미 데이터
            model: ScanDevice(
                deviceName: "mode4",
                macAddress: "asdsdgggggggg",
                rssi: "1231231231231"),
            // 더미 데이터
            isExpanded: false,
            status: ConnectionStatus.disconnected),
      ];
      connectionUiState.val = NearByDevicesUpdate(
          data: ConnectionUiState(scanDevices: dummyScanUiModels));
    }
  }

  Future<void> _resetAndSubscribeToScan() async {
    await dispose();
    await subscribeToMessages();
    await stopScan();
  }

  Future<void> stopScan() async {
    await _wifiRepository.stopScan();
  }

  Future<void> connectWifi(String address, int port) async {
    try {
      await _wifiRepository.connect(address, port);
    } catch (e, t) {
      Log.e("Wifi connection failed $e");
    }
  }

  void expandStateUpdate(ScanUiModel item, bool isExpanded) {
    if (connectionUiState.val is NearByDevicesUpdate) {
      NearByDevicesUpdate model = connectionUiState.val;

      final updateScanDevices = isExpanded
          ? model.data.scanDevices.map((e) {
              if (e == item) {
                return e.copyWith(isExpanded: true);
              } else {
                return e.copyWith(isExpanded: false);
              }
            }).toList()
          : model.data.scanDevices.map((e) {
              if (e == item) {
                return e.copyWith(isExpanded: false);
              } else {
                return e;
              }
            }).toList();

      connectionUiState.val = NearByDevicesUpdate(
          data: model.data.copyWith(scanDevices: updateScanDevices));

      // if (isExpanded) {
      //   int index = model.data.scanDevices.indexWhere((element) => element == item);
      //   List<ScanUiModel> mutableScanDevices = List.from(model.data.scanDevices);
      //   for (int i = 0; i < mutableScanDevices.length; i++) {
      //     if (i == index) {
      //       mutableScanDevices[i] = model.data.scanDevices[i].copyWith(isExpanded: true);
      //     } else {
      //       mutableScanDevices[i] = model.data.scanDevices[i].copyWith(isExpanded: false);
      //     }
      //   }
      //   connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
      // } else {
      //   int index = model.data.scanDevices.indexWhere((element) => element == item);
      //   List<ScanUiModel> mutableScanDevices = List.from(model.data.scanDevices);
      //   mutableScanDevices[index] = mutableScanDevices[index].copyWith(isExpanded: false);
      //
      //   connectionUiState.val = NearByDevicesUpdate(
      //       data: model.data.copyWith(scanDevices: mutableScanDevices));
      // }

    }
  }
}
