import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:injectable/injectable.dart';
import 'package:tcp_client/tcp_client.dart';
import 'package:tuple/tuple.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/data/exception/connection_exception.dart';
import 'package:wave_desktop_installer/data/system_wifi.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/main.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImp extends WifiRepository {
  WifiRepositoryImp(this._clientRepository, this._wifiScanWindows)
      : _period = const Duration(seconds: 3),
        _messageController = StreamController.broadcast(),
        _wifiScanController = StreamController.broadcast(),
        _controller = StreamController.broadcast() {
    subscribeToConnection();
  }

  final TcpClientRepository _clientRepository;

  final SystemWifiUtils _wifiScanWindows;

  final Duration _period;

  ScanDevice? _currentDevice;
  StreamSubscription<int>? _subscription;
  StreamSubscription<int>? _autoScanSubscription;

  bool isScanning = false;
  bool isForcedDisconnect = false;
  bool isRetryConnect = false;


  final StreamController<WaveSensorResponse> _messageController;
  final StreamController<List<ScanDevice>> _wifiScanController;
  final StreamController<Tuple2<String, ConnectionStatus>> _controller;

  int retryConnectCount = 0;
  int attemptCount = 0;
  int timeoutCount = 5;

  _resetRetryCount() {
    attemptCount = 0;
    retryConnectCount = 0;
  }

  Future<void> _beforeCheck(ScanDevice device) async {
    if (_currentDevice != null) {
      if (_currentDevice?.macAddress != device.macAddress) {
        realLog.info('new Wave is connected, disconnect old Wave... ${_currentDevice?.macAddress}');
        disconnect();
        await _wifiScanWindows.disconnect(device.macAddress);
      }
    }
  }

  final _requestQueue = Queue<Future<void> Function()>();
  bool _isProcessingQueue = false;

  _updateStatus(ScanDevice device, ConnectionStatus status){
    _controller.add(Tuple2(device.macAddress, status));
    _putDeviceAddress(device.copyWith(status: status));
  }

  @override
  Future<void> connect(ScanDevice device,{bool isReconnection = false}) async {
    realLog.info('Connecting to Wifi... $device');
    try {
      await _beforeCheck(device);

      _currentDevice = device;
      _updateStatus(device, ConnectionStatus.connecting);

      _requestQueue.add(() async {
        bool isSystemConnect = await _wifiScanWindows.connect(device.macAddress);

        realLog.info('System Wifi Connect: $isSystemConnect');

        if (isSystemConnect == false) {
          _updateStatus(device, ConnectionStatus.disconnected);
          return;
        }

        final serverIp = await retryAction(() => TcpClientRepository.discover(Const.waveIp), 3);

        Log.d('serverIp... $serverIp');

        try {
          await send(WelcomeDataRequest().getRawBytes(), timeout: const Duration(seconds: 1));
        } catch (e) {
          realLog.error('Wave [Welcome] Packet No Response');
        }
        try {
          await Future.delayed(const Duration(milliseconds: 200));
          await send(VersionDataRequest().getRawBytes(), timeout: const Duration(seconds: 1));
          _updateStatus(device, ConnectionStatus.connected);
        } catch (e) {
          realLog.error('Wave [GET SW VER] Packet No Response');
        }

        await cancelPing();

        _subscription = Stream<int>.periodic(
          _period,
          (_) => _,
        ).listen(
          (_) async {
            if (_subscription == null) {
              return;
            }
            try {
              await send(PingDataRequest().getRawBytes(), timeout: const Duration(seconds: 1));
              _resetRetryCount();
              _updateStatus(device, ConnectionStatus.connected);
            } catch (e) {
              Log.d('[timeOut] : lAttempts = $attemptCount, maxCount = $timeoutCount');

              final isSystemWifiConnect = await _wifiScanWindows.isDesiredSsidConnected(device.macAddress);

              if(isSystemWifiConnect == false){
                _updateStatus(device, ConnectionStatus.disconnected);
                await disconnect();
                _resetRetryCount();
                return;
              }
              if (attemptCount++ >= timeoutCount) {
                Log.e('Wave [PING] Packet 5 Try No Response ');
                realLog.error('Wave [PING] Packet 5 Try No Response');
                _updateStatus(device, ConnectionStatus.disconnected);
                await disconnect();
                attemptCount = 0;
                Log.e('Wave RETRY connectionCount ... $retryConnectCount' + " isRetryConnectMode: $isRetryConnect");
                realLog.error('Wave RETRY connectionCount ... $retryConnectCount' + " isRetryConnectMode: $isRetryConnect");
                if (retryConnectCount++ < 1 && isRetryConnect) {
                  realLog.info('Wave reConnection... ${device.macAddress}');
                  connect(device,isReconnection: true);
                }

                Log.d('reset 카운트 초기화 여부.. $isReconnection');
                if(isReconnection){
                  _resetRetryCount();
                }

              }
            }
          },
        );
      });

      if (!_isProcessingQueue) {
        unawaited(_processQueue());
      }
    } catch (e, t) {
      realLog.error('ConnectionException>>>>>>>>>>>>> $e');
      _controller.add(Tuple2(device.macAddress, ConnectionStatus.disconnected));
      _removeDeviceAddress();
      throw ConnectionException(e, t);
    }
  }

  Future<void> _processQueue() async {
    _isProcessingQueue = true;

    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      realLog.info('execute requestQueue: ${request.toString()}');
      await request();
    }

    _isProcessingQueue = false;
  }

  @override
  Future<WaveSensorResponse> send(Uint8List event, {bool isAutoConnect = false, Duration? timeout}) async {
    try {
      final response = await _clientRepository.rawPacket(event, timeout: timeout);
      realLog.info('[send] response: $response');
      _messageController.add(response);
      return response;
    } catch (e) {
      if(e is TcpClientException){
        realLog.error('Error sending packet: ${e.cause}');
      }else{
        realLog.error('Error sending packet: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> disconnect([String ssid = '']) async {
    realLog.info('Disconnecting... $_currentDevice');
    if (_currentDevice == null) {
      return;
    }
    await cancelPing();
    _controller.add(Tuple2(_currentDevice!.macAddress, ConnectionStatus.disconnected));
    await _clientRepository.disconnect();
    _removeDeviceAddress();
  }


  _removeDeviceAddress() {
    _currentDevice = null;
  }

  _putDeviceAddress(ScanDevice device) {
    _currentDevice = device;
  }

  Future<void> dispose() async {
    await disconnect();
    _removeDeviceAddress();
  }

  @override
  Future<void> startScan() async {
    try {
      if (isScanning == true) {
        realLog.info('Already scanning wifi');
        return;
      }

      isScanning = true;

      final cacheSSID = _currentDevice;
      final response = await _wifiScanWindows.performNetworkScan();
      final scanResult = response.toList();

      if (cacheSSID != null) {
        scanResult.removeWhere((device) => device.macAddress == cacheSSID.macAddress);
        scanResult.insert(0, cacheSSID);
      }
      _wifiScanController.add(scanResult);

      isScanning = false;
    } catch (e) {
      realLog.error('Error scanning wifi: $e');
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
  Stream<Tuple2<String, ConnectionStatus>> get statuses => _controller.stream.distinct();

  @override
  bool get isClosed => _clientRepository.isClosed;

  @override
  String? get getAddressFromDevice => _currentDevice?.macAddress;

  @override
  void subscribeToConnection() {
    _clientRepository.onClose((fn) async {
      realLog.error('[TCP Disconnect] Wave TCP CLOSE');
      attemptCount = 0;
      disconnect();
    });
  }

  Future<bool> retryAction(FutureOr<String?> Function() action, retryCount) async {
    int lAttempts = 1;
    String? result;
    await Future.doWhile(() async {
      try {
        result = await action();
        if (result != null || lAttempts >= retryCount) {
          Log.d('Connect Success Exiting loop: lAttempts = $lAttempts, retryCount = $retryCount');
          return false;
        }
      } catch (e) {
        if (lAttempts++ >= retryCount) {
          Log.e('Rethrowing exception: lAttempts = $lAttempts, retryCount = $retryCount');
          rethrow;
        }
      }
      Log.d('[ReConnection loop: lAttempts = $lAttempts, retryCount = $retryCount');
      return result == null && lAttempts++ <= retryCount;
    });
    return result != null;
  }

  @override
  Future<void> cancelPing() async {
    Log.d("cancelPing>>>>>>>>");
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void setRetryConnectMode(bool isRetryConnect) {
    Log.d("setRetryConnectMode... $isRetryConnect");
    this.isRetryConnect = isRetryConnect;
  }
}
