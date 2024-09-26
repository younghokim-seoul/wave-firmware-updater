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

import '../data/fwupd/fwupd_imp.dart' as _i18;
import '../data/fwupd/fwupd_service.dart' as _i17;
import '../data/network/api_service.dart' as _i13;
import '../data/repository/ble_repository_imp.dart' as _i10;
import '../data/repository/patch_repository_imp.dart' as _i12;
import '../data/repository/wifi_repository_imp.dart' as _i5;
import '../data/socket/socket_repository_impl.dart' as _i8;
import '../data/system_wifi.dart' as _i3;
import '../domain/repository/bluetooth_repository.dart' as _i9;
import '../domain/repository/patch_repository.dart' as _i11;
import '../domain/repository/socket_repository.dart' as _i7;
import '../domain/repository/wifi_repository.dart' as _i4;
import '../feature/pages/camera/camera_view_model.dart' as _i16;
import '../feature/pages/connection/connection_view_model.dart' as _i14;
import '../feature/pages/firmware_update/firmware_update_view_model.dart'
    as _i19;
import '../feature/pages/setting/setting_view_model.dart' as _i15;
import '../main_view_model.dart' as _i20;

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
  gh.lazySingleton<_i7.SocketRepository>(() => _i8.SocketRepositoryImpl());
  gh.lazySingleton<_i9.BluetoothRepository>(() => _i10.BleRepositoryImp());
  gh.lazySingleton<_i11.PatchRepository>(
      () => _i12.PatchRepositoryImp(gh<_i13.ApiService>()));
  gh.lazySingleton<_i14.ConnectionViewModel>(
      () => _i14.ConnectionViewModel(gh<_i4.WifiRepository>()));
  gh.factory<_i15.SettingViewModel>(
      () => _i15.SettingViewModel(gh<_i4.WifiRepository>()));
  gh.factory<_i16.CameraViewModel>(() => _i16.CameraViewModel(
        gh<_i7.SocketRepository>(),
        gh<_i3.SystemWifiUtils>(),
      ));
  gh.lazySingleton<_i17.FwupdService>(
      () => _i18.FwupdImp(gh<_i9.BluetoothRepository>()));
  gh.factory<_i19.FirmwareUpdateViewModel>(() => _i19.FirmwareUpdateViewModel(
        gh<_i4.WifiRepository>(),
        gh<_i9.BluetoothRepository>(),
        gh<_i11.PatchRepository>(),
        gh<_i17.FwupdService>(),
      ));
  gh.lazySingleton<_i20.MainViewModel>(() => _i20.MainViewModel(
        gh<_i4.WifiRepository>(),
        gh<_i17.FwupdService>(),
      ));
  return getIt;
}
