import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
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
              connectionMode: _connectionMode, model: e, isExpanded: false, status: ConnectionStatus.disconnected))
          .toList();
      connectionUiState.val = NearByDevicesUpdate(data: ConnectionUiState(scanDevices: state));
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

  void expandStateUpdate(ScanUiModel item) {
    if (connectionUiState.val is NearByDevicesUpdate) {
      NearByDevicesUpdate model = connectionUiState.val;
      final state = model.data.scanDevices.map((e) {
        if (e.model == item.model) {
          return e = item;
        } else {
          return e.copyWith(isExpanded: false);
        }
      }).toList();

      if (!state.isNullOrEmpty) {
        connectionUiState.val = NearByDevicesUpdate(data: model.data.copyWith(scanDevices: state));
      }

    }
  }
}
