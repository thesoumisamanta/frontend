import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'secure_storage_service.dart';
import 'token_interceptor.dart';

class ApiService {
  final SecureStorageService _secureStorage;
  late final Dio _dio;
  late final TokenInterceptor _tokenInterceptor;

  ApiService(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add token interceptor
    _tokenInterceptor = TokenInterceptor(_secureStorage, _dio);
    _dio.interceptors.add(_tokenInterceptor);

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _secureStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Cookie': 'accessToken=$accessToken',
    };
  }

  // Auth APIs
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String accountType,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'accountType': accountType,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'emailOrUsername': emailOrUsername,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/auth/refresh-token',
        options: Options(
          headers: {'Cookie': 'refreshToken=$refreshToken'},
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.get('/auth/logout');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateFCMToken(String fcmToken) async {
    try {
      await _dio.put('/auth/fcm-token', data: {'fcmToken': fcmToken});
    } catch (e) {
      throw _handleError(e);
    }
  }

  // User APIs
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/profile/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/profile', data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> followUnfollowUser(String userId) async {
    try {
      final response = await _dio.post('/users/follow/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/users/search', queryParameters: {'query': query});
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFollowers(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/followers');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFollowing(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/following');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Post APIs
  Future<Map<String, dynamic>> createPost({
    required String caption,
    required String postType,
    required List<File> mediaFiles,
    String? location,
    List<String>? tags,
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('caption', caption));
      formData.fields.add(MapEntry('postType', postType));
      if (location != null) formData.fields.add(MapEntry('location', location));
      if (tags != null) formData.fields.add(MapEntry('tags', tags.join(',')));

      for (var file in mediaFiles) {
        formData.files.add(
          MapEntry(
            'media',
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ),
        );
      }

      final response = await _dio.post('/posts', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/posts/feed',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 12,
    String? postType,
  }) async {
    try {
      final response = await _dio.get(
        '/posts/user/$userId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (postType != null) 'postType': postType,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/like');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> dislikePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/dislike');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final response = await _dio.delete('/posts/$postId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sharePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/share');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Comment APIs
  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final response = await _dio.post(
        '/comments/post/$postId',
        data: {
          'text': text,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPostComments(
    String postId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/comments/post/$postId',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCommentReplies(String commentId) async {
    try {
      final response = await _dio.get('/comments/$commentId/replies');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> likeComment(String commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/like');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> dislikeComment(String commentId) async {
    try {
      final response = await _dio.post('/comments/$commentId/dislike');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final response = await _dio.delete('/comments/$commentId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Story APIs
  Future<Map<String, dynamic>> createStory({
    required File mediaFile,
    String? caption,
  }) async {
    try {
      FormData formData = FormData();
      if (caption != null) formData.fields.add(MapEntry('caption', caption));
      formData.files.add(
        MapEntry(
          'media',
          await MultipartFile.fromFile(mediaFile.path, filename: mediaFile.path.split('/').last),
        ),
      );

      final response = await _dio.post('/stories', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFollowingStories() async {
    try {
      final response = await _dio.get('/stories/following');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserStories(String userId) async {
    try {
      final response = await _dio.get('/stories/user/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      await _dio.post('/stories/$storyId/view');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteStory(String storyId) async {
    try {
      final response = await _dio.delete('/stories/$storyId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Chat APIs
  Future<Map<String, dynamic>> getOrCreateChat(String userId) async {
    try {
      final response = await _dio.get('/chats/user/$userId');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getChats() async {
    try {
      final response = await _dio.get('/chats');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    String? text,
    File? mediaFile,
    String? sharedPostId,
  }) async {
    try {
      FormData formData = FormData();
      if (text != null) formData.fields.add(MapEntry('text', text));
      if (sharedPostId != null) formData.fields.add(MapEntry('sharedPostId', sharedPostId));
      if (mediaFile != null) {
        formData.files.add(
          MapEntry(
            'media',
            await MultipartFile.fromFile(mediaFile.path, filename: mediaFile.path.split('/').last),
          ),
        );
      }

      final response = await _dio.post('/chats/$chatId/message', data: formData);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/chats/$chatId/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await _dio.post('/chats/$chatId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Notification APIs
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Business Mail APIs
  Future<Map<String, dynamic>> sendBusinessMail({
    required String recipientId,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/mails/send',
        data: {
          'recipientId': recipientId,
          'subject': subject,
          'message': message,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getInbox({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/mails/inbox',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return 'Server error: ${error.response?.statusCode}';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'Receive timeout';
      } else {
        return 'Network error occurred';
      }
    }
    return 'An unexpected error occurred';
  }
}