import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/data/connection_status.dart';


part 'scan_device.freezed.dart';

@freezed
class ScanDevice with _$ScanDevice {
  const factory ScanDevice({
    required String deviceName,
    required String macAddress,
    required String rssi,
    required ConnectionStatus status,
  }) = _ScanDevice;

  factory ScanDevice.toDomain(String deviceName, String macAddress, String rssi, ConnectionStatus status) {
    return ScanDevice(deviceName: deviceName, macAddress: macAddress, rssi: rssi,status: status);
  }
}
