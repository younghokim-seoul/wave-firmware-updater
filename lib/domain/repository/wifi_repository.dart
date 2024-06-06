import 'package:control_protocol/control_protocol.dart';
import 'package:wave_desktop_installer/domain/model/scan_device.dart';


abstract class WifiRepository {
  Future<void> connect(String address, int port);

  Future<void> disconnect();

  Future<void> startScan();

  Future<void> stopScan();

  Stream<WaveSensorResponse> get responseMessage;
  Stream<List<ScanDevice>> get scanMessage;
  bool get isClosed;
}
