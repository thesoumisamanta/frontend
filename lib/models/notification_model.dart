import 'user_model.dart';

class NotificationModel {
  final String id;
  final String recipient;
  final UserModel sender;
  final String type;
  final String message;
  final String? post;
  final String? comment;
  final String? story;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    required this.message,
    this.post,
    this.comment,
    this.story,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      recipient: json['recipient'] ?? '',
      sender: UserModel.fromJson(json['sender']),
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      // FIXED: Handle both object and string formats
      post: _extractId(json['post']),
      comment: _extractId(json['comment']),
      story: _extractId(json['story']),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Helper method to extract ID from either string or object
  static String? _extractId(dynamic value) {
    if (value == null) return null;
    
    // If it's already a string, return it
    if (value is String) return value;
    
    // If it's an object/map, extract the _id field
    if (value is Map<String, dynamic>) {
      return value['_id'] as String?;
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient,
      'sender': sender.toJson(),
      'type': type,
      'message': message,
      'post': post,
      'comment': comment,
      'story': story,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getNotificationIcon() {
    switch (type) {
      case 'follow':
        return '👤';
      case 'like':
        return '❤️';
      case 'dislike':
        return '👎';
      case 'comment':
        return '💬';
      case 'reply':
        return '↩️';
      case 'mention':
        return '@';
      case 'share':
        return '🔄';
      case 'story_view':
        return '👁️';
      default:
        return '🔔';
    }
  }
}