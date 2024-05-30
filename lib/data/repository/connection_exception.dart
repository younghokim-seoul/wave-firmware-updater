class ConnectionException implements Exception {
  const ConnectionException(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;
}
