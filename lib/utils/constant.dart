import 'package:wave_desktop_installer/utils/dev_log.dart';

class Const {
  static LogLevel logLevel = LogLevel.v;
  static bool useProxy = false;
  static String proxyAddress = '192.168.206.119:8888';

  static const String waveIp = '192.168.8.1';
  static const int wavePort = 4999;

  static const String baseUrl = 'https://skills.golfzonwave.com';
  static const String publicApi = '/common/json';

  static const String waveOsCode = 'G_RADAR_MINI';

  static const int ftpPort = 3999;
  static const String ftpUser = 'upgrade';
  static const String ftpPass = 'gradar';
}
