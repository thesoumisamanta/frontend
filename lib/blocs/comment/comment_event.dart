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
  final bool refresh;

  const CommentLoadReplies(
    this.commentId, {
    this.refresh = false,
  });

  @override
  List<Object?> get props => [commentId, refresh];
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

class CommentUpdate extends CommentEvent {
  final String commentId;
  final String text;

  const CommentUpdate(this.commentId, this.text);

  @override
  List<Object?> get props => [commentId, text];
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

class CommentLoadLikes extends CommentEvent {
  final String commentId;

  const CommentLoadLikes(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentLoadDislikes extends CommentEvent {
  final String commentId;

  const CommentLoadDislikes(this.commentId);

  @override
  List<Object?> get props => [commentId];
}