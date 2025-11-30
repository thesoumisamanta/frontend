import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/user_model.dart';
import '../../models/story_model.dart';
import '../../services/api_service.dart';
import 'story_event.dart';
import 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final ApiService apiService;

  StoryBloc({required this.apiService}) : super(StoryInitial()) {
    on<StoryLoadFollowing>(_onStoryLoadFollowing);
    on<StoryLoadUser>(_onStoryLoadUser);
    on<StoryCreate>(_onStoryCreate);
    on<StoryView>(_onStoryView);
    on<StoryDelete>(_onStoryDelete);
  }

  Future<void> _onStoryLoadFollowing(
    StoryLoadFollowing event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(StoryLoading());

      final response = await apiService.getFollowingStories();

      if (response['success'] == true) {
        final List<dynamic> storiesJson = response['stories'];

        // Parse story groups
        final storyGroups = storiesJson.map((groupJson) {
          final user = UserModel.fromJson(groupJson['user']);
          final stories = (groupJson['stories'] as List)
              .map((storyJson) => StoryModel.fromJson(storyJson))
              .toList();

          return StoryGroup(user: user, stories: stories);
        }).toList();

        emit(StoryFollowingLoaded(storyGroups));
      } else {
        emit(StoryError(response['message'] ?? 'Failed to load stories'));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onStoryLoadUser(
    StoryLoadUser event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(StoryLoading());

      final response = await apiService.getUserStories(event.userId);

      if (response['success'] == true) {
        final List<dynamic> storiesJson = response['stories'];
        final stories = storiesJson
            .map((json) => StoryModel.fromJson(json))
            .toList();

        emit(StoryUserLoaded(stories));
      } else {
        emit(StoryError(response['message'] ?? 'Failed to load user stories'));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onStoryCreate(
    StoryCreate event,
    Emitter<StoryState> emit,
  ) async {
    try {
      emit(StoryCreating());

      final response = await apiService.createStory(
        mediaFile: event.mediaFile,
        caption: event.caption,
      );

      if (response['success'] == true) {
        final story = StoryModel.fromJson(response['story']);
        emit(StoryCreated(story));
      } else {
        emit(StoryError(response['message'] ?? 'Failed to create story'));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }

  Future<void> _onStoryView(StoryView event, Emitter<StoryState> emit) async {
    try {
      await apiService.viewStory(event.storyId);
      emit(StoryViewed(event.storyId));
    } catch (e) {
      // Silently fail for story views
      print('Error viewing story: $e');
    }
  }

  Future<void> _onStoryDelete(
    StoryDelete event,
    Emitter<StoryState> emit,
  ) async {
    try {
      final response = await apiService.deleteStory(event.storyId);

      if (response['success'] == true) {
        emit(StoryDeleted(response['message'] ?? 'Story deleted'));
      } else {
        emit(StoryError(response['message'] ?? 'Failed to delete story'));
      }
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }
}
