import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class NetworkException implements Exception {
  const NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.data,
    this.originalError,
  });

  final String message;
  final NetworkExceptionType type;
  final int? statusCode;
  final Object? data;
  final Object? originalError;

  factory NetworkException.noInternet([Object? originalError]) {
    return NetworkException(
      message: 'No internet connection available.',
      type: NetworkExceptionType.noInternet,
      originalError: originalError,
    );
  }

  factory NetworkException.fromDioException(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final responseMessage = _extractMessage(response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: responseMessage ?? 'Request timed out.',
          type: NetworkExceptionType.timeout,
          statusCode: statusCode,
          data: response?.data,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          message: responseMessage ?? 'Request was cancelled.',
          type: NetworkExceptionType.cancelled,
          statusCode: statusCode,
          data: response?.data,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return NetworkException.noInternet(error);
      case DioExceptionType.badResponse:
        return _fromStatusCode(
          statusCode: statusCode,
          message:
              responseMessage ??
              'Received an invalid response from the server.',
          data: response?.data,
          originalError: error,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException.noInternet(error);
        }

        if (error.error is TimeoutException) {
          return NetworkException(
            message: responseMessage ?? 'Request timed out.',
            type: NetworkExceptionType.timeout,
            statusCode: statusCode,
            data: response?.data,
            originalError: error,
          );
        }

        return NetworkException(
          message:
              responseMessage ??
              error.message ??
              'Unexpected network error occurred.',
          type: NetworkExceptionType.unknown,
          statusCode: statusCode,
          data: response?.data,
          originalError: error,
        );
    }
  }

  factory NetworkException.fromObject(Object error) {
    if (error is DioException) {
      return NetworkException.fromDioException(error);
    }

    if (error is SocketException) {
      return NetworkException.noInternet(error);
    }

    if (error is TimeoutException) {
      return const NetworkException(
        message: 'Request timed out.',
        type: NetworkExceptionType.timeout,
      );
    }

    return NetworkException(
      message: error.toString(),
      type: NetworkExceptionType.unknown,
      originalError: error,
    );
  }

  static NetworkException _fromStatusCode({
    required int? statusCode,
    required String message,
    required Object? data,
    required Object originalError,
  }) {
    final type = _mapStatusCode(statusCode);

    return NetworkException(
      message: message,
      type: type,
      statusCode: statusCode,
      data: data,
      originalError: originalError,
    );
  }

  static NetworkExceptionType _mapStatusCode(int? statusCode) {
    if (statusCode == 400 || statusCode == 422) {
      return NetworkExceptionType.validation;
    }

    if (statusCode == 401) {
      return NetworkExceptionType.unauthorized;
    }

    if (statusCode == 403) {
      return NetworkExceptionType.forbidden;
    }

    if (statusCode == 404) {
      return NetworkExceptionType.notFound;
    }

    if (statusCode == 409) {
      return NetworkExceptionType.conflict;
    }

    if (statusCode != null && statusCode >= 500) {
      return NetworkExceptionType.serverError;
    }

    return NetworkExceptionType.badResponse;
  }

  static String? _extractMessage(Object? data) {
    if (data == null) {
      return null;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (data is Map) {
      final map = data.cast<Object?, Object?>();
      final candidates = <Object?>[
        map['message'],
        map['error'],
        map['detail'],
        map['title'],
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate;
        }
      }

      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'NetworkException(type: $type, statusCode: $statusCode, message: $message)';
  }
}

enum NetworkExceptionType {
  timeout,
  cancelled,
  noInternet,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  badResponse,
  serverError,
  unknown,
}
