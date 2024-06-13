import 'package:wave_desktop_installer/data/fwupd/fwupd_listener.dart';
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

  Future<void> install(FirmwareVersion release);
  Future<void> reboot();

  void addFirmWareChannelListener(FirmWareChannelListener listener);
  void removeFirmWareChannelListener();
}