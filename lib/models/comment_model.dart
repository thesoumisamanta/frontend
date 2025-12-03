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
  final int depth;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
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
    this.depth = 0,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
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
      depth: json['depth'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
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
      'depth': depth,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasLiked': hasLiked,
      'hasDisliked': hasDisliked,
    };
  }

  CommentModel copyWith({
    String? id,
    String? post,
    UserModel? user,
    String? text,
    String? parentComment,
    int? likesCount,
    int? dislikesCount,
    int? repliesCount,
    int? depth,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasLiked,
    bool? hasDisliked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      post: post ?? this.post,
      user: user ?? this.user,
      text: text ?? this.text,
      parentComment: parentComment ?? this.parentComment,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      depth: depth ?? this.depth,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasLiked: hasLiked ?? this.hasLiked,
      hasDisliked: hasDisliked ?? this.hasDisliked,
    );
  }
}