import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/comment/comment_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'blocs/post/post_bloc.dart';
import 'blocs/story/story_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'config/app_environment.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/secure_storage_service.dart';
import 'utils/theme.dart';

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
          create: (context) =>
              AuthBloc(apiService: apiService, secureStorage: secureStorage)
                ..add(AuthCheckRequested()),
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
        title: AppEnvironment.current.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
