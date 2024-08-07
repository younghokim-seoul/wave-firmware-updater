import 'dart:async';

import 'package:easy_isolate_helper/easy_isolate_helper.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_event.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@lazySingleton
class ConnectionViewModel with IsolateHelperMixin {
  ConnectionViewModel(this._wifiRepository);

  final WifiRepository _wifiRepository;


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
  }

  Future<void> startScan() async {
    realLog.info('Start Scan');
    connectionUiState.val = const NearByDevicesRequested();
    await _resetAndSubscribeToScan();
    try {
      await subscribeToMessages();
      await _wifiRepository.startScan();
    } catch (e, t) {
      realLog.error('[startScan Error] $e');
      connectionUiState.val = const NearByDeviceNotFound();
    }
  }

  Future<void> _resetAndSubscribeToScan() async {
    await disposeScan();
    await stopScan();
  }

  Future<void> stopScan() async {
    realLog.info('StopScan');
    await _wifiRepository.stopScan();
  }

  Future<void> connectDevice(ScanUiModel item, ConnectionStatus status) async {
    if (connectionUiState.val is NearByDevicesUpdate) {
      try {
        subscribeToConnection();

        String ssid = item.model.macAddress;
        realLog.info('Connecting to $ssid $status');
        if (status == ConnectionStatus.connecting) {
          realLog.info('Already Status Connecting to $ssid return');
          return;
        }

        if (status == ConnectionStatus.disconnected) {
          await _wifiRepository.connect(item.model);
        } else {
          await _wifiRepository.disconnect();
        }
      } catch (e, t) {
        realLog.error('Device connection failed $e');
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
    _wifiRepository.setRetryConnectMode(true);
    _connectionSubscription ??= _wifiRepository.statuses.listen((response) {
      _handleConnectionResponse(response.item1, response.item2);
    });
  }

  void _subscribeToWifiMessages() {
    _scanSubscription ??= _wifiRepository.scanMessage.listen((response) => _handleScanResponse(response));
  }

  void _handleConnectionResponse(String macAddress, ConnectionStatus state) {
    realLog.info('[_handleConnectionResponse] Connection State: [ $macAddress ] $state ');

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
      return origin.status == ConnectionStatus.connected || origin.status == ConnectionStatus.connecting ? true : false;
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

    if (response.isNullOrEmpty) {
      realLog.error("scan empty!!!");
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
