import 'package:dio/dio.dart';

import '../interceptors/auth_interceptor.dart';
import '../interceptors/connectivity_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../token/network_token_provider.dart';
import 'network_config.dart';
import 'network_exception.dart';
import 'network_logger.dart';

class NetworkClient {
  NetworkClient({
    required NetworkConfig config,
    NetworkTokenProvider? tokenProvider,
    NetworkLogger? logger,
    Dio? dio,
    List<Interceptor> additionalInterceptors = const [],
  }) : _config = config,
       _tokenProvider = tokenProvider,
       _logger = logger ?? NetworkLogger(enabled: config.enableLogging),
       _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: Map<String, dynamic>.from(config.defaultHeaders),
      responseType: ResponseType.json,
      contentType: 'application/json',
      validateStatus: (status) =>
          status != null && status >= 200 && status < 500,
    );
    _dio.interceptors.clear();

    if (_config.enableConnectivityCheck) {
      _dio.interceptors.add(ConnectivityInterceptor(logger: _logger));
    }

    if (_tokenProvider != null) {
      _dio.interceptors.add(
        AuthInterceptor(
          dio: _dio,
          config: _config,
          tokenProvider: _tokenProvider,
          logger: _logger,
        ),
      );
    }

    if (_config.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor(logger: _logger));
    }

    if (additionalInterceptors.isNotEmpty) {
      _dio.interceptors.addAll(additionalInterceptors);
    }
  }

  final NetworkConfig _config;
  final NetworkTokenProvider? _tokenProvider;
  final NetworkLogger _logger;
  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _execute(() {
      return _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _execute(() {
      return _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _execute(() {
      return _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _execute(() {
      return _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute(() {
      return _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }

  Future<Response<T>> request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _execute(() {
      return _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: options?.headers,
          extra: options?.extra,
          responseType: options?.responseType,
          contentType: options?.contentType,
          followRedirects: options?.followRedirects,
          validateStatus: options?.validateStatus,
          receiveDataWhenStatusError: options?.receiveDataWhenStatusError,
          receiveTimeout: options?.receiveTimeout,
          sendTimeout: options?.sendTimeout,
          requestEncoder: options?.requestEncoder,
          responseDecoder: options?.responseDecoder,
          listFormat: options?.listFormat,
          persistentConnection: options?.persistentConnection,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> uploadFormData<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> _execute<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException.fromObject(error);
    }
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
