abstract class IDatabaseService {
  Future<void> connect();
  Future<void> disconnect();
  Future<dynamic> query(String collection, Map<String, dynamic> filter);
}

