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
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';

@LazySingleton(as: WifiRepository)
class WifiRepositoryImp extends WifiRepository {
  WifiRepositoryImp(this._clientRepository, this._wifiScanWindows)
      : _period = const Duration(seconds: 5),
        _messageController = StreamController.broadcast(),
        _wifiScanController = StreamController.broadcast(),
        _controller = StreamController.broadcast(),
        _deviceMap = LinkedHashMap() {
    subscribeToConnection();
  }

  final TcpClientRepository _clientRepository;

  final SystemWifiUtils _wifiScanWindows;

  final Duration _period;

  final LinkedHashMap<String, ScanDevice> _deviceMap;

  ScanDevice? _currentDevice;
  StreamSubscription<int>? _subscription;
  StreamSubscription<int>? _autoScanSubscription;

  bool isScanning = false;
  bool isForcedDisconnect = false;

  final StreamController<WaveSensorResponse> _messageController;
  final StreamController<List<ScanDevice>> _wifiScanController;
  final StreamController<Tuple2<String, ConnectionStatus>> _controller;

  int attemptCount = 0;

  @override
  Future<bool> connect(ScanDevice device) async {
    Log.d("Connecting to Wifi... " + device.toString());
    try {
      if (_currentDevice != null) {
        if (_currentDevice?.macAddress != device.macAddress) {
          Log.d("신규 장치 연결시도...");
          disconnect();
        }
      }

      _currentDevice = device;

      _putDeviceAddress(device.copyWith(status: ConnectionStatus.connecting));
      _controller.add(Tuple2(device.macAddress, ConnectionStatus.connecting));

      bool isSystemConnect = await _wifiScanWindows.connect(device.macAddress);

      Log.d('System Wifi Connect: $isSystemConnect');

      if (isSystemConnect == false) {
        _controller.add(Tuple2(device.macAddress, ConnectionStatus.disconnected));
        throw ConnectionException('System Wifi Connect Fail', StackTrace.current);
      }

      await Future.delayed(const Duration(seconds: 2));
      var serverIp = await TcpClientRepository.discover(Const.waveIp);

      Log.d('Server IP: $serverIp');

      try {
        await send(WelcomeDataRequest().getRawBytes(), timeout: const Duration(seconds: 1));
      } catch (e) {
        Log.e("Welcome 설정 실패");
      }

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await send(VersionDataRequest().getRawBytes());
        _controller.add(Tuple2(device.macAddress, ConnectionStatus.connected));
        _putDeviceAddress(device.copyWith(status: ConnectionStatus.connected));
      } catch (e) {
        Log.e("버전정보 설정 실패");
      }
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
            _controller.add(Tuple2(device.macAddress, ConnectionStatus.connected));
            _putDeviceAddress(device.copyWith(status: ConnectionStatus.connected));
          } catch (e) {
            if (attemptCount == 5) {
              Log.d('5회 이상 연결이 안될경우 연결 해제 시도');
              await disconnect();
              attemptCount = 0;
            }
            attemptCount++;
          }
        },
      );
      // }
      return serverIp != null;
    } catch (e, t) {
      Log.e("e... " + e.toString());
      _controller.add(Tuple2(device.macAddress, ConnectionStatus.disconnected));
      _removeDeviceAddress();
      throw ConnectionException(e, t);
    }
  }

  @override
  Future<WaveSensorResponse> send(Uint8List event, {bool isAutoConnect = false, Duration? timeout}) async {
    try {
      final response = await _clientRepository.rawPacket(event, timeout: timeout);
      Log.d('response: $response');
      _messageController.add(response);
      return response;
    } catch (e) {
      Log.e("Error sending event: $e");
      rethrow;
    }
  }

  @override
  Future<void> disconnect([String ssid = '']) async {
    Log.d("Disconnecting... TCP 연결 해제  시도 " + _currentDevice.toString());
    if (_currentDevice == null) {
      return;
    }
    _controller.add(Tuple2(_currentDevice!.macAddress, ConnectionStatus.disconnected));
    await _clientRepository.disconnect();
    await _subscription?.cancel();
    _removeDeviceAddress();
    _subscription = null;
    _currentDevice = null;
  }

  _removeDeviceAddress() {
    Log.d('_removeDeviceAddress!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    _currentDevice = null;
  }

  _putDeviceAddress(ScanDevice device) {
    _currentDevice = device;
  }

  Future<void> dispose() async {
    Log.d('디스포스!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    await disconnect();
    _removeDeviceAddress();
  }

  @override
  Future<void> startScan() async {
    try {
      if (isScanning == true) {
        Log.d('Already scanning wifi');
        return;
      }

      isScanning = true;

      // Log.d("asdsadasda " + _deviceMap.values.isNullOrEmpty.toString());
      final cacheSSID = _currentDevice;

      Log.d("cacheSSID: $cacheSSID");

      final response = await _wifiScanWindows.performNetworkScan();
      final scanResult = response.toList();

      if (cacheSSID != null) {
        scanResult.removeWhere((device) => device.macAddress == cacheSSID.macAddress);
        scanResult.insert(0, cacheSSID);
      }

      Log.d("검색결과......" + scanResult.toString());
      _wifiScanController.add(scanResult);

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
  Stream<Tuple2<String, ConnectionStatus>> get statuses => _controller.stream.distinct();

  @override
  bool get isClosed => _clientRepository.isClosed;

  @override
  String? get getAddressFromDevice => _currentDevice?.macAddress;

  @override
  void subscribeToConnection() {
    _clientRepository.onClose((fn) async {
      Log.e("::::onClose... ");
      disconnect();
    });
  }

  @override
  void stopPing() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
