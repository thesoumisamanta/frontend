import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user_model.dart';
import '../../services/api_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService apiService;

  UserBloc({required this.apiService}) : super(UserInitial()) {
    on<UserLoadProfile>(_onUserLoadProfile);
    on<UserUpdateProfile>(_onUserUpdateProfile);
    on<UserFollowToggle>(_onUserFollowToggle);
    on<UserSearchUsers>(_onUserSearchUsers);
    on<UserLoadFollowers>(_onUserLoadFollowers);
    on<UserLoadFollowing>(_onUserLoadFollowing);
  }

  Future<void> _onUserLoadProfile(
    UserLoadProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      final response = await apiService.getUserProfile(event.userId);

      if (response['success'] == true) {
        final user = UserModel.fromJson(response['user']);
        final isFollowing = response['isFollowing'] ?? false;

        emit(UserProfileLoaded(user: user, isFollowing: isFollowing));
      } else {
        emit(UserError(response['message'] ?? 'Failed to load profile'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  // blocs/user/user_bloc.dart
  Future<void> _onUserUpdateProfile(
    UserUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      // If there are images to upload, use the appropriate API method
      if (event.profileImage != null || event.coverImage != null) {
        final response = await apiService.updateProfileWithImages(
          data: event.data,
          profileImage: event.profileImage,
          coverImage: event.coverImage,
        );

        if (response['success'] == true) {
          final user = UserModel.fromJson(response['user']);
          emit(UserProfileUpdated(user));
        } else {
          emit(UserError(response['message'] ?? 'Failed to update profile'));
        }
      } else {
        // No images, just update data
        final response = await apiService.updateProfile(event.data);

        if (response['success'] == true) {
          final user = UserModel.fromJson(response['user']);
          emit(UserProfileUpdated(user));
        } else {
          emit(UserError(response['message'] ?? 'Failed to update profile'));
        }
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserFollowToggle(
    UserFollowToggle event,
    Emitter<UserState> emit,
  ) async {
    try {
      final currentState = state;

      // Early exit if not viewing this profile
      if (currentState is! UserProfileLoaded ||
          currentState.user.id != event.userId) {
        // Still make the API call
        final response = await apiService.followUnfollowUser(event.userId);
        if (response['success'] == true) {
          emit(UserActionSuccess(response['message']));
        }
        return;
      }

      // Store original state for rollback
      final originalUser = currentState.user;
      final originalIsFollowing = currentState.isFollowing;

      // Optimistically update UI immediately
      final newFollowersCount = originalIsFollowing
          ? originalUser.followersCount -
                1 // Unfollowing
          : originalUser.followersCount + 1; // Following

      final updatedUser = originalUser.copyWith(
        followersCount: newFollowersCount,
      );

      emit(
        UserProfileLoaded(user: updatedUser, isFollowing: !originalIsFollowing),
      );

      // Make API call
      try {
        final response = await apiService.followUnfollowUser(event.userId);

        if (response['success'] != true) {
          // Rollback on failure
          emit(
            UserProfileLoaded(
              user: originalUser,
              isFollowing: originalIsFollowing,
            ),
          );
          emit(UserError(response['message'] ?? 'Failed to follow/unfollow'));
        }
        // Success - UI already updated optimistically
      } catch (apiError) {
        // Rollback on error
        emit(
          UserProfileLoaded(
            user: originalUser,
            isFollowing: originalIsFollowing,
          ),
        );
        rethrow;
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserSearchUsers(
    UserSearchUsers event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(const UserSearchResults([]));
        return;
      }

      emit(UserLoading());

      final response = await apiService.searchUsers(event.query);

      if (response['success'] == true) {
        final List<dynamic> usersJson = response['users'];
        final users = usersJson
            .map((json) => UserModel.fromJson(json))
            .toList();

        emit(UserSearchResults(users));
      } else {
        emit(UserError(response['message'] ?? 'Search failed'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserLoadFollowers(
    UserLoadFollowers event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      final response = await apiService.getFollowers(event.userId);

      if (response['success'] == true) {
        final List<dynamic> followersJson = response['followers'];
        final followers = followersJson
            .map((json) => UserModel.fromJson(json))
            .toList();

        emit(UserFollowersLoaded(followers));
      } else {
        emit(UserError(response['message'] ?? 'Failed to load followers'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserLoadFollowing(
    UserLoadFollowing event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      final response = await apiService.getFollowing(event.userId);

      if (response['success'] == true) {
        final List<dynamic> followingJson = response['following'];
        final following = followingJson
            .map((json) => UserModel.fromJson(json))
            .toList();

        emit(UserFollowingLoaded(following));
      } else {
        emit(UserError(response['message'] ?? 'Failed to load following'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
