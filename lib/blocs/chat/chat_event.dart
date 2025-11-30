import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatLoadChats extends ChatEvent {
  const ChatLoadChats();
}

class ChatGetOrCreate extends ChatEvent {
  final String userId;

  const ChatGetOrCreate(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ChatLoadMessages extends ChatEvent {
  final String chatId;
  final bool refresh;

  const ChatLoadMessages({
    required this.chatId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [chatId, refresh];
}

class ChatSendMessage extends ChatEvent {
  final String chatId;
  final String? text;
  final File? mediaFile;
  final String? sharedPostId;

  const ChatSendMessage({
    required this.chatId,
    this.text,
    this.mediaFile,
    this.sharedPostId,
  });

  @override
  List<Object?> get props => [chatId, text, mediaFile, sharedPostId];
}

class ChatMarkAsRead extends ChatEvent {
  final String chatId;

  const ChatMarkAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatAddMessage extends ChatEvent {
  final String chatId;
  final dynamic message;

  const ChatAddMessage({
    required this.chatId,
    required this.message,
  });

  @override
  List<Object?> get props => [chatId, message];
}