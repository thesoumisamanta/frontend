import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_diary_network/network.dart';

void main() {
  group('NetworkException', () {
    test('maps connection timeout to timeout', () {
      final exception = NetworkException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(exception.type, NetworkExceptionType.timeout);
    });

    test('maps 401 response to unauthorized', () {
      final exception = NetworkException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
        ),
      );

      expect(exception.type, NetworkExceptionType.unauthorized);
      expect(exception.message, 'Unauthorized');
    });

    test('maps socket error to no internet', () {
      final exception = NetworkException.fromObject(
        const SocketException('Failed host lookup'),
      );

      expect(exception.type, NetworkExceptionType.noInternet);
    });
  });
}
