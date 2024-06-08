import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/domain/repository/bluetooth_repository.dart';
import 'package:wave_desktop_installer/domain/repository/patch_repository.dart';
import 'package:wave_desktop_installer/domain/repository/wifi_repository.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

@injectable
class FirmwareUpdateViewModel {
  FirmwareUpdateViewModel(
    this._wifiRepository,
    this._bleRepository,
    this._patchRepository,
  );

  final WifiRepository _wifiRepository;
  final BluetoothRepository _bleRepository;
  final PatchRepository _patchRepository;


  void checkFirmwareUpdate() async {
    try{
      final response = await _patchRepository.fetchPatchDetails();
      Log.i('[checkFirmwareUpdate] response $response');
    }catch(e){
      Log.e('[checkFirmwareUpdate] error: $e');
    }
  }

  void dispose() {

  }
}
