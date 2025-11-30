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
      post: json['post']?['_id'],
      comment: json['comment']?['_id'],
      story: json['story']?['_id'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
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