import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/tcp_client.dart';
import 'package:wave_desktop_installer/data/network/api_client.dart';
import 'package:wave_desktop_installer/data/network/api_service.dart';
import 'package:wave_desktop_installer/utils/constant.dart';
import 'package:wave_desktop_installer/utils/dev_log.dart';

import 'configurations.config.dart' as config;

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() => $initGetIt(getIt);

Future<void> $initGetIt(
  GetIt getIt, {
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {

  final gh = GetItHelper(getIt, environment.toString());

  final sharedPreferences = await SharedPreferences.getInstance();

  var baseApiClient = ApiClient(enableLogging: !kReleaseMode);

  gh.factory<Dio>(() => baseApiClient.apiProvider.getDio);

  gh.factory<ApiService>(() => ApiService(getIt<Dio>()));

  gh.lazySingleton<TcpClientRepository>(
    () => TcpClientRepository(Const.waveIp, serverPort: Const.wavePort),
    dispose: (TcpClientRepository repo) {
      Log.d('TcpClientRepository Dispose');
      repo.disconnect();
    },
  );
  config.$initGetIt(getIt);
}
