import 'user_model.dart';

class CommentModel {
  final String id;
  final String post;
  final UserModel user;
  final String text;
  final String? parentComment;
  final int likesCount;
  final int dislikesCount;
  final int repliesCount;
  final DateTime createdAt;
  bool hasLiked;
  bool hasDisliked;

  CommentModel({
    required this.id,
    required this.post,
    required this.user,
    required this.text,
    this.parentComment,
    required this.likesCount,
    required this.dislikesCount,
    required this.repliesCount,
    required this.createdAt,
    this.hasLiked = false,
    this.hasDisliked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      post: json['post'] ?? '',
      user: UserModel.fromJson(json['user']),
      text: json['text'] ?? '',
      parentComment: json['parentComment'],
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      repliesCount: json['repliesCount'] ?? 0,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      hasLiked: json['hasLiked'] ?? false,
      hasDisliked: json['hasDisliked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'post': post,
      'user': user.toJson(),
      'text': text,
      'parentComment': parentComment,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'repliesCount': repliesCount,
      'createdAt': createdAt.toIso8601String(),
      'hasLiked': hasLiked,
      'hasDisliked': hasDisliked,
    };
  }
}