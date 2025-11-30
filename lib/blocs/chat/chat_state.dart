import 'package:equatable/equatable.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatChatsLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatLoaded extends ChatState {
  final ChatModel chat;

  const ChatLoaded(this.chat);

  @override
  List<Object?> get props => [chat];
}

class ChatMessagesLoaded extends ChatState {
  final String chatId;
  final List<MessageModel> messages;
  final bool hasMore;
  final int currentPage;

  const ChatMessagesLoaded({
    required this.chatId,
    required this.messages,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [chatId, messages, hasMore, currentPage];

  ChatMessagesLoaded copyWith({
    List<MessageModel>? messages,
    bool? hasMore,
    int? currentPage,
  }) {
    return ChatMessagesLoaded(
      chatId: chatId,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ChatMessageSending extends ChatState {}

class ChatMessageSent extends ChatState {
  final MessageModel message;

  const ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMarkedAsRead extends ChatState {
  final String chatId;

  const ChatMarkedAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}