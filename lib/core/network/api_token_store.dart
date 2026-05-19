abstract interface class ApiTokenStore {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<String?> readRefreshToken();

  Future<void> writeRefreshToken(String token);

  Future<void> clearToken();
}
