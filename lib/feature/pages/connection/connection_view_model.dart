import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
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
    _scanSubscription ??= _wifiRepository.scanMessage.listen(
      (response) {
        final address = _wifiRepository.getAddressFromDevice;

        final state = response
            .map(
              (e) => ScanUiModel(
                connectionMode: _connectionMode,
                model: e,
                isExpanded: e.macAddress == address ? true : false,
                status: e.macAddress == address ? ConnectionStatus.connected : ConnectionStatus.disconnected,
              ),
            )
            .toList();

        int connectedIndex = state.indexWhere((item) => item.status == ConnectionStatus.connected);

        if (connectedIndex != -1) {
          ScanUiModel connectedItem = state.removeAt(connectedIndex);
          state.insert(0, connectedItem);
        }

        connectionUiState.val = NearByDevicesUpdate(data: ConnectionUiState(scanDevices: state));
      },
    );
  }

  Future<void> dispose() async {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }



  Future<void> startScan(ConnectionMode mode) async {
    Log.i('Start Scan $mode');
    connectionUiState.val = const NearByDevicesRequested();
    await Future.delayed(const Duration(milliseconds: 300));
    _connectionMode = mode;
    await _resetAndSubscribeToScan();
    try {
      if (mode == ConnectionMode.wifi) {
        await _wifiRepository.startScan();
      } else {}
    } catch (e, t) {
      Log.e('[startScan Error] $e');
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

  Future<void> connectWifi(ScanUiModel item, ConnectionStatus status) async {
    if (connectionUiState.val is NearByDevicesUpdate) {
      NearByDevicesUpdate model = connectionUiState.val;

      int index = model.data.scanDevices.indexWhere((element) => element == item);
      List<ScanUiModel> mutableScanDevices = List.from(model.data.scanDevices);

      try {
        String ssid = item.model.macAddress;

        Log.d('Connecting to $ssid');

        if (status == ConnectionStatus.disconnected) {
          mutableScanDevices[index] = mutableScanDevices[index].copyWith(status: ConnectionStatus.connecting);
          connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
          final response = await _wifiRepository.connect(item.model.macAddress);
          mutableScanDevices[index] = mutableScanDevices[index]
              .copyWith(status: response ? ConnectionStatus.connected : ConnectionStatus.disconnected);
          connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
        } else {
          await _wifiRepository.disconnect();
          mutableScanDevices[index] = mutableScanDevices[index].copyWith(status: ConnectionStatus.disconnected);
          connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
        }
      } catch (e, t) {
        Log.e("Wifi connection failed $e");
        mutableScanDevices[index] = mutableScanDevices[index].copyWith(status: ConnectionStatus.disconnected);
        connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
      }
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

      connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: updateScanDevices));
    }
  }

}
