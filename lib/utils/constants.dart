class AppConstants {
  // API Base URL - Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:5000'; // For iOS Simulator
  // static const String baseUrl = 'https://your-api.com'; // For Production
  
  // API Endpoints
  static const String apiUrl = '$baseUrl/api';
  
  // Auth Endpoints
  static const String loginEndpoint = '$apiUrl/auth/login';
  static const String registerEndpoint = '$apiUrl/auth/register';
  static const String logoutEndpoint = '$apiUrl/auth/logout';
  static const String getMeEndpoint = '$apiUrl/auth/me';
  static const String refreshTokenEndpoint = '$apiUrl/auth/refresh-token';
  static const String updateFCMTokenEndpoint = '$apiUrl/auth/fcm-token';
  
  // User Endpoints
  static const String getUserProfileEndpoint = '$apiUrl/users/profile';
  static const String updateProfileEndpoint = '$apiUrl/users/profile';
  static const String followEndpoint = '$apiUrl/users/follow';
  static const String searchUsersEndpoint = '$apiUrl/users/search';
  
  // Post Endpoints
  static const String createPostEndpoint = '$apiUrl/posts';
  static const String getFeedEndpoint = '$apiUrl/posts/feed';
  static const String getUserPostsEndpoint = '$apiUrl/posts/user';
  static const String likePostEndpoint = '$apiUrl/posts';
  static const String dislikePostEndpoint = '$apiUrl/posts';
  static const String deletePostEndpoint = '$apiUrl/posts';
  
  // Comment Endpoints
  static const String createCommentEndpoint = '$apiUrl/comments/post';
  static const String getCommentsEndpoint = '$apiUrl/comments/post';
  
  // Story Endpoints
  static const String createStoryEndpoint = '$apiUrl/stories';
  static const String getStoriesEndpoint = '$apiUrl/stories/following';
  
  // Chat Endpoints
  static const String getChatsEndpoint = '$apiUrl/chats';
  static const String getChatEndpoint = '$apiUrl/chats/user';
  static const String sendMessageEndpoint = '$apiUrl/chats';
  
  // Notification Endpoints
  static const String getNotificationsEndpoint = '$apiUrl/notifications';
  
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