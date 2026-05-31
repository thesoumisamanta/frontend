import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class NetworkLogger {
  NetworkLogger({
    Logger? logger,
    this.enabled = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logHeaders = false,
    this.logErrors = true,
  }) : _logger =
           logger ??
           Logger(
             printer: PrettyPrinter(methodCount: 0, printEmojis: false),
             level: Level.debug,
           );

  final Logger _logger;
  final bool enabled;
  final bool logRequestBody;
  final bool logResponseBody;
  final bool logHeaders;
  final bool logErrors;

  void debug(String message) {
    if (!enabled) {
      return;
    }
    _logger.d(message);
  }

  void info(String message) {
    if (!enabled) {
      return;
    }
    _logger.i(message);
  }

  void warning(String message) {
    if (!enabled) {
      return;
    }
    _logger.w(message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled || !logErrors) {
      return;
    }
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void logRequest(RequestOptions options) {
    if (!enabled) {
      return;
    }

    final buffer = StringBuffer()
      ..writeln('┌──→ ${options.method.toUpperCase()} ${options.uri}');

    if (logHeaders) {
      buffer.writeln('Headers: ${_sanitizeHeaders(options.headers)}');
    }

    if (logRequestBody && options.data != null) {
      buffer.writeln('Body: ${_stringify(options.data)}');
    }

    buffer.write('└────────────────────────────────────');
    _logger.d(buffer.toString());
  }

  void logResponse(Response<dynamic> response) {
    if (!enabled) {
      return;
    }

    final buffer = StringBuffer()
      ..writeln('┌──← ${response.statusCode} ${response.requestOptions.uri}');

    if (logHeaders) {
      buffer.writeln('Headers: ${_sanitizeHeaders(response.headers.map)}');
    }

    if (logResponseBody && response.data != null) {
      buffer.writeln('Body: ${_stringify(response.data)}');
    }

    buffer.write('└────────────────────────────────────');
    _logger.i(buffer.toString());
  }

  void logDioError(DioException error) {
    if (!enabled || !logErrors) {
      return;
    }

    final buffer = StringBuffer()
      ..writeln(
        '┌──× ${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}',
      );

    if (error.response?.statusCode != null) {
      buffer.writeln('Status: ${error.response!.statusCode}');
    }

    if (error.response?.data != null) {
      buffer.writeln('Response: ${_stringify(error.response!.data)}');
    }

    buffer.write('└────────────────────────────────────');
    _logger.e(buffer.toString(), error: error, stackTrace: error.stackTrace);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    const sensitiveKeys = <String>{
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
    };

    return headers.map((key, value) {
      final lowerKey = key.toString().toLowerCase();
      if (sensitiveKeys.contains(lowerKey)) {
        return MapEntry(key.toString(), '***');
      }
      return MapEntry(key.toString(), value);
    });
  }

  String _stringify(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
