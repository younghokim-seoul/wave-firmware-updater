import 'dart:async';
import 'dart:typed_data';

import 'package:control_protocol/src/response.dart';
import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';
import 'package:wave_desktop_installer/utils/extension/value_extension.dart';
import 'package:win_ble/win_ble.dart';

@LazySingleton(as: BluetoothRepository)
class BleRepositoryImp extends BluetoothRepository {
  BleRepositoryImp()
      : _bleScanController = StreamController.broadcast(),
        _deviceMap = {};

  StreamSubscription? _scanSubscription;
  final Map _deviceMap;
  final StreamController<List<ScanDevice>> _bleScanController;
  final discoveredDevices = <ScanDevice>[];

  @override
  Future<bool> connect(String ssid) async {
    Log.d('[Bluetooth connect Call ] => $ssid');
    final connectState = await retryAction(() => WinBle.connect(ssid));
    Log.d('[Bluetooth connect Result ] => ${connectState.address} connection state => ${connectState.state}');
    if (connectState.state) _putDeviceAddress(ssid);
    return connectState.state;
  }

  @override
  Future<void> disconnect([String ssid = '']) async {
    Log.d('[Bluetooth disconnect Call ] => $ssid');
    if (!getAddressFromDevice.isNullOrEmpty) {
      await WinBle.disconnect(getAddressFromDevice, null);
      _removeDeviceAddress();
    }else{
      Log.e('not found device');
    }
  }

  @override
  Future<void> send(Uint8List event, {bool isAutoConnect = false}) {
    // TODO: implement send
    throw UnimplementedError();
  }

  @override
  Stream<ConnectionStatus> get statuses => throw UnimplementedError();

  @override
  Future<void> startScan() async {
    if (await WinBle.getBluetoothState() == BleState.On) {
      Log.d("BleState On");
      _scanCallback();
      WinBle.startScanning();
    } else {
      throw Exception('Bluetooth is off');
    }
    discoveredDevices.clear();
  }

  @override
  Future<void> stopScan() async {
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
  Stream<List<ScanDevice>> get scanMessage => _bleScanController.stream.distinct();

  void _scanCallback() {
    _scanSubscription = WinBle.scanStream
        .where((ad) => discoveredDevices.indexWhere((element) => element.macAddress == ad.address) == -1)
        .listen((device) {
      Log.d('scanCallback Call => ${device.name} ${device.address} ${device.rssi}');
      discoveredDevices.add(ScanDevice.toDomain(device.name.replaceAll('\n', ''), device.address, device.rssi));
      _bleScanController.add(discoveredDevices);
    });
  }

  void _removeDeviceAddress() {
    _deviceMap.clear();
  }

  void _putDeviceAddress(String ssid) {
    _deviceMap[ssid] = ssid;
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
