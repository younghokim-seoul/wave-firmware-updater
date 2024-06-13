import 'dart:typed_data';

import 'package:control_protocol/control_protocol.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';


abstract class WifiRepository {
  Future<bool> connect(String ssid);

  Future<void> disconnect();

  Future<void> startScan();

  Future<void> stopScan();

  Future<void> send(Uint8List event, {bool isAutoConnect = false});

  Stream<WaveSensorResponse> get responseMessage;
  Stream<List<ScanDevice>> get scanMessage;
  Stream<ConnectionStatus> get statuses;
  bool get isClosed;

  String? get getAddressFromDevice;
}
