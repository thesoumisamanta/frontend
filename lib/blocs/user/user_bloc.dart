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

  UserProfileLoaded? _lastProfileLoadedState;

  Future<void> _onUserLoadProfile(
    UserLoadProfile event,
    Emitter<UserState> emit,
  ) async {
    try {
      // If we already have this user cached, show it immediately
      if (_lastProfileLoadedState != null &&
          _lastProfileLoadedState!.user.id == event.userId) {
        emit(_lastProfileLoadedState!);
      }

      // If we are already currently showing this user in the active state,
      // don't emit loading.
      final currentState = state;
      bool isRefreshing = false;

      if (currentState is UserProfileLoaded &&
          currentState.user.id == event.userId) {
        // We are already showing this user. Do NOT emit UserLoading.
        isRefreshing = true;
      } else if (_lastProfileLoadedState == null ||
          _lastProfileLoadedState!.user.id != event.userId) {
        // Only emit loading if we didn't just restore from cache above
        emit(UserLoading());
      }

      final response = await apiService.getUserProfile(event.userId);

      if (response['success'] == true) {
        final user = UserModel.fromJson(response['user']);
        final isFollowing = response['isFollowing'] ?? false;

        final newState = UserProfileLoaded(
          user: user,
          isFollowing: isFollowing,
        );
        _lastProfileLoadedState = newState; // Update cache
        emit(newState);
      } else {
        // If we were refreshing, we might not want to replace the whole screen with an error
        // effectively hiding valuable content.
        if (isRefreshing ||
            (_lastProfileLoadedState != null &&
                _lastProfileLoadedState!.user.id == event.userId)) {
          // Maybe emit a side-effect or just ignore?
          // For now, if we fail to refresh, we just stay in Loaded state.
          // We could add a "toast" event, but that requires state change.
          // Let's just NOT emit Error if we have data.
          // Or print to log.
          print('Failed to refresh profile: ${response['message']}');
        } else {
          emit(UserError(response['message'] ?? 'Failed to load profile'));
        }
      }
    } catch (e) {
      if ((state is UserProfileLoaded &&
              (state as UserProfileLoaded).user.id == event.userId) ||
          (_lastProfileLoadedState != null &&
              _lastProfileLoadedState!.user.id == event.userId)) {
        print('Error refreshing profile: $e');
      } else {
        emit(UserError(e.toString()));
      }
    }
  }

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
      // Only show loading if we don't already have followers loaded
      if (state is! UserFollowersLoaded) {
        emit(UserLoading());
      }

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
      // Only show loading if we don't already have following loaded
      if (state is! UserFollowingLoaded) {
        emit(UserLoading());
      }

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
