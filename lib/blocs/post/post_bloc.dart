import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final ApiService apiService;

  PostBloc({required this.apiService}) : super(PostInitial()) {
    on<PostLoadFeed>(_onPostLoadFeed);
    on<PostLoadUserPosts>(_onPostLoadUserPosts);
    on<PostCreate>(_onPostCreate);
    on<PostLike>(_onPostLike);
    on<PostDislike>(_onPostDislike);
    on<PostDelete>(_onPostDelete);
    on<PostShare>(_onPostShare);
    on<PostLoadSingle>(_onPostLoadSingle);
  }

  Future<void> _onPostLoadFeed(
    PostLoadFeed event,
    Emitter<PostState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(PostLoading());
      }

      final currentState = state;
      int page = 1;
      List<PostModel> currentPosts = [];

      if (currentState is PostFeedLoaded && !event.refresh) {
        page = currentState.currentPage + 1;
        currentPosts = currentState.posts;
      }

      final response = await apiService.getFeed(
        page: page,
        limit: AppConstants.postsPerPage,
      );

      if (response['success'] == true) {
        final List<dynamic> postsJson = response['posts'];
        final newPosts = postsJson
            .map((json) => PostModel.fromJson(json))
            .toList();

        final allPosts = event.refresh
            ? newPosts
            : [...currentPosts, ...newPosts];
        final hasMore = page < response['totalPages'];

        emit(
          PostFeedLoaded(posts: allPosts, hasMore: hasMore, currentPage: page),
        );
      } else {
        emit(PostError(response['message'] ?? 'Failed to load posts'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostLoadUserPosts(
    PostLoadUserPosts event,
    Emitter<PostState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(PostLoading());
      }

      final currentState = state;
      int page = 1;
      List<PostModel> currentPosts = [];

      if (currentState is PostUserPostsLoaded && !event.refresh) {
        page = currentState.currentPage + 1;
        currentPosts = currentState.posts;
      }

      final response = await apiService.getUserPosts(
        event.userId,
        page: page,
        limit: 12,
        postType: event.postType,
      );

      if (response['success'] == true) {
        final List<dynamic> postsJson = response['posts'];
        final newPosts = postsJson
            .map((json) => PostModel.fromJson(json))
            .toList();

        final allPosts = event.refresh
            ? newPosts
            : [...currentPosts, ...newPosts];
        final hasMore = page < response['totalPages'];

        emit(
          PostUserPostsLoaded(
            posts: allPosts,
            hasMore: hasMore,
            currentPage: page,
            userId: event.userId,
          ),
        );
      } else {
        emit(PostError(response['message'] ?? 'Failed to load user posts'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostCreate(PostCreate event, Emitter<PostState> emit) async {
    try {
      emit(PostCreating());

      final response = await apiService.createPost(
        caption: event.caption,
        postType: event.postType,
        mediaFiles: event.mediaFiles,
        location: event.location,
        tags: event.tags,
      );

      if (response['success'] == true) {
        final post = PostModel.fromJson(response['post']);
        emit(PostCreated(post));
      } else {
        emit(PostError(response['message'] ?? 'Failed to create post'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostLike(PostLike event, Emitter<PostState> emit) async {
    try {
      final response = await apiService.likePost(event.postId);

      if (response['success'] == true) {
        // Update the post in the current state
        final currentState = state;
        if (currentState is PostFeedLoaded) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return PostModel(
                id: post.id,
                user: post.user,
                caption: post.caption,
                postType: post.postType,
                media: post.media,
                location: post.location,
                tags: post.tags,
                likesCount: response['likesCount'],
                dislikesCount: response['dislikesCount'],
                commentsCount: post.commentsCount,
                sharesCount: post.sharesCount,
                viewsCount: post.viewsCount,
                isCommentEnabled: post.isCommentEnabled,
                createdAt: post.createdAt,
                hasLiked: response['hasLiked'],
                hasDisliked: response['hasDisliked'],
              );
            }
            return post;
          }).toList();

          emit(currentState.copyWith(posts: updatedPosts));
        }
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostDislike(
    PostDislike event,
    Emitter<PostState> emit,
  ) async {
    try {
      final response = await apiService.dislikePost(event.postId);

      if (response['success'] == true) {
        final currentState = state;
        if (currentState is PostFeedLoaded) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return PostModel(
                id: post.id,
                user: post.user,
                caption: post.caption,
                postType: post.postType,
                media: post.media,
                location: post.location,
                tags: post.tags,
                likesCount: response['likesCount'],
                dislikesCount: response['dislikesCount'],
                commentsCount: post.commentsCount,
                sharesCount: post.sharesCount,
                viewsCount: post.viewsCount,
                isCommentEnabled: post.isCommentEnabled,
                createdAt: post.createdAt,
                hasLiked: response['hasLiked'],
                hasDisliked: response['hasDisliked'],
              );
            }
            return post;
          }).toList();

          emit(currentState.copyWith(posts: updatedPosts));
        }
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostDelete(PostDelete event, Emitter<PostState> emit) async {
    try {
      final response = await apiService.deletePost(event.postId);

      if (response['success'] == true) {
        final currentState = state;
        if (currentState is PostFeedLoaded) {
          final updatedPosts = currentState.posts
              .where((post) => post.id != event.postId)
              .toList();

          emit(currentState.copyWith(posts: updatedPosts));
        } else if (currentState is PostUserPostsLoaded) {
          final updatedPosts = currentState.posts
              .where((post) => post.id != event.postId)
              .toList();

          emit(currentState.copyWith(posts: updatedPosts));
        }

        emit(PostActionSuccess('Post deleted successfully'));
      } else {
        emit(PostError(response['message'] ?? 'Failed to delete post'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostShare(PostShare event, Emitter<PostState> emit) async {
    try {
      final response = await apiService.sharePost(event.postId);

      if (response['success'] == true) {
        emit(PostActionSuccess('Post shared successfully'));
      } else {
        emit(PostError(response['message'] ?? 'Failed to share post'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> _onPostLoadSingle(
    PostLoadSingle event,
    Emitter<PostState> emit,
  ) async {
    try {
      emit(PostLoading());

      final response = await apiService.getPost(event.postId);

      if (response['success'] == true) {
        final post = PostModel.fromJson(response['post']);
        emit(PostSingleLoaded(post));
      } else {
        emit(PostError(response['message'] ?? 'Failed to load post'));
      }
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}
