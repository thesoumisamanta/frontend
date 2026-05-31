import 'dart:async';

import 'package:dio/dio.dart';

import '../core/network_config.dart';
import '../core/network_logger.dart';
import '../token/network_token_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required NetworkConfig config,
    required NetworkTokenProvider tokenProvider,
    required NetworkLogger logger,
  }) : _dio = dio,
       _config = config,
       _tokenProvider = tokenProvider,
       _logger = logger;

  final Dio _dio;
  final NetworkConfig _config;
  final NetworkTokenProvider _tokenProvider;
  final NetworkLogger _logger;

  Completer<bool>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_config.isAuthSkippable(options.path, options.method)) {
      return handler.next(options);
    }

    final accessToken = await _tokenProvider.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      _config.accessTokenHeaderBuilder(accessToken).forEach((key, value) {
        options.headers[key] = value;
      });
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = requestOptions.extra['_network_auth_retry'] == true;

    if (!isUnauthorized ||
        alreadyRetried ||
        _config.isAuthSkippable(requestOptions.path, requestOptions.method)) {
      return handler.next(err);
    }

    final refreshToken = await _tokenProvider.getRefreshToken();
    if (refreshToken == null || _config.tokenRefresher == null) {
      await _tokenProvider.clearTokens();
      return handler.next(err);
    }

    final refreshed = await _refreshTokens(refreshToken);
    if (!refreshed) {
      await _tokenProvider.clearTokens();
      return handler.next(err);
    }

    final newAccessToken = await _tokenProvider.getAccessToken();
    if (newAccessToken == null || newAccessToken.isEmpty) {
      return handler.next(err);
    }

    requestOptions.extra['_network_auth_retry'] = true;
    _config.accessTokenHeaderBuilder(newAccessToken).forEach((key, value) {
      requestOptions.headers[key] = value;
    });

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      return handler.resolve(response);
    } on DioException catch (refreshError) {
      return handler.next(refreshError);
    } catch (error) {
      return handler.next(
        DioException(
          requestOptions: requestOptions,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  Future<bool> _refreshTokens(String? refreshToken) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final tokenPair = await _config.tokenRefresher!(
        dio: _dio,
        refreshToken: refreshToken,
      );
      if (tokenPair == null || !tokenPair.isValid) {
        _logger.warning('Token refresh returned no valid token pair.');
        completer.complete(false);
        return false;
      }

      await _tokenProvider.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );
      _logger.info('Authentication tokens refreshed successfully.');
      completer.complete(true);
      return true;
    } catch (error, stackTrace) {
      _logger.error('Token refresh failed', error, stackTrace);
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
