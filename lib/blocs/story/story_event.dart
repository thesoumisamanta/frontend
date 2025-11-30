import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class StoryLoadFollowing extends StoryEvent {
  const StoryLoadFollowing();
}

class StoryLoadUser extends StoryEvent {
  final String userId;

  const StoryLoadUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StoryCreate extends StoryEvent {
  final File mediaFile;
  final String? caption;

  const StoryCreate({
    required this.mediaFile,
    this.caption,
  });

  @override
  List<Object?> get props => [mediaFile, caption];
}

class StoryView extends StoryEvent {
  final String storyId;

  const StoryView(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class StoryDelete extends StoryEvent {
  final String storyId;

  const StoryDelete(this.storyId);

  @override
  List<Object?> get props => [storyId];
}