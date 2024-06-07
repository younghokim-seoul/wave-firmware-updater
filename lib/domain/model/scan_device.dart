import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wave_desktop_installer/data/repository/connection_status.dart';

part 'scan_device.freezed.dart';

@freezed
class ScanDevice with _$ScanDevice {
  const factory ScanDevice({
    required String deviceName,
    required String macAddress,
    required String rssi,
  }) = _ScanDevice;

  factory ScanDevice.toDomain(String deviceName, String macAddress, String rssi) {
    return ScanDevice(deviceName: deviceName, macAddress: macAddress, rssi: rssi);
  }
}
