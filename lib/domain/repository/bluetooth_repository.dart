
import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:file/file.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:win_ble/win_ble.dart';

typedef FileProgress = void Function(double progressInPercent);

abstract class BluetoothRepository {
  Future<bool> connect(ScanDevice device);

  Future<void> disconnect([String ssid = '']);

  Future<void> startScan();

  Future<void> stopScan();


  Future<WaveSensorResponse> send(Uint8List event);

  Future<void> startOTA(File file,FileProgress progress);

  Future<void> failOTA();

  Future<WaveSensorResponse> transferBinaryData({String serviceId = Const.waveServiceUuid, String characteristicId = Const.waveWriteUuid});

  Future<void> setNotificationEnable(String address, {String serviceId = Const.waveServiceUuid, String characteristicId = Const.waveNotifyUuid});

  Stream characteristicValueStream(String address, {String serviceId = Const.waveServiceUuid, String characteristicId = Const.waveNotifyUuid});

  Stream<WaveSensorResponse> get responseMessage;

  Stream<List<ScanDevice>> get scanMessage;

  Stream<BleConnectState> get statuses;

  bool get isClosed;

  String? get getAddressFromDevice;
}
