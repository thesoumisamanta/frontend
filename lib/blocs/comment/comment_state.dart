import 'package:equatable/equatable.dart';
import '../../models/comment_model.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentPostCommentsLoaded extends CommentState {
  final String postId;
  final List<CommentModel> comments;
  final bool hasMore;
  final int currentPage;

  const CommentPostCommentsLoaded({
    required this.postId,
    required this.comments,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [postId, comments, hasMore, currentPage];

  CommentPostCommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? hasMore,
    int? currentPage,
  }) {
    return CommentPostCommentsLoaded(
      postId: postId,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class CommentRepliesLoaded extends CommentState {
  final String commentId;
  final List<CommentModel> replies;

  const CommentRepliesLoaded({
    required this.commentId,
    required this.replies,
  });

  @override
  List<Object?> get props => [commentId, replies];
}

class CommentCreating extends CommentState {}

class CommentCreated extends CommentState {
  final CommentModel comment;

  const CommentCreated(this.comment);

  @override
  List<Object?> get props => [comment];
}

class CommentActionSuccess extends CommentState {
  final String message;

  const CommentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}