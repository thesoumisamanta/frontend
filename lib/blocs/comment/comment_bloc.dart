import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/comment_model.dart';
import '../../services/api_service.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ApiService apiService;

  CommentBloc({required this.apiService}) : super(CommentInitial()) {
    on<CommentLoadPostComments>(_onCommentLoadPostComments);
    on<CommentLoadReplies>(_onCommentLoadReplies);
    on<CommentCreate>(_onCommentCreate);
    on<CommentLike>(_onCommentLike);
    on<CommentDislike>(_onCommentDislike);
    on<CommentDelete>(_onCommentDelete);
  }

  Future<void> _onCommentLoadPostComments(
    CommentLoadPostComments event,
    Emitter<CommentState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(CommentLoading());
      }

      final currentState = state;
      int page = 1;
      List<CommentModel> currentComments = [];

      if (currentState is CommentPostCommentsLoaded &&
          currentState.postId == event.postId &&
          !event.refresh) {
        page = currentState.currentPage + 1;
        currentComments = currentState.comments;
      }

      final response = await apiService.getPostComments(
        event.postId,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> commentsJson = response['comments'];
        final newComments = commentsJson
            .map((json) => CommentModel.fromJson(json))
            .toList();

        final allComments = event.refresh
            ? newComments
            : [...currentComments, ...newComments];
        final hasMore = page < response['totalPages'];

        emit(CommentPostCommentsLoaded(
          postId: event.postId,
          comments: allComments,
          hasMore: hasMore,
          currentPage: page,
        ));
      } else {
        emit(CommentError(response['message'] ?? 'Failed to load comments'));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentLoadReplies(
    CommentLoadReplies event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentLoading());

      final response = await apiService.getCommentReplies(event.commentId);

      if (response['success'] == true) {
        final List<dynamic> repliesJson = response['replies'];
        final replies = repliesJson
            .map((json) => CommentModel.fromJson(json))
            .toList();

        emit(CommentRepliesLoaded(
          commentId: event.commentId,
          replies: replies,
        ));
      } else {
        emit(CommentError(response['message'] ?? 'Failed to load replies'));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentCreate(
    CommentCreate event,
    Emitter<CommentState> emit,
  ) async {
    try {
      emit(CommentCreating());

      final response = await apiService.createComment(
        postId: event.postId,
        text: event.text,
        parentCommentId: event.parentCommentId,
      );

      if (response['success'] == true) {
        final comment = CommentModel.fromJson(response['comment']);
        emit(CommentCreated(comment));
      } else {
        emit(CommentError(response['message'] ?? 'Failed to create comment'));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentLike(
    CommentLike event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final response = await apiService.likeComment(event.commentId);

      if (response['success'] == true) {
        final currentState = state;
        
        if (currentState is CommentPostCommentsLoaded) {
          final updatedComments = currentState.comments.map((comment) {
            if (comment.id == event.commentId) {
              return CommentModel(
                id: comment.id,
                post: comment.post,
                user: comment.user,
                text: comment.text,
                parentComment: comment.parentComment,
                likesCount: response['likesCount'],
                dislikesCount: response['dislikesCount'],
                repliesCount: comment.repliesCount,
                createdAt: comment.createdAt,
                hasLiked: response['hasLiked'],
                hasDisliked: response['hasDisliked'],
              );
            }
            return comment;
          }).toList();

          emit(currentState.copyWith(comments: updatedComments));
        } else if (currentState is CommentRepliesLoaded) {
          final updatedReplies = currentState.replies.map((comment) {
            if (comment.id == event.commentId) {
              return CommentModel(
                id: comment.id,
                post: comment.post,
                user: comment.user,
                text: comment.text,
                parentComment: comment.parentComment,
                likesCount: response['likesCount'],
                dislikesCount: response['dislikesCount'],
                repliesCount: comment.repliesCount,
                createdAt: comment.createdAt,
                hasLiked: response['hasLiked'],
                hasDisliked: response['hasDisliked'],
              );
            }
            return comment;
          }).toList();

          emit(CommentRepliesLoaded(
            commentId: currentState.commentId,
            replies: updatedReplies,
          ));
        }
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentDislike(
    CommentDislike event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final response = await apiService.dislikeComment(event.commentId);

      if (response['success'] == true) {
        final currentState = state;
        
        if (currentState is CommentPostCommentsLoaded) {
          final updatedComments = currentState.comments.map((comment) {
            if (comment.id == event.commentId) {
              return CommentModel(
                id: comment.id,
                post: comment.post,
                user: comment.user,
                text: comment.text,
                parentComment: comment.parentComment,
                likesCount: response['likesCount'],
                dislikesCount: response['dislikesCount'],
                repliesCount: comment.repliesCount,
                createdAt: comment.createdAt,
                hasLiked: response['hasLiked'],
                hasDisliked: response['hasDisliked'],
              );
            }
            return comment;
          }).toList();

          emit(currentState.copyWith(comments: updatedComments));
        }
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onCommentDelete(
    CommentDelete event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final response = await apiService.deleteComment(event.commentId);

      if (response['success'] == true) {
        final currentState = state;
        
        if (currentState is CommentPostCommentsLoaded) {
          final updatedComments = currentState.comments
              .where((comment) => comment.id != event.commentId)
              .toList();

          emit(currentState.copyWith(comments: updatedComments));
        }

        emit(const CommentActionSuccess('Comment deleted successfully'));
      } else {
        emit(CommentError(response['message'] ?? 'Failed to delete comment'));
      }
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }
}