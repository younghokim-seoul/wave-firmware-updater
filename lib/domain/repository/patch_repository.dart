import 'package:wave_desktop_installer/domain/model/firmware_version.dart';

abstract class PatchRepository {
  Future<FirmwareVersion> fetchPatchDetails();
}
