import 'package:wave_desktop_installer/data/fwupd/fwupd_listener.dart';
import 'package:wave_desktop_installer/di/app_provider.dart';
import 'package:wave_desktop_installer/domain/model/firmware_version.dart';

enum FwupdStatus {
  idle,
  initializing,
  downloading,
  complete,
  error,
}


abstract class FwupdService {
  FwupdService();

  FwupdStatus get status;
  double get percentage;

  Future<void> wifiInstall();
  Future<void> bluetoothInstall(FirmwareVersion release);
  Future<void> cancelInstall();
  Future<void> writeConfig(FirmwareVersion version);
  Future<String> readConfig();
  Future<void> reboot();

  void addFirmWareChannelListener(FirmWareChannelListener listener);
  void removeFirmWareChannelListener();
}