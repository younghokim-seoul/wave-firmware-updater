// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:tcp_client/tcp_client.dart' as _i5;

import '../data/repository/ble_repository_imp.dart' as _i8;
import '../data/repository/wifi_repository_imp.dart' as _i4;
import '../data/repository/wifi_scanner.dart' as _i6;
import '../domain/repository/bluetooth_repository.dart' as _i7;
import '../domain/repository/wifi_repository.dart' as _i3;
import '../feature/pages/connection/connection_view_model.dart' as _i9;
import '../feature/pages/setting/setting_view_model.dart' as _i10;

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
  gh.lazySingleton<_i3.WifiRepository>(() => _i4.WifiRepositoryImp(
        gh<_i5.TcpClientRepository>(),
        gh<_i6.WifiScanner>(),
      ));
  gh.lazySingleton<_i7.BluetoothRepository>(() => _i8.BleRepositoryImp());
  gh.factory<_i9.ConnectionViewModel>(() => _i9.ConnectionViewModel(
        gh<_i3.WifiRepository>(),
        gh<_i7.BluetoothRepository>(),
      ));
  gh.factory<_i10.SettingViewModel>(
      () => _i10.SettingViewModel(gh<_i3.WifiRepository>()));
  return getIt;
}
