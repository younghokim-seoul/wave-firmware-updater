abstract class ConnectionRepository {
  Future<void> connect(Map<String, dynamic> request);

  Future<void> disconnect(Map<String, dynamic> request);
}
