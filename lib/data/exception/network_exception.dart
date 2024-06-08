class NetworkException implements Exception {
  NetworkException(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}
