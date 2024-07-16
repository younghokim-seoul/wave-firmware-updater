import 'package:dio/dio.dart';

class CancelTokenManager {
  static final Map<String, CancelToken> _tokens = {};

  static void addToken(String key, CancelToken token) {
    _tokens[key] = token;
  }

  static void cancelToken(String key) {
    if (_tokens.containsKey(key)) {
      _tokens[key]?.cancel();
      _tokens.remove(key);
    }
  }

  static void cancelAll() {
    _tokens.forEach((key, token) {
      if (token.isCancelled == false) {
        token.cancel();
      }
    });
    _tokens.clear();
  }

  static void removeToken(String path) {
    _tokens.remove(path);
  }
}