import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/tcp_client.dart';
import 'package:wave_desktop_installer/data/repository/wifi_scanner.dart';


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

  gh.lazySingleton<TcpClientRepository>(() => TcpClientRepository('192.168.8.1', serverPort: 4999));
  gh.lazySingleton<WifiScanner>(() => WifiScanner());
  config.$initGetIt(getIt);
}
