import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/feature/pages/connection/connection_state.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/rx/arc_subject.dart';

@injectable
class ConnectionViewModel {
  ConnectionViewModel(this._wifiRepository, this._bluetoothRepository);

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bluetoothRepository;


  final connectionUiState = ArcSubject<ConnectionUiState>();

  StreamSubscription? _scanSubscription;

  Future<void> subscribeToMessages() async {
    _scanSubscription ??= _wifiRepository.scanMessage.listen((response) {
      Log.d('Scan message: $response');
      connectionUiState.val = ConnectionUiState(scanDevices: response);
    });
  }

  Future<void> dispose() async {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<void> startScan(ConnectionMode mode) async {
    await dispose();
    await subscribeToMessages();
    await stopScan();
    try {
      if (mode == ConnectionMode.wifi) {
        await _wifiRepository.startScan();
      } else {}
    } catch (e, t) {
      Log.e('[startScan Error] $e');
    }
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
}
