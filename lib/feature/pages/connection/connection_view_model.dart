import 'dart:async';

import 'package:easy_isolate_helper/easy_isolate_helper.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@lazySingleton
class ConnectionViewModel with IsolateHelperMixin {
  ConnectionViewModel(this._wifiRepository, this._bluetoothRepository);

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bluetoothRepository;

  final connectionUiState = ArcSubject<ConnectionEvent>();

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;

  final ConnectionMode _connectionMode = ConnectionMode.wifi;

  Future<void> subscribeToConnection() async {
    _subscribeToWifiConnectionStatus();
  }

  Future<void> subscribeToMessages() async {
    _subscribeToWifiMessages();
  }

  void disposeAll() {
    stopScan();
    disposeScan();
    disposeConnection();
  }

  Future<void> disposeScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> disposeConnection() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    Log.d(":::커넥션 스트림 제거");
  }

  Future<void> startScan() async {
    Log.i('Start Scan');
    connectionUiState.val = const NearByDevicesRequested();
    await _resetAndSubscribeToScan();
    try {
      await subscribeToMessages();
      await _wifiRepository.startScan();
    } catch (e, t) {
      Log.e('[startScan Error] $e');
    }
  }

  Future<void> _resetAndSubscribeToScan() async {
    await disposeScan();
    await stopScan();
  }

  Future<void> stopScan() async {
    await _wifiRepository.stopScan();
  }

  Future<void> connectDevice(ScanUiModel item, ConnectionStatus status) async {
    if (connectionUiState.val is NearByDevicesUpdate) {
      try {
        subscribeToConnection();

        String ssid = item.model.macAddress;
        Log.d('Connecting to $ssid ' + status.toString());
        if (status == ConnectionStatus.connecting) {
          Log.d('Connecting to $ssid return');
          return;
        }

        if (status == ConnectionStatus.disconnected) {
          await _wifiRepository.connect(item.model);
        } else {
          await _wifiRepository.disconnect();
        }
      } catch (e, t) {
        Log.e('Device connection failed $e');
        await _wifiRepository.disconnect();
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

  void _subscribeToWifiConnectionStatus() {
    _connectionSubscription ??= _wifiRepository.statuses.listen((response) {
      _handleConnectionResponse(response.item1, response.item2);
    });
  }

  void _subscribeToWifiMessages() {
    _scanSubscription ??= _wifiRepository.scanMessage.listen((response) => _handleScanResponse(response));
  }

  void _handleConnectionResponse(String macAddress, ConnectionStatus state) {
    Log.d('[_handleConnectionResponse] Connection State: [ $macAddress ] $state ');

    if (connectionUiState.val is NearByDevicesUpdate) {
      NearByDevicesUpdate model = connectionUiState.val;

      final updateScanDevices = model.data.scanDevices.map((e) {
        if (e.model.macAddress == macAddress) {
          return e.copyWith(status: state, isExpanded: state == ConnectionStatus.disconnected ? false : true);
        } else {
          return e;
        }
      }).toList();

      connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: updateScanDevices));
    }
  }

  bool _isExpanded({required ScanDevice origin, required String? cacheSSID}) {
    if (origin.macAddress == cacheSSID) {
      return origin.status == ConnectionStatus.connected ? true : false;
    }
    return false;
  }

  ConnectionStatus _handleCurrentStatus({required ScanDevice origin, required String? cacheSSID}) {
    if (origin.macAddress == cacheSSID) {
      return origin.status;
    }
    return ConnectionStatus.disconnected;
  }

  void _handleScanResponse(List<ScanDevice> response) {

    final connectDevice = _wifiRepository.getAddressFromDevice;

    Log.d("현재 연결된 장치?? $connectDevice");

    if (response.isNullOrEmpty) {
      connectionUiState.val = const NearByDeviceNotFound();
      return;
    }

    final state = response
        .map(
          (e) => ScanUiModel(
            connectionMode: _connectionMode,
            model: e,
            isExpanded: _isExpanded(origin: e, cacheSSID: connectDevice),
            status: _handleCurrentStatus(origin: e, cacheSSID: connectDevice),
          ),
        )
        .toList();

    int connectedIndex = state.indexWhere((item) => item.status == ConnectionStatus.connected);

    if (connectedIndex != -1) {
      ScanUiModel connectedItem = state.removeAt(connectedIndex);
      state.insert(0, connectedItem);
    }

    connectionUiState.val = NearByDevicesUpdate(data: ConnectionUiState(scanDevices: state));
  }
}
