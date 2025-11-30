import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiService apiService;

  ChatBloc({required this.apiService}) : super(ChatInitial()) {
    on<ChatLoadChats>(_onChatLoadChats);
    on<ChatGetOrCreate>(_onChatGetOrCreate);
    on<ChatLoadMessages>(_onChatLoadMessages);
    on<ChatSendMessage>(_onChatSendMessage);
    on<ChatMarkAsRead>(_onChatMarkAsRead);
    on<ChatAddMessage>(_onChatAddMessage);
  }

  Future<void> _onChatLoadChats(
    ChatLoadChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      final response = await apiService.getChats();

      if (response['success'] == true) {
        final List<dynamic> chatsJson = response['chats'];
        final chats = chatsJson
            .map((json) => ChatModel.fromJson(json))
            .toList();

        emit(ChatChatsLoaded(chats));
      } else {
        emit(ChatError(response['message'] ?? 'Failed to load chats'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onChatGetOrCreate(
    ChatGetOrCreate event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      final response = await apiService.getOrCreateChat(event.userId);

      if (response['success'] == true) {
        final chat = ChatModel.fromJson(response['chat']);
        emit(ChatLoaded(chat));
      } else {
        emit(ChatError(response['message'] ?? 'Failed to create chat'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onChatLoadMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(ChatLoading());
      }

      final currentState = state;
      int page = 1;
      List<MessageModel> currentMessages = [];

      if (currentState is ChatMessagesLoaded && 
          currentState.chatId == event.chatId && 
          !event.refresh) {
        page = currentState.currentPage + 1;
        currentMessages = currentState.messages;
      }

      final response = await apiService.getMessages(
        event.chatId,
        page: page,
        limit: 50,
      );

      if (response['success'] == true) {
        final List<dynamic> messagesJson = response['messages'];
        final newMessages = messagesJson
            .map((json) => MessageModel.fromJson(json))
            .toList();

        final allMessages = event.refresh 
            ? newMessages 
            : [...newMessages, ...currentMessages];
        final hasMore = page < response['totalPages'];

        emit(ChatMessagesLoaded(
          chatId: event.chatId,
          messages: allMessages,
          hasMore: hasMore,
          currentPage: page,
        ));
      } else {
        emit(ChatError(response['message'] ?? 'Failed to load messages'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onChatSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state;
      emit(ChatMessageSending());

      final response = await apiService.sendMessage(
        chatId: event.chatId,
        text: event.text,
        mediaFile: event.mediaFile,
        sharedPostId: event.sharedPostId,
      );

      if (response['success'] == true) {
        final message = MessageModel.fromJson(response['message']);
        
        // Add the new message to the current state
        if (currentState is ChatMessagesLoaded && 
            currentState.chatId == event.chatId) {
          final updatedMessages = [...currentState.messages, message];
          emit(currentState.copyWith(messages: updatedMessages));
        } else {
          emit(ChatMessageSent(message));
        }
      } else {
        emit(ChatError(response['message'] ?? 'Failed to send message'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onChatMarkAsRead(
    ChatMarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await apiService.markMessagesAsRead(event.chatId);
      emit(ChatMarkedAsRead(event.chatId));
    } catch (e) {
      // Silently fail
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _onChatAddMessage(
    ChatAddMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is ChatMessagesLoaded && 
        currentState.chatId == event.chatId) {
      final message = MessageModel.fromJson(event.message);
      final updatedMessages = [...currentState.messages, message];
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }
}