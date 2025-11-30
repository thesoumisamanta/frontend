import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final SecureStorageService secureStorage;

  AuthBloc({required this.apiService, required this.secureStorage})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateFCMToken>(_onAuthUpdateFCMToken);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final isLoggedIn = await secureStorage.isLoggedIn();

      if (isLoggedIn) {
        // Try to get user data from API
        try {
          final response = await apiService.getMe();

          if (response['success'] == true) {
            final user = UserModel.fromJson(response['user']);

            // Save user data to secure storage
            await secureStorage.saveUserData(
              userId: user.id,
              username: user.username,
              email: user.email,
              fullName: user.fullName,
              accountType: user.accountType,
              profilePicture: user.profilePicture.url,
            );

            // Get and update FCM token
            final fcmToken = await NotificationService.getToken();
            if (fcmToken != null) {
              await apiService.updateFCMToken(fcmToken);
              await secureStorage.saveFCMToken(fcmToken);
            }

            emit(AuthAuthenticated(user));
          } else {
            await secureStorage.clearAll();
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          // If API call fails but we have refresh token, try to refresh
          final refreshToken = await secureStorage.getRefreshToken();

          if (refreshToken != null) {
            try {
              final refreshResponse = await apiService.refreshToken();

              if (refreshResponse['success'] == true) {
                // Save new tokens
                await secureStorage.saveTokens(
                  accessToken: refreshResponse['accessToken'],
                  refreshToken: refreshResponse['refreshToken'],
                );

                // Try to get user data again
                final response = await apiService.getMe();
                if (response['success'] == true) {
                  final user = UserModel.fromJson(response['user']);
                  emit(AuthAuthenticated(user));
                  return;
                }
              }
            } catch (e) {
              print('Token refresh failed: $e');
            }
          }

          await secureStorage.clearAll();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('Auth check error: $e');
      await secureStorage.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final response = await apiService.login(
        emailOrUsername: event.emailOrUsername,
        password: event.password,
      );

      if (response['success'] == true) {
        final accessToken = response['accessToken'];
        final refreshToken = response['refreshToken'];
        final user = UserModel.fromJson(response['user']);

        // Save tokens
        await secureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Save user data
        await secureStorage.saveUserData(
          userId: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          accountType: user.accountType,
          profilePicture: user.profilePicture.url,
        );

        // Get and update FCM token
        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          await apiService.updateFCMToken(fcmToken);
          await secureStorage.saveFCMToken(fcmToken);
        }

        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError(response['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final response = await apiService.register(
        username: event.username,
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        accountType: event.accountType,
      );

      if (response['success'] == true) {
        final accessToken = response['accessToken'];
        final refreshToken = response['refreshToken'];
        final user = UserModel.fromJson(response['user']);

        // Save tokens
        await secureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Save user data
        await secureStorage.saveUserData(
          userId: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          accountType: user.accountType,
          profilePicture: user.profilePicture.url,
        );

        // Get and update FCM token
        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          await apiService.updateFCMToken(fcmToken);
          await secureStorage.saveFCMToken(fcmToken);
        }

        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError(response['message'] ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await apiService.logout();
      await secureStorage.clearAll();

      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if API call fails, clear local data
      await secureStorage.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthUpdateFCMToken(
    AuthUpdateFCMToken event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await apiService.updateFCMToken(event.fcmToken);
      await secureStorage.saveFCMToken(event.fcmToken);
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
