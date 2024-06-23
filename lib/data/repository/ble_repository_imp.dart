import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:file/file.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/data/exception/connection_exception.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/ota_data.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:win_ble/win_ble.dart';

@LazySingleton(as: BluetoothRepository)
class BleRepositoryImp extends BluetoothRepository {
  BleRepositoryImp()
      : _bleScanController = StreamController.broadcast(),
        _gattController = StreamController.broadcast(),
        _connectionTimeout = const Duration(seconds: 5),
        _deviceMap = {};

  final Duration _connectionTimeout;
  final StreamController<BleConnectState> _gattController;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _notifySubscription;
  StreamSubscription? _scanSubscription;
  StreamSubscription<int>? _pingSubscription;
  final Map<String, ScanDevice> _deviceMap;
  final StreamController<List<ScanDevice>> _bleScanController;
  final discoveredDevices = <ScanDevice>[];
  OtaData otaData = OtaData.blank();
  Timer? scanTimer;
  FileProgress? progress;

  final _requestQueue = Queue<Future<void> Function()>();
  bool _isProcessingQueue = false;
  Completer<WaveSensorResponse> _responseCompleter = Completer();

  int _lastTransactionId = 0;
  int attemptCount = 0;

  int _getNextTransactionId() {
    _lastTransactionId++;
    if (_lastTransactionId > 65535) {
      _lastTransactionId = 0;
    }
    return _lastTransactionId;
  }

  @override
  Future<bool> connect(ScanDevice device) async {
    Log.d('[Bluetooth connect Call ] => ${device.macAddress} ${device.rssi} ${device.deviceName}');
    final connectState = await retryAction(() => WinBle.connect(device.macAddress));
    Log.d('[Bluetooth connect Result ] => ${connectState.address} connection state => ${connectState.state}');
    if (connectState.state) await _putDeviceAddress(device);
    await setNotificationEnable(device.macAddress);

    if (connectState.state) {
      await send(WelcomeDataRequest().getRawBytes());
      _pingSubscription = Stream<int>.periodic(
        _connectionTimeout,
        (_) => _,
      ).listen(
        (_) async {
          if (_pingSubscription == null) {
            return;
          }
          try {
            await send(PingDataRequest().getRawBytes());
            attemptCount = 0;
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

    return connectState.state;
  }

  @override
  Future<void> disconnect([String ssid = '']) async {
    Log.d('[Bluetooth disconnect Call ] => $ssid');
    if (!getAddressFromDevice.isNullOrEmpty) {
      await WinBle.disconnect(getAddressFromDevice, null);
      _removeDeviceAddress();
    } else {
      Log.e('not found device');
    }
  }

  @override
  Stream<BleConnectState> get statuses => _gattController.stream;

  @override
  Future<void> startScan() async {
    discoveredDevices.clear();
    if (await WinBle.getBluetoothState() == BleState.On) {
      Log.d("BleState On");
      _scanCallback();
      _checkPairDevice();
      WinBle.startScanning();

      scanTimer?.cancel();
      scanTimer = Timer(const Duration(seconds: 3), () {
        stopScan();
        _bleScanController.add(discoveredDevices);
      });
    } else {
      throw Exception('Bluetooth is off');
    }
  }

  @override
  Future<void> stopScan() async {
    scanTimer?.cancel();
    await _scanSubscription?.cancel();
    WinBle.stopScanning();
  }

  @override
  String? get getAddressFromDevice => _deviceMap.getAddressFromDevice();

  @override
  bool get isClosed => _deviceMap.isNullOrEmpty;

  @override
  Stream<WaveSensorResponse> get responseMessage => throw UnimplementedError();

  @override
  Stream<List<ScanDevice>> get scanMessage => _bleScanController.stream;

  void _scanCallback() {
    _scanSubscription = WinBle.scanStream
        .where((ad) => discoveredDevices.indexWhere((element) => element.macAddress == ad.address) == -1)
        .listen((device) {
      Log.d('scanCallback Call => ${device.name} ${device.address} ${device.rssi}');
      discoveredDevices.add(ScanDevice.toDomain(device.name.replaceAll('\n', ''), device.address, device.rssi));

      Log.d(":::discoveredDevices... $discoveredDevices");
    });
  }

  void _checkPairDevice() {
    Log.d('getAddressFromDevice => $getAddressFromDevice');
    if (getAddressFromDevice != null) {
      final pairDevice = _deviceMap[getAddressFromDevice];

      Log.d("pairDevice.... $pairDevice");
      if (pairDevice != null) {
        _putDeviceAddress(pairDevice);
        discoveredDevices.add(pairDevice);

        Log.d("pairDevice....discoveredDevices  $discoveredDevices");
        _bleScanController.add(discoveredDevices);
      }
    }
  }

  Future<void> _removeDeviceAddress() async {
    _deviceMap.clear();
  }

  Future<void> _putDeviceAddress(ScanDevice device) async {
    if (!_deviceMap.containsKey(device.macAddress)) {
      await dispose();
      _deviceMap[device.macAddress] = device;
      _connectionSubscription = WinBle.connectionStreamOf(device.macAddress).distinct().listen((event) {
        Log.i('>>>>>>>>>>>>>>>>>>>>>[_putDeviceAddress] connectionStreamOf => ${event.address} ${event.state}');
        _updateDeviceInfo(event);
        _gattController.add(event);
      });
      _notifySubscription = characteristicValueStream(device.macAddress).listen((datagram) {
        Log.i('>>>>>>>>>>>>>>>>>>>>>[_putDeviceAddress] characteristicValueStreamOf => ${device.macAddress}');

        // final packet = datagram.whereType<int>().toList();
        // final msgType = packet.sublist(2, 5);
        // String hex = utf8.decode(packet);
        // String event = utf8.decode(msgType);
        //
        // if(event =="FWD") {
        //   final response = hex.extractDataFirmwareDownData().split(",");
        //
        // }else{
        //   _onParseData(datagram);
        // }

        _onParseData(datagram);
      });
    }
  }

  @override
  Future<void> setNotificationEnable(String address,
      {String serviceId = Const.waveServiceUuid, String characteristicId = Const.waveNotifyUuid}) async {
    try {
      await WinBle.discoverCharacteristics(address: address, serviceId: serviceId);

      await WinBle.unSubscribeFromCharacteristic(
          address: address, serviceId: serviceId, characteristicId: characteristicId);
      await WinBle.subscribeToCharacteristic(
          address: address, serviceId: serviceId, characteristicId: characteristicId);
      Log.i('setNotificationEnable True');
    } catch (e) {
      Log.e("unSubscribeToCharacteristic Error: $e");
      for (int i = 0; i < 3; i++) {
        try {
          await WinBle.subscribeToCharacteristic(
              address: address, serviceId: serviceId, characteristicId: characteristicId);
          Log.e("unSubscribeToCharacteristic Error: $e");
          break;
        } catch (e) {
          Log.e("subscribeToCharacteristic Error : $e, Retry Count: $i");
          if (i == 2) {
            Log.e("Failed to subscribe to characteristic after 3 attempts");
            rethrow;
          }
        }
      }
    }
  }

  @override
  Future<WaveSensorResponse> send(Uint8List event) async {
    try {
      return await _rawPacket(event);
    } catch (e) {
      Log.e('[Ble Send packet Error] : $e');
      rethrow;
    }
  }

  @override
  Stream characteristicValueStream(
    String address, {
    String serviceId = Const.waveServiceUuid,
    String characteristicId = Const.waveNotifyUuid,
  }) {
    return WinBle.characteristicValueStreamOf(
      address: address,
      serviceId: serviceId,
      characteristicId: characteristicId,
    );
  }

  @override
  Future<void> startOTA(File file, FileProgress progress) async {
    Log.d("Starting OTA...");
    try {
      this.progress = progress;
      await _pingStop();
      final size = await WinBle.getMaxMtuSize(getAddressFromDevice!);
      Log.d("Max MTU Size: $size");
      final otaStartRequest = OtaStartRequest();
      final content = await file.readAsBytes();
      final totalSize = content.length;

      Log.d('OTA File TotalSize: $totalSize');

      otaData = otaData.copyWith(
        totalDataLen: totalSize,
        totalPageNum: (totalSize / 240).ceil(),
        lastPageDataLen: totalSize % 240,
        totalBuff: content,
      );

      otaStartRequest.setDate(otaData.totalPageNum);

      final response = await send(otaStartRequest.getRawBytes());
      Log.d('startOTA response: $response');

      bool isSetFWDownMode = false;
      if (response is FirmwareDownloadModeResponse) {
        isSetFWDownMode = response.status;
      }
      if (isSetFWDownMode) {
        Log.d('Firmware download mode set');
        //첫번째 데이터 전송...
        // final response = await transferBinaryData();
        await _transferBinaryDataRecursive();
        // await transferBinaryData();
        // await transferBinaryData();
      } else {
        throw Exception('Failed to set firmware download mode');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _transferBinaryDataRecursive() async {
    // final response = await transferBinaryData();

    // Log.d("response: $response");

    await Future.doWhile(() async {

      try{
        final response = await transferBinaryData();

        if (response is FirmwareDownloadingResponse) {
          Log.d('펌웨어 다운로드 진행...');

          if (response.status) {
            otaData = otaData.copyWith(pageNum: response.pageNum, retryCnt: 0);
          } else {
            Log.e('파일 데이터 전송 실패');
            otaData = otaData.copyWith(retryCnt: otaData.retryCnt + 1);
          }

          if (response.pageNum < otaData.totalPageNum) {
            Log.i('파일 데이터 전송 중... ${response.pageNum + 1} / ${otaData.totalPageNum}');
            return true;
          } else {
            Log.d("WOW OTA COMPLETE........");
            otaData = OtaData.blank();

            OtaDataVarityRequest otaDataVarityRequest = OtaDataVarityRequest();
            otaDataVarityRequest.setDate();

            await send(otaDataVarityRequest.getRawBytes());
            return false;
          }
        }
        return true;
      }catch(e){
        rethrow;
      }
    });
  }

  Future<void> _pingStop() async {
    Log.d('Ping Stop');
    await _pingSubscription?.cancel();
    _pingSubscription = null;
  }

  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _notifySubscription?.cancel();
    _notifySubscription = null;
  }

  void _onParseData(dynamic rawPacket) {
    try {
      final datagram = rawPacket.whereType<int>().toList();
      final data = utf8.decode(datagram);
      _responseCompleter.complete(parseResponse(data));
    } on ResponseParseException catch (e) {
      _responseCompleter.completeError(e);
    } catch (e, t) {
      _responseCompleter.completeError(ConnectionException(e, t));
    }
    _responseCompleter = Completer();
  }

  void _updateDeviceInfo(BleConnectState state) async {
    if (state.state) {
    } else {
      _removeDeviceAddress();
    }
  }

  Future<WaveSensorResponse> _rawPacket(Uint8List data) async {
    final completer = Completer<WaveSensorResponse>();

    _requestQueue.add(() async {
      try {
        if (isClosed) {
          throw ConnectionException('Message was not sent', StackTrace.current);
        }

        await WinBle.write(
            address: getAddressFromDevice!,
            service: Const.waveServiceUuid,
            characteristic: Const.waveWriteUuid,
            data: data,
            writeWithResponse: true);

        // Create the new response handler
        var transactionId = _getNextTransactionId();

        String timestamp = '[${DateTime.now().toString()}] ';
        Log.d('$timestamp transactionId $transactionId');
        final response = await _responseCompleter.future.timeout(_connectionTimeout);
        completer.complete(response);
      } on ResponseParseException catch (e) {
        completer.completeError(e);
      } catch (e, t) {
        Log.e('rawPacket error : $e');
        completer.completeError(ConnectionException('Unexpected exception in sending Ble message{$e}', t));
      }
    });

    if (!_isProcessingQueue) {
      unawaited(_processQueue());
    }

    return completer.future;
  }

  Future<void> _processQueue() async {
    _isProcessingQueue = true;

    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      await request();
    }

    _isProcessingQueue = false;
  }

  @override
  Future<WaveSensorResponse> transferBinaryData({
    String serviceId = Const.waveServiceUuid,
    String characteristicId = Const.waveWriteUuid,
  }) async {
    if (otaData == OtaData.blank()) {
      Log.e('ota data blank..!!!!! error');
      throw Exception('ota data blank..!!!!! error');
    }

    Log.d('[${otaData.pageNum + 1} / ${otaData.totalPageNum}]');

    progress?.call(((otaData.pageNum + 1) / otaData.totalPageNum) * 100);

    int sendPage = otaData.pageNum;
    final srcPos = sendPage * 240;
    final endPos = min(srcPos + otaDataLength, otaData.totalDataLen);

    Log.d('startPos: $srcPos' ' endPos: $endPos');

    Uint8List pageBuff = otaData.totalBuff.sublist(srcPos, endPos);

    // 패킷의 크기가 240 바이트보다 작으면, 패킷의 뒷부분을 0으로 채우자

    if ((otaData.pageNum + 1) == otaData.totalPageNum) {
      var paddedPacket = Uint8List(240);
      paddedPacket.setRange(0, pageBuff.length, pageBuff);
      pageBuff = paddedPacket;
    }

    otaData = otaData.copyWith(pageBuff: pageBuff);

    final OtaDataRequest otaDataRequest = OtaDataRequest();

    sendPage = sendPage + 1;
    Log.d('Page => $sendPage');

    otaDataRequest.setDate(pageBuff);
    otaDataRequest.setHeader(page: sendPage);

    Log.d("send--->>>> ${otaDataRequest.getRawBytes()}");

    return await send(otaDataRequest.getRawBytes());
  }
}

Future<BleForceConnectState> retryAction(FutureOr<BleForceConnectState> Function() action, [int retryCount = 3]) async {
  int lAttempts = 1;
  late BleForceConnectState result;
  await Future.doWhile(() async {
    try {
      result = await action();
      Log.d('retryAction => ${result.address} connection state => ${result.state}');
      if (result.state == true || lAttempts >= retryCount) {
        Log.d('Connect Success Exiting loop: lAttempts = $lAttempts, retryCount = $retryCount');
        return false;
      }
    } catch (e) {
      if (lAttempts++ >= retryCount) {
        Log.d('Rethrowing exception: lAttempts = $lAttempts, retryCount = $retryCount');
        rethrow;
      }
    }
    Log.d('[ReConnection loop: lAttempts = $lAttempts, retryCount = $retryCount');
    return result.state == false && lAttempts++ <= retryCount;
  });
  return result;
}

writeCharacteristic(String address, String serviceID, String charID, Uint8List data, bool writeWithResponse) async {
  try {
    await WinBle.write(
        address: address, service: serviceID, characteristic: charID, data: data, writeWithResponse: true);
  } catch (e) {
    Log.e(e.toString());
  }
}
