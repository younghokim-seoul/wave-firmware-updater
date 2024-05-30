import 'package:injectable/injectable.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

@lazySingleton
class SettingViewModel  {

  SettingViewModel(){
    Log.d('SettingViewModel created');
  }
}