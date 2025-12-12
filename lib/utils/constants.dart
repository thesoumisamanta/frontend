class AppConstants {
  // API Endpoints
  static String get apiUrl => 'https://backend-r9e6.onrender.com/api';

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
