typedef TokenHeaderBuilder = Map<String, String> Function(String token);

abstract interface class NetworkTokenProvider {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearTokens();
}
