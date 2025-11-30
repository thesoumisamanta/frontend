import 'package:dio/dio.dart';
import 'secure_storage_service.dart';
import '../utils/constants.dart';

class TokenInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  TokenInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't add token to refresh token endpoint
    if (options.path.contains('refresh-token') || 
        options.path.contains('login') || 
        options.path.contains('register')) {
      return handler.next(options);
    }

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Cookie'] = 'accessToken=$accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is due to token expiration
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;
      
      if (responseData is Map && responseData['tokenExpired'] == true) {
        // Token expired, try to refresh
        try {
          await _refreshToken();
          
          // Retry the original request
          final options = err.requestOptions;
          final accessToken = await _secureStorage.getAccessToken();
          
          if (accessToken != null) {
            options.headers['Cookie'] = 'accessToken=$accessToken';
          }

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          // Refresh failed, pass the error
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) {
      // Wait for the refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));
      return _refreshToken();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstants.apiUrl,
        headers: {'Cookie': 'refreshToken=$refreshToken'},
      ));

      final response = await refreshDio.post('/auth/refresh-token');

      if (response.data['success'] == true) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        print('Token refreshed successfully');
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      // Clear tokens on refresh failure
      await _secureStorage.clearAll();
      throw e;
    } finally {
      _isRefreshing = false;
    }
  }
}