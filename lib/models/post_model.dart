import 'user_model.dart';

class PostModel {
  final String id;
  final UserModel user;
  final String caption;
  final String postType;
  final List<MediaItem> media;
  final String location;
  final List<String> tags;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isCommentEnabled;
  final DateTime createdAt;
  bool hasLiked;
  bool hasDisliked;

  PostModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.postType,
    required this.media,
    required this.location,
    required this.tags,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.isCommentEnabled,
    required this.createdAt,
    this.hasLiked = false,
    this.hasDisliked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['user']),
      caption: json['caption'] ?? '',
      postType: json['postType'] ?? 'image',
      media: (json['media'] as List?)
              ?.map((item) => MediaItem.fromJson(item))
              .toList() ??
          [],
      location: json['location'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      isCommentEnabled: json['isCommentEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      hasLiked: json['hasLiked'] ?? false,
      hasDisliked: json['hasDisliked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'caption': caption,
      'postType': postType,
      'media': media.map((item) => item.toJson()).toList(),
      'location': location,
      'tags': tags,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'isCommentEnabled': isCommentEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MediaItem {
  final String publicId;
  final String url;
  final String type;
  final String? thumbnail;
  final int? duration;

  MediaItem({
    required this.publicId,
    required this.url,
    required this.type,
    this.thumbnail,
    this.duration,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
      thumbnail: json['thumbnail'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
      'type': type,
      'thumbnail': thumbnail,
      'duration': duration,
    };
  }
}