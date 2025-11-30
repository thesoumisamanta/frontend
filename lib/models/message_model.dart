import 'user_model.dart';
import 'post_model.dart';

class MessageModel {
  final String id;
  final String chat;
  final UserModel sender;
  final String messageType;
  final String? text;
  final MessageMedia? media;
  final PostModel? sharedPost;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chat,
    required this.sender,
    required this.messageType,
    this.text,
    this.media,
    this.sharedPost,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      chat: json['chat'] ?? '',
      sender: UserModel.fromJson(json['sender']),
      messageType: json['messageType'] ?? 'text',
      text: json['text'],
      media: json['media'] != null
          ? MessageMedia.fromJson(json['media'])
          : null,
      sharedPost: json['sharedPost'] != null
          ? PostModel.fromJson(json['sharedPost'])
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat': chat,
      'sender': sender.toJson(),
      'messageType': messageType,
      'text': text,
      'media': media?.toJson(),
      'sharedPost': sharedPost?.toJson(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool isMine(String currentUserId) {
    return sender.id == currentUserId;
  }
}

class MessageMedia {
  final String publicId;
  final String url;
  final String type;

  MessageMedia({
    required this.publicId,
    required this.url,
    required this.type,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) {
    return MessageMedia(
      publicId: json['public_id'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'url': url,
      'type': type,
    };
  }
}