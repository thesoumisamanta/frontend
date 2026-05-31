import 'package:dio/dio.dart';

import '../core/network_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({required NetworkLogger logger}) : _logger = logger;

  final NetworkLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['suppressLogging'] != true) {
      _logger.logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.extra['suppressLogging'] != true) {
      _logger.logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.extra['suppressLogging'] != true) {
      _logger.logDioError(err);
    }
    handler.next(err);
  }
}
