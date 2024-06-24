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
import 'package:win_ble/win_ble.dart';

@lazySingleton
class ConnectionViewModel {
  ConnectionViewModel(this._wifiRepository, this._bluetoothRepository);

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bluetoothRepository;

  final connectionUiState = ArcSubject<ConnectionEvent>();

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;

  ConnectionMode _connectionMode = ConnectionMode.wifi;

  Future<void> subscribeToConnection() async {
    if (_connectionMode == ConnectionMode.wifi) {
      _subscribeToWifiConnectionStatus();
    } else {
      _subscribeToBluetoothConnectionStatus();
    }
  }

  Future<void> subscribeToMessages() async {
    if (_connectionMode == ConnectionMode.wifi) {
      _subscribeToWifiMessages();
    } else {
      _subscribeToBluetoothMessages();
    }
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

  Future<void> startScan(ConnectionMode mode) async {
    Log.i('Start Bluetooth Scan $mode');
    connectionUiState.val = const NearByDevicesRequested();
    _connectionMode = mode;
    await _resetAndSubscribeToScan();
    try {
      await subscribeToMessages();
      if (mode == ConnectionMode.wifi) {
        await _wifiRepository.startScan();
      } else {
        await _bluetoothRepository.startScan();
      }
    } catch (e, t) {
      Log.e('[startScan Error] $e');
    }
  }

  Future<void> _resetAndSubscribeToScan() async {
    await disposeScan();
    await stopScan();
  }

  Future<void> stopScan() async {
    Log.i('Stop Bluetooth Scan');
    await _wifiRepository.stopScan();
    await _bluetoothRepository.stopScan();


  }

  Future<void> connectDevice(ScanUiModel item, ConnectionStatus status) async {
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

          final response = item.connectionMode == ConnectionMode.wifi
              ? await _wifiRepository.connect(item.model.macAddress)
              : await _bluetoothRepository.connect(item.model);

          subscribeToConnection();

          mutableScanDevices[index] = mutableScanDevices[index].copyWith(status: response ? ConnectionStatus.connected : ConnectionStatus.disconnected);
          connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
        } else {
          item.connectionMode == ConnectionMode.wifi
              ? await _wifiRepository.disconnect()
              : await _bluetoothRepository.disconnect();
          mutableScanDevices[index] = mutableScanDevices[index].copyWith(status: ConnectionStatus.disconnected);
          connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: mutableScanDevices));
        }

      } catch (e, t) {
        Log.e("Device connection failed $e");
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

  void _subscribeToWifiConnectionStatus() {
    // _connectionSubscription ??= _wifiRepository.statuses
    //     .where((_) => _connectionMode == ConnectionMode.wifi)
    //     .listen((response) => _handleConnectionResponse(response));
  }

  void _subscribeToBluetoothConnectionStatus() {
    _connectionSubscription ??= _bluetoothRepository.statuses
        .listen((response) => _handleConnectionResponse(response));
  }

  void _subscribeToWifiMessages() {
    _scanSubscription ??= _wifiRepository.scanMessage
        .listen((response) => _handleScanResponse(response));
  }

  void _subscribeToBluetoothMessages() {
    _scanSubscription ??= _bluetoothRepository.scanMessage
        .listen((response) => _handleScanResponse(response));
  }

  void _handleConnectionResponse(BleConnectState response) {
    Log.d('[_handleConnectionResponse] Connection State: [ ${response.state} ] ${response.address} ');



    if (connectionUiState.val is NearByDevicesUpdate) {
      NearByDevicesUpdate model = connectionUiState.val;

      final updateScanDevices = model.data.scanDevices.map((e) {
        if (e.model.macAddress == response.address) {
          return e.copyWith(status: response.state ? ConnectionStatus.connected : ConnectionStatus.disconnected);
        } else {
          return e;
        }
      }).toList();

      connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: updateScanDevices));
    }
  }

  void _handleScanResponse(List<ScanDevice> response) {
    final connectDevice = _connectionMode == ConnectionMode.bluetooth
        ? _bluetoothRepository.getAddressFromDevice
        : _wifiRepository.getAddressFromDevice;

    Log.d("response... $response");
    Log.d("connectDevice... $connectDevice");

    final state = response
        .map(
          (e) => ScanUiModel(
            connectionMode: _connectionMode,
            model: e,
            isExpanded: e.macAddress == connectDevice ? true : false,
            status: e.macAddress == connectDevice ? ConnectionStatus.connected : ConnectionStatus.disconnected,
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
