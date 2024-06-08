import 'package:wave_desktop_installer/data/network/api_provider.dart';

class ApiClient {
  final bool enableLogging;
  late final ApiProviderFactory apiProvider;

  ApiClient({required this.enableLogging}) {
    apiProvider = ApiProviderFactory(enableLogging);
  }
}
