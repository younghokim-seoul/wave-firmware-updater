import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:wave_desktop_installer/utils/constant.dart';




abstract class ApiProviderFactory {
  Dio get getDio;

  factory ApiProviderFactory(bool enableLogger, {BaseOptions? options}) =>
      ApiProvider(enableLogger, options: options);
}

class ApiProvider implements ApiProviderFactory {
  static const int apiTimeOut = 60000;
  static late Dio dio;

  bool enableLogger;

  ApiProvider(this.enableLogger, {BaseOptions? options}) {
    final dioInstance = Dio(options ?? BaseOptions()
      ..baseUrl = Const.baseUrl
      ..connectTimeout = const Duration(milliseconds: apiTimeOut)
      ..receiveTimeout = const Duration(milliseconds: apiTimeOut)
      ..headers = <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'accept': 'application/json',
      });

    if (enableLogger) {
      dioInstance.interceptors.add(PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90));
    }

    dio = dioInstance;
  }

  @override
  Dio get getDio => dio;
}
