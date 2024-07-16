import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:tuple/tuple.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';

abstract class WifiRepository {
  Future<bool> connect(ScanDevice device);

  Future<void> disconnect([String ssid = '']);

  Future<void> startScan();

  Future<void> stopScan();

  Future<WaveSensorResponse> send(Uint8List event, {bool isAutoConnect = false, Duration? timeout});

  void subscribeToConnection();

  Stream<WaveSensorResponse> get responseMessage;

  Stream<List<ScanDevice>> get scanMessage;

  Stream<Tuple2<String, ConnectionStatus>> get statuses;

  void stopPing();

  bool get isClosed;

  String? get getAddressFromDevice;
}
