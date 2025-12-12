import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/blocs/auth/auth_event.dart';
import 'package:frontend/blocs/comment/comment_bloc.dart';
import 'package:frontend/utils/constants.dart';
import 'services/secure_storage_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/post/post_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/story/story_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/bloc_observer.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Uncomment when you're ready for Firebase
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await NotificationService.initialize();

  // Initialize BLoC Observer for debugging
  Bloc.observer = AppBlocObserver();

  // Initialize services
  final secureStorage = SecureStorageService();
  final apiService = ApiService(secureStorage);

  runApp(
    TravelDiaryApp(
      secureStorage: secureStorage,
      apiService: apiService,
    ),
  );
}

class TravelDiaryApp extends StatelessWidget {
  final SecureStorageService secureStorage;
  final ApiService apiService;

  const TravelDiaryApp({
    super.key,
    required this.secureStorage,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            apiService: apiService,
            secureStorage: secureStorage,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(apiService: apiService),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(apiService: apiService),
        ),
        BlocProvider<StoryBloc>(
          create: (context) => StoryBloc(apiService: apiService),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(apiService: apiService),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(apiService: apiService),
        ),
        BlocProvider<CommentBloc>(
          create: (context) => CommentBloc(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Travel Diary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}