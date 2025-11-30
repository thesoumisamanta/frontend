import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  // Your computer's IP address (from wlo1 interface)
  static const String _localIp = '192.168.0.104';
  
  // Cached values
  static String? _cachedBaseUrl;
  static bool? _isEmulator;
  
  /// Get base URL - automatically detects emulator vs real device
  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    
    if (kIsWeb) {
      _cachedBaseUrl = 'http://localhost:5000';
      return _cachedBaseUrl!;
    }
    
    // Check if running on emulator
    _isEmulator ??= await _checkIfEmulator();
    
    if (Platform.isAndroid) {
      _cachedBaseUrl = _isEmulator! 
          ? 'http://10.0.2.2:5000'      // Android Emulator
          : 'http://$_localIp:5000';    // Real Android Device
    } else if (Platform.isIOS) {
      _cachedBaseUrl = _isEmulator!
          ? 'http://localhost:5000'     // iOS Simulator
          : 'http://$_localIp:5000';    // Real iPhone
    } else {
      _cachedBaseUrl = 'http://localhost:5000';
    }
    
    // Debug log
    print('🌐 API URL: $_cachedBaseUrl (${_isEmulator! ? "Emulator" : "Real Device"})');
    
    return _cachedBaseUrl!;
  }
  
  /// Synchronous getter (use after calling getBaseUrl() first)
  static String get baseUrl {
    if (_cachedBaseUrl == null) {
      throw Exception('Call AppConstants.getBaseUrl() first in main()!');
    }
    return _cachedBaseUrl!;
  }

  /// Check if running on emulator/simulator
  static Future<bool> _checkIfEmulator() async {
    if (Platform.isAndroid) {
      // Check for emulator characteristics
      try {
        final result = await Process.run('getprop', ['ro.kernel.qemu']);
        return result.stdout.toString().trim() == '1';
      } catch (e) {
        // Fallback: check for common emulator indicators
        final brand = Platform.environment['android.os.Build.BRAND'] ?? '';
        final model = Platform.environment['android.os.Build.MODEL'] ?? '';
        return brand.toLowerCase().contains('generic') || 
               model.toLowerCase().contains('emulator') ||
               model.toLowerCase().contains('sdk');
      }
    }
    
    if (Platform.isIOS) {
      // iOS Simulator detection
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
    }
    
    return false;
  }

  // API Endpoints
  static String get apiUrl => '$baseUrl/api';

  // Auth Endpoints
  static String get loginEndpoint => '$apiUrl/auth/login';
  static String get registerEndpoint => '$apiUrl/auth/register';
  static String get logoutEndpoint => '$apiUrl/auth/logout';
  static String get getMeEndpoint => '$apiUrl/auth/me';
  static String get refreshTokenEndpoint => '$apiUrl/auth/refresh-token';
  static String get updateFCMTokenEndpoint => '$apiUrl/auth/fcm-token';

  // User Endpoints
  static String get getUserProfileEndpoint => '$apiUrl/users/profile';
  static String get updateProfileEndpoint => '$apiUrl/users/profile';
  static String get followEndpoint => '$apiUrl/users/follow';
  static String get searchUsersEndpoint => '$apiUrl/users/search';

  // Post Endpoints
  static String get createPostEndpoint => '$apiUrl/posts';
  static String get getFeedEndpoint => '$apiUrl/posts/feed';
  static String get getUserPostsEndpoint => '$apiUrl/posts/user';
  static String get likePostEndpoint => '$apiUrl/posts';
  static String get dislikePostEndpoint => '$apiUrl/posts';
  static String get deletePostEndpoint => '$apiUrl/posts';

  // Comment Endpoints
  static String get createCommentEndpoint => '$apiUrl/comments/post';
  static String get getCommentsEndpoint => '$apiUrl/comments/post';

  // Story Endpoints
  static String get createStoryEndpoint => '$apiUrl/stories';
  static String get getStoriesEndpoint => '$apiUrl/stories/following';

  // Chat Endpoints
  static String get getChatsEndpoint => '$apiUrl/chats';
  static String get getChatEndpoint => '$apiUrl/chats/user';
  static String get sendMessageEndpoint => '$apiUrl/chats';

  // Notification Endpoints
  static String get getNotificationsEndpoint => '$apiUrl/notifications';

  // Secure Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String emailKey = 'email';
  static const String accountTypeKey = 'account_type';

  // Token Configuration
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;

  // Media
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxImagesPerPost = 10;

  // Story
  static const Duration storyDuration = Duration(seconds: 5);
  static const Duration storyDisplayDuration = Duration(hours: 24);
}