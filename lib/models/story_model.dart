import 'user_model.dart';

class StoryModel {
  final String id;
  final UserModel user;
  final StoryMedia media;
  final String caption;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool hasViewed;

  StoryModel({
    required this.id,
    required this.user,
    required this.media,
    required this.caption,
    required this.viewsCount,
    required this.createdAt,
    required this.expiresAt,
    this.hasViewed = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['user']),
      media: StoryMedia.fromJson(json['media']),
      caption: json['caption'] ?? '',
      viewsCount: json['viewsCount'] ?? 0,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(
          json['expiresAt'] ?? DateTime.now().toIso8601String()),
      hasViewed: json['hasViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'media': media.toJson(),
      'caption': caption,
      'viewsCount': viewsCount,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'hasViewed': hasViewed,
    };
  }
}

class StoryMedia {
  final String publicId;
  final String url;
  final String type;
  final String? thumbnail;
  final int? duration;

  StoryMedia({
    required this.publicId,
    required this.url,
    required this.type,
    this.thumbnail,
    this.duration,
  });

  factory StoryMedia.fromJson(Map<String, dynamic> json) {
    return StoryMedia(
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

class StoryGroup {
  final UserModel user;
  final List<StoryModel> stories;

  StoryGroup({
    required this.user,
    required this.stories,
  });

  bool get hasUnviewed => stories.any((story) => !story.hasViewed);
}