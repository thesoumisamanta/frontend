import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostLoadFeed extends PostEvent {
  final bool refresh;

  const PostLoadFeed({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class PostLoadUserPosts extends PostEvent {
  final String userId;
  final String? postType;
  final bool refresh;

  const PostLoadUserPosts({
    required this.userId,
    this.postType,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [userId, postType, refresh];
}

class PostCreate extends PostEvent {
  final String caption;
  final String postType;
  final List<File> mediaFiles;
  final String? location;
  final List<String>? tags;

  const PostCreate({
    required this.caption,
    required this.postType,
    required this.mediaFiles,
    this.location,
    this.tags,
  });

  @override
  List<Object?> get props => [caption, postType, mediaFiles, location, tags];
}

class PostLike extends PostEvent {
  final String postId;

  const PostLike(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostDislike extends PostEvent {
  final String postId;

  const PostDislike(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostDelete extends PostEvent {
  final String postId;

  const PostDelete(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostShare extends PostEvent {
  final String postId;

  const PostShare(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostLoadSingle extends PostEvent {
  final String postId;

  const PostLoadSingle(this.postId);

  @override
  List<Object?> get props => [postId];
}