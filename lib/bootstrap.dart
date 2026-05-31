import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'config/app_environment.dart';
import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/secure_storage_service.dart';
import 'utils/bloc_observer.dart';

class _SilentBlocObserver extends BlocObserver {}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppEnvironment.initialize(flavor);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService.initialize();

    if (AppEnvironment.current.enableVerboseLogs) {
      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    if (AppEnvironment.current.enableVerboseLogs) {
      debugPrint('Firebase initialization error: $e');
    }
  }

  Bloc.observer = AppEnvironment.current.enableVerboseLogs
      ? AppBlocObserver()
      : _SilentBlocObserver();

  final secureStorage = SecureStorageService();
  final apiService = ApiService(secureStorage);

  runApp(TravelDiaryApp(secureStorage: secureStorage, apiService: apiService));
}
