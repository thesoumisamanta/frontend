import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ApiService apiService;

  CommentBloc({required this.apiService}) : super(CommentInitial()) {
    on<CommentLoadPostComments>(_onCommentLoadPostComments);
    on<CommentLoadReplies>(_onCommentLoadReplies);
    on<CommentCreate>(_onCommentCreate);
    on<CommentUpdate>(_onCommentUpdate);
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

  Future<void> _onCommentUpdate(
    CommentUpdate event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final response = await apiService.updateComment(
        event.commentId,
        event.text,
      );

      if (response['success'] == true) {
        final currentState = state;
        
        if (currentState is CommentPostCommentsLoaded) {
          final updatedComments = _updateCommentInListById(
            currentState.comments,
            event.commentId,
            text: event.text,
            isEdited: true,
          );

          emit(currentState.copyWith(comments: updatedComments));
        }
        
        emit(const CommentActionSuccess('Comment updated successfully'));
      } else {
        emit(CommentError(response['message'] ?? 'Failed to update comment'));
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
          final updatedComments = _updateCommentCounts(
            currentState.comments,
            event.commentId,
            response,
          );
          emit(currentState.copyWith(comments: updatedComments));
        } else if (currentState is CommentRepliesLoaded) {
          final updatedReplies = _updateCommentCounts(
            currentState.replies,
            event.commentId,
            response,
          );
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
          final updatedComments = _updateCommentCounts(
            currentState.comments,
            event.commentId,
            response,
          );
          emit(currentState.copyWith(comments: updatedComments));
        } else if (currentState is CommentRepliesLoaded) {
          final updatedReplies = _updateCommentCounts(
            currentState.replies,
            event.commentId,
            response,
          );
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

  Future<void> _onCommentDelete(
    CommentDelete event,
    Emitter<CommentState> emit,
  ) async {
    try {
      final response = await apiService.deleteComment(event.commentId);

      if (response['success'] == true) {
        final currentState = state;
        
        if (currentState is CommentPostCommentsLoaded) {
          final updatedComments = _updateCommentInListById(
            currentState.comments,
            event.commentId,
            text: '[Deleted]',
            isDeleted: true,
          );

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

  // Helper method to update comment counts (likes/dislikes)
  List<CommentModel> _updateCommentCounts(
    List<CommentModel> comments,
    String commentId,
    Map<String, dynamic> response,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          likesCount: response['likesCount'],
          dislikesCount: response['dislikesCount'],
          hasLiked: response['hasLiked'],
          hasDisliked: response['hasDisliked'],
        );
      }
      return comment;
    }).toList();
  }

  // Helper method to update comment text/status
  List<CommentModel> _updateCommentInListById(
    List<CommentModel> comments,
    String commentId, {
    String? text,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          text: text,
          isEdited: isEdited,
          isDeleted: isDeleted,
        );
      }
      return comment;
    }).toList();
  }

  // Method to get comment likes (for showing users list)
  Future<List<UserModel>> getCommentLikes(String commentId) async {
    try {
      final response = await apiService.getCommentLikes(commentId);
      if (response['success'] == true) {
        final List<dynamic> usersJson = response['users'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Method to get comment dislikes (for showing users list)
  Future<List<UserModel>> getCommentDislikes(String commentId) async {
    try {
      final response = await apiService.getCommentDislikes(commentId);
      if (response['success'] == true) {
        final List<dynamic> usersJson = response['users'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}