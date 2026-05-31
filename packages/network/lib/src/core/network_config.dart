import 'package:dio/dio.dart';

import '../token/network_token_provider.dart';
import '../token/token_pair.dart';

typedef NetworkRequestMatcher = bool Function(String path, String method);

typedef NetworkTokenRefresher =
    Future<TokenPair?> Function({
      required Dio dio,
      required String? refreshToken,
    });

Map<String, String> defaultBearerHeaderBuilder(String token) {
  return <String, String>{'Authorization': 'Bearer $token'};
}

class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.enableConnectivityCheck = true,
    this.defaultHeaders = const <String, dynamic>{
      'Content-Type': 'application/json',
    },
    this.refreshTokenPath = '/auth/refresh-token',
    this.skipAuthForPaths = const <String>[],
    this.shouldSkipAuth,
    this.accessTokenHeaderBuilder = defaultBearerHeaderBuilder,
    this.tokenRefresher,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableConnectivityCheck;
  final Map<String, dynamic> defaultHeaders;
  final String refreshTokenPath;
  final List<String> skipAuthForPaths;
  final NetworkRequestMatcher? shouldSkipAuth;
  final TokenHeaderBuilder accessTokenHeaderBuilder;
  final NetworkTokenRefresher? tokenRefresher;

  bool isAuthSkippable(String path, String method) {
    if (shouldSkipAuth != null) {
      return shouldSkipAuth!(path, method);
    }

    return skipAuthForPaths.any(
          (excludedPath) => path.contains(excludedPath),
        ) ||
        path.contains(refreshTokenPath) ||
        path.contains('/auth/login') ||
        path.contains('/auth/register');
  }

  NetworkConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? enableLogging,
    bool? enableConnectivityCheck,
    Map<String, dynamic>? defaultHeaders,
    String? refreshTokenPath,
    List<String>? skipAuthForPaths,
    NetworkRequestMatcher? shouldSkipAuth,
    TokenHeaderBuilder? accessTokenHeaderBuilder,
    NetworkTokenRefresher? tokenRefresher,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      enableLogging: enableLogging ?? this.enableLogging,
      enableConnectivityCheck:
          enableConnectivityCheck ?? this.enableConnectivityCheck,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      refreshTokenPath: refreshTokenPath ?? this.refreshTokenPath,
      skipAuthForPaths: skipAuthForPaths ?? this.skipAuthForPaths,
      shouldSkipAuth: shouldSkipAuth ?? this.shouldSkipAuth,
      accessTokenHeaderBuilder:
          accessTokenHeaderBuilder ?? this.accessTokenHeaderBuilder,
      tokenRefresher: tokenRefresher ?? this.tokenRefresher,
    );
  }
}
