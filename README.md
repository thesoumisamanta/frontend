# Travel Diary - Flutter Frontend

A beautiful, feature-rich mobile application built with Flutter for iOS and Android. A complete social media platform for travel enthusiasts with posts, stories, real-time chat, and push notifications.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [State Management](#state-management)
- [Authentication Flow](#authentication-flow)
- [Features Deep Dive](#features-deep-dive)
- [Testing](#testing)
- [Building](#building)
- [Deployment](#deployment)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

Travel Diary is a cross-platform mobile application that allows users to share their travel experiences through posts, stories, and real-time conversations. Built with Flutter and BLoC pattern, it offers a seamless experience on both iOS and Android.

### Key Highlights

- **Modern UI/UX**: Material Design 3 with light/dark theme support
- **State Management**: BLoC pattern for predictable state management
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Real-time Features**: Push notifications via Firebase
- **Offline Support**: Cached images and data persistence
- **Auto Token Refresh**: Seamless authentication with automatic token renewal
- **Responsive Design**: Adapts to different screen sizes

---

## ✨ Features

### Authentication & Security
- Secure login and registration
- JWT token authentication (access + refresh tokens)
- Automatic token refresh (transparent to user)
- Biometric authentication ready
- Secure local storage for sensitive data
- Cookie-based session management

### User Experience
- **Profile Management**: Edit profile, upload photos, customize bio
- **Follow System**: Follow/unfollow users (Instagram-style)
- **Account Types**: Personal and Business accounts
- **Search**: Find users by username or name
- **Private Accounts**: Control who can see your content

### Content Creation
- **Posts**: Share photos and videos with captions
- **Stories**: 24-hour disappearing content
- **Shorts**: Quick video posts (TikTok-style)
- **Location Tagging**: Add locations to posts
- **Hashtags**: Tag posts with hashtags
- **Multi-media**: Upload up to 10 photos per post

### Social Interaction
- **Like/Dislike**: React to posts
- **Comments**: Nested comments on posts
- **Comment Reactions**: Like/dislike comments
- **Share**: Share posts with others
- **Real-time Chat**: One-on-one messaging
- **Message Status**: Read receipts

### Notifications
- **Push Notifications**: Firebase Cloud Messaging
- **In-app Notifications**: Activity feed
- **Notification Types**: Follows, likes, comments, messages

### Additional Features
- **Followers/Following Lists**: View connections
- **Post Grid View**: Instagram-style profile grid
- **Pull to Refresh**: Update content easily
- **Infinite Scroll**: Seamless content loading
- **Image Caching**: Fast image loading
- **Dark Mode**: Eye-friendly night theme

---

## 📱 Screenshots

```
[ Add screenshots here ]

- Login Screen
- Home Feed
- Profile Screen
- Post Creation
- Story Viewer
- Chat Interface
- Notifications
```

---

## 🛠 Tech Stack

### Framework & Language
- **Flutter**: 3.0+
- **Dart**: 3.0+

### State Management
- **flutter_bloc**: ^8.1.3 - BLoC pattern implementation
- **equatable**: ^2.0.5 - Value equality

### Networking
- **dio**: ^5.4.0 - HTTP client with interceptors
- **http**: ^1.1.2 - Alternative HTTP client

### Local Storage
- **flutter_secure_storage**: ^9.0.0 - Secure key-value storage

### Firebase Services
- **firebase_core**: ^2.24.2 - Firebase initialization
- **firebase_messaging**: ^14.7.10 - Push notifications
- **flutter_local_notifications**: ^16.3.0 - Local notifications

### UI Components
- **cached_network_image**: ^3.3.0 - Image caching
- **google_fonts**: ^6.1.0 - Custom fonts
- **shimmer**: ^3.0.0 - Loading animations
- **photo_view**: ^0.14.0 - Image viewer
- **loading_animation_widget**: ^1.2.0 - Loading indicators

### Media Handling
- **image_picker**: ^1.0.7 - Pick images/videos
- **video_player**: ^2.8.2 - Video playback
- **chewie**: ^1.7.4 - Video player UI
- **camera**: ^0.10.5 - Camera access
- **image_cropper**: ^5.0.1 - Image cropping

### Utilities
- **intl**: ^0.19.0 - Internationalization
- **timeago**: ^3.6.0 - Relative timestamps
- **url_launcher**: ^6.2.3 - Launch URLs
- **share_plus**: ^7.2.1 - Share content
- **connectivity_plus**: ^5.0.2 - Network status

---

## 🏗 Architecture

### BLoC Pattern

```
Presentation Layer (UI)
         ↓
    BLoC Layer (Business Logic)
         ↓
  Repository Layer (Data)
         ↓
    API Service / Local Storage
```

### App Architecture

```
Travel Diary Frontend
│
├── Presentation Layer
│   ├── Screens (UI Components)
│   └── Widgets (Reusable UI)
│
├── Business Logic Layer (BLoC)
│   ├── Events (User Actions)
│   ├── States (UI States)
│   └── BLoC (State Management)
│
├── Data Layer
│   ├── Models (Data Structures)
│   ├── Services (API, Storage)
│   └── Repositories (Data Sources)
│
└── Utils
    ├── Constants
    ├── Themes
    └── Helpers
```

---

## 📦 Prerequisites

### Required Software

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.0.0
- **Android Studio** or **Xcode** (depending on target platform)
- **Git**: For version control

### For Android Development
- Android Studio
- Android SDK (API level 21+)
- Java JDK 11+

### For iOS Development (Mac only)
- Xcode 14+
- CocoaPods
- iOS 12+

### Required Accounts
- **Firebase Account**: For push notifications
- **Backend API**: Running Travel Diary backend

---

## 🚀 Installation

### Step 1: Install Flutter

Follow the official guide: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### Step 2: Clone Repository

```bash
git clone <repository-url>
cd frontend
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Firebase Setup

#### Android Setup

1. Create Firebase project at https://console.firebase.google.com/
2. Add Android app with package name: `com.example.travel_diary`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

#### iOS Setup

1. In same Firebase project, add iOS app
2. Use bundle ID: `com.example.travelDiary`
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` via Xcode

### Step 5: Update API URL

Edit `lib/utils/constants.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:5000';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:5000';

// For Real Device (replace with your IP)
// static const String baseUrl = 'http://192.168.1.100:5000';

// For Production
// static const String baseUrl = 'https://api.yourdomain.com';
```

### Step 6: Run the App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

---

## ⚙️ Configuration

### Android Configuration

**File: `android/app/build.gradle`**

```gradle
defaultConfig {
    applicationId "com.example.travel_diary"
    minSdkVersion 21
    targetSdkVersion 34
    versionCode 1
    versionName "1.0.0"
    multiDexEnabled true
}
```

**File: `android/app/src/main/AndroidManifest.xml`**

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS Configuration

**File: `ios/Runner/Info.plist`**

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to camera to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to microphone to record videos</string>
```

### App Configuration

**File: `lib/utils/constants.dart`**

```dart
class AppConstants {
  // API Configuration
  static const String baseUrl = 'YOUR_API_URL';
  
  // Token Configuration
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;
  
  // Media Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxImagesPerPost = 10;
}
```

---

## 🎭 State Management

### BLoC Pattern Implementation

#### Event → BLoC → State Flow

```dart
// 1. User Action triggers Event
context.read<PostBloc>().add(PostLoadFeed(refresh: true));

// 2. BLoC processes Event
class PostBloc extends Bloc<PostEvent, PostState> {
  on<PostLoadFeed>(_onPostLoadFeed);
  
  Future<void> _onPostLoadFeed(event, emit) async {
    emit(PostLoading());
    final posts = await apiService.getFeed();
    emit(PostFeedLoaded(posts));
  }
}

// 3. UI reacts to State changes
BlocBuilder<PostBloc, PostState>(
  builder: (context, state) {
    if (state is PostLoading) return CircularProgressIndicator();
    if (state is PostFeedLoaded) return PostsList(state.posts);
    return ErrorWidget();
  },
)
```

### Available BLoCs

- **AuthBloc**: Authentication and user session
- **PostBloc**: Post management and feed
- **UserBloc**: User profiles and search
- **StoryBloc**: Stories management
- **ChatBloc**: Messaging functionality
- **CommentBloc**: Comments and replies
- **NotificationBloc**: Notifications

### BLoC Best Practices

```dart
// ✅ Good: Use BlocProvider at app level
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
    BlocProvider<PostBloc>(create: (_) => PostBloc()),
  ],
  child: MyApp(),
)

// ✅ Good: Use BlocListener for side effects
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: MyWidget(),
)

// ✅ Good: Use BlocBuilder for UI updates
BlocBuilder<PostBloc, PostState>(
  builder: (context, state) {
    // Return UI based on state
  },
)
```

---

## 🔐 Authentication Flow

### Login/Register Flow

```
1. User enters credentials
   ↓
2. AuthBloc dispatches AuthLoginRequested event
   ↓
3. API Service makes login request
   ↓
4. Backend returns access + refresh tokens
   ↓
5. Tokens saved to Secure Storage
   ↓
6. AuthBloc emits AuthAuthenticated state
   ↓
7. UI navigates to Main Screen
```

### Automatic Token Refresh

```
1. User makes API request
   ↓
2. Dio interceptor adds access token
   ↓
3. Backend returns 401 (token expired)
   ↓
4. Token interceptor catches error
   ↓
5. Automatically calls /refresh-token
   ↓
6. Gets new access + refresh tokens
   ↓
7. Saves new tokens
   ↓
8. Retries original request
   ↓
9. User continues seamlessly (no interruption)
```

### Token Storage

```dart
// Secure Storage Service
class SecureStorageService {
  // Access Token (24h)
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  
  // Refresh Token (7d)
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  
  // Clear on logout
  Future<void> clearAll();
}
```

---

## 🎨 Features Deep Dive

### Post Creation

```dart
// 1. User selects media
final images = await ImagePicker().pickMultiImage();

// 2. Add caption and metadata
final caption = 'Amazing sunset in Bali!';
final location = 'Bali, Indonesia';
final tags = ['travel', 'sunset', 'bali'];

// 3. Create post
context.read<PostBloc>().add(
  PostCreate(
    caption: caption,
    postType: 'image',
    mediaFiles: images,
    location: location,
    tags: tags,
  ),
);

// 4. BLoC uploads to API
// 5. Post appears in feed
```

### Real-time Chat

```dart
// 1. Check mutual following
final canChat = await checkMutualFollowing(userId);

// 2. Get or create chat
final chat = await getOrCreateChat(userId);

// 3. Load messages
context.read<ChatBloc>().add(
  ChatLoadMessages(chatId: chat.id),
);

// 4. Send message
context.read<ChatBloc>().add(
  ChatSendMessage(
    chatId: chat.id,
    text: 'Hello!',
  ),
);

// 5. Receive push notification (other user)
```

### Story Creation

```dart
// 1. Capture/select media
final media = await ImagePicker().pickImage();

// 2. Create story
context.read<StoryBloc>().add(
  StoryCreate(
    mediaFile: media,
    caption: 'My travel moment',
  ),
);

// 3. Story visible for 24h
// 4. Auto-expires after 24h (backend)
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/blocs/auth_bloc_test.dart
```

### Test Structure

```
test/
├── blocs/
│   ├── auth_bloc_test.dart
│   ├── post_bloc_test.dart
│   └── user_bloc_test.dart
├── models/
│   └── user_model_test.dart
├── services/
│   └── api_service_test.dart
└── widgets/
    └── post_card_test.dart
```

### Writing Tests

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

blocTest<AuthBloc, AuthState>(
  'emits AuthAuthenticated when login succeeds',
  build: () => AuthBloc(apiService: mockApiService),
  act: (bloc) => bloc.add(AuthLoginRequested(
    emailOrUsername: 'test@example.com',
    password: 'password123',
  )),
  expect: () => [
    AuthLoading(),
    AuthAuthenticated(mockUser),
  ],
);
```

---

## 🏗 Building

### Build Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI
flutter build apk --split-per-abi

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Android App Bundle (AAB)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Output: build/ios/iphoneos/Runner.app
```

### Build for Web (Future)

```bash
flutter build web --release

# Output: build/web/
```

---

## 🚢 Deployment

### Google Play Store (Android)

1. **Create signing key:**
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. **Configure signing** in `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        storeFile file("/path/to/key.jks")
        storePassword "password"
        keyAlias "key"
        keyPassword "password"
    }
}
```

3. **Build release AAB:**
```bash
flutter build appbundle --release
```

4. **Upload to Play Console**

### Apple App Store (iOS)

1. **Open in Xcode:**
```bash
open ios/Runner.xcworkspace
```

2. **Configure signing in Xcode:**
   - Select Runner project
   - Select Runner target
   - Go to Signing & Capabilities
   - Select your team

3. **Archive the app:**
   - Product → Archive
   - Validate → Upload to App Store Connect

4. **Submit for review in App Store Connect**

---

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── blocs/                    # State management
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── post/
│   │   ├── user/
│   │   ├── story/
│   │   ├── chat/
│   │   ├── comment/
│   │   └── notification/
│   │
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   ├── story_model.dart
│   │   ├── comment_model.dart
│   │   ├── chat_model.dart
│   │   ├── message_model.dart
│   │   └── notification_model.dart
│   │
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── home/
│   │       ├── main_screen.dart
│   │       ├── feed_screen.dart
│   │       ├── search_screen.dart
│   │       ├── create_post_screen.dart
│   │       ├── notifications_screen.dart
│   │       ├── profile_screen.dart
│   │       ├── post_detail_screen.dart
│   │       ├── chat_list_screen.dart
│   │       ├── chat_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       └── followers_screen.dart
│   │
│   ├── widgets/                  # Reusable widgets
│   │   ├── post_card.dart
│   │   ├── story_list.dart
│   │   ├── comment_item.dart
│   │   ├── user_list_tile.dart
│   │   ├── message_bubble.dart
│   │   ├── profile_post_grid.dart
│   │   └── cached_image.dart
│   │
│   ├── services/                 # API and storage
│   │   ├── api_service.dart
│   │   ├── secure_storage_service.dart
│   │   ├── notification_service.dart
│   │   └── token_interceptor.dart
│   │
│   ├── utils/                    # Utilities
│   │   ├── constants.dart
│   │   ├── theme.dart
│   │   └── bloc_observer.dart
│   │
│   └── main.dart                 # App entry point
│
├── android/                      # Android native code
│   └── app/
│       ├── build.gradle
│       └── google-services.json
│
├── ios/                          # iOS native code
│   └── Runner/
│       ├── Info.plist
│       └── GoogleService-Info.plist
│
├── test/                         # Tests
├── pubspec.yaml                  # Dependencies
└── README.md
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Firebase initialization failed

**Error:**
```
PlatformException: Failed to load FirebaseOptions
```

**Solution:**
- Ensure `google-services.json` is in `android/app/`
- Check package name matches Firebase Console
- Run `flutter clean && flutter pub get`

#### 2. Token refresh not working

**Error:**
```
401 Unauthorized (token expired)
```

**Solution:**
- Check `TokenInterceptor` is added to Dio
- Verify refresh token is saved in secure storage
- Check backend `/refresh-token` endpoint

#### 3. Images not loading

**Error:**
```
Image failed to load
```

**Solution:**
- Check internet permission in AndroidManifest.xml
- Verify API URL is correct
- Check if backend is running
- Clear app cache

#### 4. Build fails on iOS

**Error:**
```
CocoaPods could not find compatible versions
```

**Solution:**
```bash
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter build ios
```

#### 5. Hot reload not working

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Debug Mode

Enable debug logging:

```dart
// lib/services/api_service.dart
_dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ),
);
```

---

## 📚 Learning Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### BLoC
- [BLoC Library](https://bloclibrary.dev)
- [BLoC Tutorial](https://bloclibrary.dev/#/gettingstarted)

### Firebase
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library maintainers
- Firebase team
- All open-source contributors

---

## 📞 Support

For issues and questions:
- Create an issue on GitHub
- Check documentation
- Review troubleshooting section

---

**Built with ❤️ using Flutter**