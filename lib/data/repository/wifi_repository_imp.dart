import 'dart:async';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:tcp_client/tcp_client.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/data/exception/connection_exception.dart';
import 'package:wave_desktop_installer/data/wifi_scanner.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImp extends WifiRepository {
  WifiRepositoryImp(this._clientRepository, this._wifiScanWindows)
      : _period = const Duration(seconds: 5),
        _messageController = StreamController.broadcast(),
        _wifiScanController = StreamController.broadcast(),
        _controller = StreamController.broadcast(),
        _deviceMap = {};

  final TcpClientRepository _clientRepository;

  final WifiScanner _wifiScanWindows;

  final Duration _period;

  final Map _deviceMap;

  StreamSubscription<int>? _subscription;
  StreamSubscription<int>? _autoScanSubscription;

  bool isScanning = false;

  final StreamController<WaveSensorResponse> _messageController;
  final StreamController<List<ScanDevice>> _wifiScanController;
  final StreamController<ConnectionStatus> _controller;

  int attemptCount = 0;

  @override
  Future<bool> connect(String ssid) async {
    Log.d("Connecting to Wifi...");
    try {
      _controller.add(ConnectionStatus.connecting);
      final response = await _clientRepository.connect();

      Log.d("Connected to Wave Response: $response");

      if (response) {
        _removeDeviceAddress();
        _deviceMap[ssid] = ConnectionMode.wifi;
        await send(WelcomeDataRequest().getRawBytes());
        _subscription = Stream<int>.periodic(
          _period,
          (_) => _,
        ).listen(
          (_) async {
            if (_subscription == null) {
              return;
            }
            try {
              await send(PingDataRequest().getRawBytes());
              attemptCount = 0;
              _controller.add(ConnectionStatus.connected);
            } catch (e) {
              if (attemptCount == 2) {
                await disconnect();
                attemptCount = 0;
              }
              attemptCount++;
            }
          },
          cancelOnError: true,
        );
      }
      return response;
    } catch (e, t) {
      _controller.add(ConnectionStatus.disconnected);
      throw ConnectionException(e, t);
    }
  }

  @override
  Future<void> send(Uint8List event, {bool isAutoConnect = false}) async {
    try {
      final response = await _clientRepository.rawPacket(event);
      Log.d('response: $response');
      _messageController.add(response);
    } catch (e) {
      Log.e("Error sending event: $e");
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    Log.d("Disconnecting...");

    _controller.add(ConnectionStatus.disconnected);
    _removeDeviceAddress();
    await _clientRepository.disconnect();
    await _subscription?.cancel();
    _subscription = null;
  }

  _removeDeviceAddress() {
    _deviceMap.clear();
  }



  Future<void> dispose() async {
    Log.d("::::wifi repository dispose::::");
    await disconnect();
  }

  @override
  Future<void> startScan() async {
    try {
      if (isScanning == true){
        Log.d("Already scanning wifi");
        return;
      };
      isScanning = true;
      final response = await _wifiScanWindows.performNetworkScan();
      _wifiScanController.add(response);
      isScanning = false;
    } catch (e) {
      Log.e("Error scanning wifi: $e");
      isScanning = false;
      rethrow;
    }
  }

  @override
  Future<void> stopScan() async {
    await _autoScanSubscription?.cancel();
    _autoScanSubscription = null;
  }

  @override
  Stream<List<ScanDevice>> get scanMessage => _wifiScanController.stream;

  @override
  Stream<WaveSensorResponse> get responseMessage => _messageController.stream;

  @override
  Stream<ConnectionStatus> get statuses => _controller.stream.distinct();

  @override
  bool get isClosed => _clientRepository.isClosed;

  @override
  String? get getAddressFromDevice => _getAddressFromDevice();

  String? _getAddressFromDevice() {
    String? address;
    _deviceMap.forEach((key, value) {
      address = key;
    });
    return address;
  }

}
