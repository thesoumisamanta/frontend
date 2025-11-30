import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class CommentLoadPostComments extends CommentEvent {
  final String postId;
  final bool refresh;

  const CommentLoadPostComments({
    required this.postId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [postId, refresh];
}

class CommentLoadReplies extends CommentEvent {
  final String commentId;

  const CommentLoadReplies(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentCreate extends CommentEvent {
  final String postId;
  final String text;
  final String? parentCommentId;

  const CommentCreate({
    required this.postId,
    required this.text,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, text, parentCommentId];
}

class CommentLike extends CommentEvent {
  final String commentId;

  const CommentLike(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentDislike extends CommentEvent {
  final String commentId;

  const CommentDislike(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentDelete extends CommentEvent {
  final String commentId;

  const CommentDelete(this.commentId);

  @override
  List<Object?> get props => [commentId];
}