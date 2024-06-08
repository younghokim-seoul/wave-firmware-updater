// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:tcp_client/tcp_client.dart' as _i8;

import '../data/network/api_service.dart' as _i11;
import '../data/repository/ble_repository_imp.dart' as _i5;
import '../data/repository/patch_repository_imp.dart' as _i10;
import '../data/repository/wifi_repository_imp.dart' as _i7;
import '../data/wifi_scanner.dart' as _i3;
import '../domain/repository/bluetooth_repository.dart' as _i4;
import '../domain/repository/patch_repository.dart' as _i9;
import '../domain/repository/wifi_repository.dart' as _i6;
import '../feature/pages/connection/connection_view_model.dart' as _i14;
import '../feature/pages/firmware_update/firmware_update_view_model.dart'
    as _i13;
import '../feature/pages/setting/setting_view_model.dart' as _i12;

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
  gh.lazySingleton<_i4.BluetoothRepository>(() => _i5.BleRepositoryImp());
  gh.lazySingleton<_i6.WifiRepository>(() => _i7.WifiRepositoryImp(
        gh<_i8.TcpClientRepository>(),
        gh<_i3.WifiScanner>(),
      ));
  gh.lazySingleton<_i9.PatchRepository>(
      () => _i10.PatchRepositoryImp(gh<_i11.ApiService>()));
  gh.factory<_i12.SettingViewModel>(
      () => _i12.SettingViewModel(gh<_i6.WifiRepository>()));
  gh.factory<_i13.FirmwareUpdateViewModel>(() => _i13.FirmwareUpdateViewModel(
        gh<_i6.WifiRepository>(),
        gh<_i4.BluetoothRepository>(),
        gh<_i9.PatchRepository>(),
      ));
  gh.factory<_i14.ConnectionViewModel>(() => _i14.ConnectionViewModel(
        gh<_i6.WifiRepository>(),
        gh<_i4.BluetoothRepository>(),
      ));
  return getIt;
}
