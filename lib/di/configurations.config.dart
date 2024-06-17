// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:tcp_client/tcp_client.dart' as _i10;

import '../data/fwupd/fwupd_imp.dart' as _i5;
import '../data/fwupd/fwupd_service.dart' as _i4;
import '../data/network/api_service.dart' as _i13;
import '../data/repository/ble_repository_imp.dart' as _i7;
import '../data/repository/patch_repository_imp.dart' as _i12;
import '../data/repository/wifi_repository_imp.dart' as _i9;
import '../data/wifi_scanner.dart' as _i3;
import '../domain/repository/bluetooth_repository.dart' as _i6;
import '../domain/repository/patch_repository.dart' as _i11;
import '../domain/repository/wifi_repository.dart' as _i8;
import '../feature/pages/connection/connection_view_model.dart' as _i17;
import '../feature/pages/firmware_update/firmware_update_view_model.dart'
    as _i15;
import '../feature/pages/setting/setting_view_model.dart' as _i14;
import '../main_view_model.dart' as _i16;

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
  gh.lazySingleton<_i3.WifiScanner>(() => _i3.WifiScanner());
  gh.lazySingleton<_i4.FwupdService>(() => _i5.FwupdImp());
  gh.lazySingleton<_i6.BluetoothRepository>(() => _i7.BleRepositoryImp());
  gh.lazySingleton<_i8.WifiRepository>(() => _i9.WifiRepositoryImp(
        gh<_i10.TcpClientRepository>(),
        gh<_i3.WifiScanner>(),
      ));
  gh.lazySingleton<_i11.PatchRepository>(
      () => _i12.PatchRepositoryImp(gh<_i13.ApiService>()));
  gh.factory<_i14.SettingViewModel>(
      () => _i14.SettingViewModel(gh<_i8.WifiRepository>()));
  gh.factory<_i15.FirmwareUpdateViewModel>(() => _i15.FirmwareUpdateViewModel(
        gh<_i8.WifiRepository>(),
        gh<_i6.BluetoothRepository>(),
        gh<_i11.PatchRepository>(),
        gh<_i4.FwupdService>(),
      ));
  gh.lazySingleton<_i16.MainViewModel>(() => _i16.MainViewModel(
        gh<_i8.WifiRepository>(),
        gh<_i6.BluetoothRepository>(),
      ));
  gh.factory<_i17.ConnectionViewModel>(() => _i17.ConnectionViewModel(
        gh<_i8.WifiRepository>(),
        gh<_i6.BluetoothRepository>(),
      ));
  return getIt;
}
