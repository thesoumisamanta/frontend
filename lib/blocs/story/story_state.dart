import 'package:equatable/equatable.dart';
import '../../models/story_model.dart';

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryFollowingLoaded extends StoryState {
  final List<StoryGroup> storyGroups;

  const StoryFollowingLoaded(this.storyGroups);

  @override
  List<Object?> get props => [storyGroups];
}

class StoryUserLoaded extends StoryState {
  final List<StoryModel> stories;

  const StoryUserLoaded(this.stories);

  @override
  List<Object?> get props => [stories];
}

class StoryCreating extends StoryState {}

class StoryCreated extends StoryState {
  final StoryModel story;

  const StoryCreated(this.story);

  @override
  List<Object?> get props => [story];
}

class StoryViewed extends StoryState {
  final String storyId;

  const StoryViewed(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class StoryDeleted extends StoryState {
  final String message;

  const StoryDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class StoryError extends StoryState {
  final String message;

  const StoryError(this.message);

  @override
  List<Object?> get props => [message];
}