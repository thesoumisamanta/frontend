import 'package:equatable/equatable.dart';
import 'package:frontend/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final UserModel user;
  final bool isFollowing;
  final bool followsBack;

  const UserProfileLoaded({
    required this.user,
    required this.isFollowing,
    this.followsBack = false,
  });

  @override
  List<Object?> get props => [user, isFollowing, followsBack];

  UserProfileLoaded copyWith({
    UserModel? user,
    bool? isFollowing,
    bool? followsBack,
  }) {
    return UserProfileLoaded(
      user: user ?? this.user,
      isFollowing: isFollowing ?? this.isFollowing,
      followsBack: followsBack ?? this.followsBack,
    );
  }
}

class UserProfileUpdated extends UserState {
  final UserModel user;

  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class UserSearchResults extends UserState {
  final List<UserModel> users;

  const UserSearchResults(this.users);

  @override
  List<Object?> get props => [users];
}

class UserFollowersLoaded extends UserState {
  final List<UserModel> followers;

  const UserFollowersLoaded(this.followers);

  @override
  List<Object?> get props => [followers];
}

class UserFollowingLoaded extends UserState {
  final List<UserModel> following;

  const UserFollowingLoaded(this.following);

  @override
  List<Object?> get props => [following];
}

class UserActionSuccess extends UserState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
