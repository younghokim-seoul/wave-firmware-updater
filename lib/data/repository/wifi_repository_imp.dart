import 'dart:async';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:tcp_client/tcp_client.dart';
import 'package:wave_desktop_installer/data/exception/connection_exception.dart';
import 'package:wave_desktop_installer/data/wifi_scanner.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';


@LazySingleton(as: WifiRepository)
class WifiRepositoryImp extends WifiRepository {
  WifiRepositoryImp(this._clientRepository, this._wifiScanWindows)
      : _period = const Duration(seconds: 5),
        _messageController = StreamController.broadcast(),
        _wifiScanController = StreamController.broadcast();

  final TcpClientRepository _clientRepository;

  final WifiScanner _wifiScanWindows;

  final Duration _period;

  StreamSubscription<int>? _subscription;
  StreamSubscription<int>? _autoScanSubscription;

  bool isScanning = false;

  final StreamController<WaveSensorResponse> _messageController;
  final StreamController<List<ScanDevice>> _wifiScanController;

  @override
  Future<void> connect(String address, int port) async {
    Log.d("Connecting to $address:$port...");
    try {

      // if (_clientRepository.isConnected) {
      //   Log.d("Already connected to $address:$port. so block....");
      //   return;
      // }
      final response = await _clientRepository.connect();

      Log.d("Connected to $address:$port. Response: $response");

      if (response) {
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
            } catch (e) {
              await disconnect();
            }
          },
          cancelOnError: true,
        );
      }
    } catch (e, t) {
      throw ConnectionException(e, t);
    }
  }

  @override
  Future<void> disconnect() async {
    Log.d("Disconnecting...");
    await _clientRepository.disconnect();
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> send(Uint8List event) async {
    try {
      final response = await _clientRepository.rawPacket(event);
      Log.d('response: $response');
      _messageController.add(response);
    } catch (e) {
      Log.e("Error sending event: $e");
      rethrow;
    }
  }

  Future<void> dispose() async {
    await disconnect();
  }

  @override
  Future<void> startScan() async {
    try {
      if(isScanning == true) return;
      isScanning = true;
      await Future.delayed(const Duration(milliseconds: 300));
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
  bool get isClosed => _clientRepository.isClosed;
}
