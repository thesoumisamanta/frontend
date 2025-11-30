import 'package:equatable/equatable.dart';
import '../../models/post_model.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostFeedLoaded extends PostState {
  final List<PostModel> posts;
  final bool hasMore;
  final int currentPage;

  const PostFeedLoaded({
    required this.posts,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [posts, hasMore, currentPage];

  PostFeedLoaded copyWith({
    List<PostModel>? posts,
    bool? hasMore,
    int? currentPage,
  }) {
    return PostFeedLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PostUserPostsLoaded extends PostState {
  final List<PostModel> posts;
  final bool hasMore;
  final int currentPage;
  final String userId;

  const PostUserPostsLoaded({
    required this.posts,
    required this.hasMore,
    required this.currentPage,
    required this.userId,
  });

  @override
  List<Object?> get props => [posts, hasMore, currentPage, userId];

  PostUserPostsLoaded copyWith({
    List<PostModel>? posts,
    bool? hasMore,
    int? currentPage,
  }) {
    return PostUserPostsLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      userId: userId,
    );
  }
}

class PostCreating extends PostState {}

class PostCreated extends PostState {
  final PostModel post;

  const PostCreated(this.post);

  @override
  List<Object?> get props => [post];
}

class PostActionSuccess extends PostState {
  final String message;

  const PostActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostSingleLoaded extends PostState {
  final PostModel post;

  const PostSingleLoaded(this.post);

  @override
  List<Object?> get props => [post];
}