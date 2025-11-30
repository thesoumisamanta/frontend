import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String emailOrUsername;
  final String password;

  const AuthLoginRequested({
    required this.emailOrUsername,
    required this.password,
  });

  @override
  List<Object?> get props => [emailOrUsername, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String accountType;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.accountType,
  });

  @override
  List<Object?> get props => [username, email, password, fullName, accountType];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateFCMToken extends AuthEvent {
  final String fcmToken;

  const AuthUpdateFCMToken(this.fcmToken);

  @override
  List<Object?> get props => [fcmToken];
}