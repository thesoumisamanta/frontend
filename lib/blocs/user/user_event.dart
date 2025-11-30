import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoadProfile extends UserEvent {
  final String userId;

  const UserLoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserUpdateProfile extends UserEvent {
  final Map<String, dynamic> data;

  const UserUpdateProfile(this.data);

  @override
  List<Object?> get props => [data];
}

class UserFollowToggle extends UserEvent {
  final String userId;

  const UserFollowToggle(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserSearchUsers extends UserEvent {
  final String query;

  const UserSearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class UserLoadFollowers extends UserEvent {
  final String userId;

  const UserLoadFollowers(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserLoadFollowing extends UserEvent {
  final String userId;

  const UserLoadFollowing(this.userId);

  @override
  List<Object?> get props => [userId];
}