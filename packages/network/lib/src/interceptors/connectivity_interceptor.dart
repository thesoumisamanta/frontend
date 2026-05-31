import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../core/network_exception.dart';
import '../core/network_logger.dart';

class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor({Connectivity? connectivity, NetworkLogger? logger})
    : _connectivity = connectivity ?? Connectivity(),
      _logger = logger;

  final Connectivity _connectivity;
  final NetworkLogger? _logger;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipConnectivityCheck'] == true) {
      return handler.next(options);
    }

    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      _logger?.warning('Connectivity check failed for ${options.uri}');
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: NetworkException.noInternet(),
          message: 'No internet connection available.',
        ),
      );
    }

    return handler.next(options);
  }
}
