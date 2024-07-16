// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:tcp_client/tcp_client.dart' as _i6;

import '../data/fwupd/fwupd_imp.dart' as _i16;
import '../data/fwupd/fwupd_service.dart' as _i15;
import '../data/network/api_service.dart' as _i12;
import '../data/repository/ble_repository_imp.dart' as _i8;
import '../data/repository/patch_repository_imp.dart' as _i11;
import '../data/repository/wifi_repository_imp.dart' as _i5;
import '../data/system_wifi.dart' as _i3;
import '../domain/repository/bluetooth_repository.dart' as _i7;
import '../domain/repository/patch_repository.dart' as _i10;
import '../domain/repository/wifi_repository.dart' as _i4;
import '../feature/pages/connection/connection_view_model.dart' as _i9;
import '../feature/pages/firmware_update/firmware_update_view_model.dart'
    as _i17;
import '../feature/pages/setting/setting_view_model.dart' as _i13;
import '../main_view_model.dart' as _i14;

// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.lazySingleton<_i3.SystemWifiUtils>(() => _i3.SystemWifiUtils());
  gh.lazySingleton<_i4.WifiRepository>(() => _i5.WifiRepositoryImp(
        gh<_i6.TcpClientRepository>(),
        gh<_i3.SystemWifiUtils>(),
      ));
  gh.lazySingleton<_i7.BluetoothRepository>(() => _i8.BleRepositoryImp());
  gh.lazySingleton<_i9.ConnectionViewModel>(() => _i9.ConnectionViewModel(
        gh<_i4.WifiRepository>(),
        gh<_i7.BluetoothRepository>(),
      ));
  gh.lazySingleton<_i10.PatchRepository>(
      () => _i11.PatchRepositoryImp(gh<_i12.ApiService>()));
  gh.factory<_i13.SettingViewModel>(
      () => _i13.SettingViewModel(gh<_i4.WifiRepository>()));
  gh.lazySingleton<_i14.MainViewModel>(() => _i14.MainViewModel(
        gh<_i4.WifiRepository>(),
        gh<_i7.BluetoothRepository>(),
        gh<_i10.PatchRepository>(),
      ));
  gh.lazySingleton<_i15.FwupdService>(
      () => _i16.FwupdImp(gh<_i7.BluetoothRepository>()));
  gh.factory<_i17.FirmwareUpdateViewModel>(() => _i17.FirmwareUpdateViewModel(
        gh<_i4.WifiRepository>(),
        gh<_i7.BluetoothRepository>(),
        gh<_i10.PatchRepository>(),
        gh<_i15.FwupdService>(),
      ));
  return getIt;
}
