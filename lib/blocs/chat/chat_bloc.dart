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

  List<ChatModel> _chatsCache = [];

  Future<void> _onChatLoadChats(
    ChatLoadChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // If we have cached chats, show them immediately
      if (_chatsCache.isNotEmpty) {
        emit(ChatChatsLoaded(_chatsCache));
      } else {
        // Only show loading if we don't have cache
        emit(ChatLoading());
      }

      final response = await apiService.getChats();

      if (response['success'] == true) {
        final List<dynamic> chatsJson = response['chats'];
        final chats = chatsJson
            .map((json) => ChatModel.fromJson(json))
            .toList();

        // Update cache
        _chatsCache = chats;
        emit(ChatChatsLoaded(chats));
      } else {
        // If we have cache, don't show error - keep showing cached data
        if (_chatsCache.isEmpty) {
          emit(ChatError(response['message'] ?? 'Failed to load chats'));
        }
      }
    } catch (e) {
      // If we have cache, don't show error - keep showing cached data
      if (_chatsCache.isEmpty) {
        emit(ChatError(e.toString()));
      }
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
      final currentState = state;
      int page = 1;
      List<MessageModel> currentMessages = [];

      // Determine page and current messages
      if (currentState is ChatMessagesLoaded &&
          currentState.chatId == event.chatId &&
          !event.refresh) {
        page = currentState.currentPage + 1;
        currentMessages = currentState.messages;
        // Don't emit loading for pagination
      } else if (event.refresh && currentState is ChatMessagesLoaded) {
        // Keep showing current messages while refreshing
        currentMessages = currentState.messages;
      } else {
        // Show loading only for initial load
        emit(ChatLoading());
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

        emit(
          ChatMessagesLoaded(
            chatId: event.chatId,
            messages: allMessages,
            hasMore: hasMore,
            currentPage: page,
          ),
        );
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
        final String errorMessage =
            response['message'] ?? 'Failed to send message';

        // Check for Firebase errors (non-critical)
        if (errorMessage.contains('Firebase') ||
            errorMessage.contains('default Firebase app')) {
          // Message likely saved, just notification failed
          // Trigger a silent reload to sync
          add(ChatLoadMessages(chatId: event.chatId, refresh: true));
          return;
        }

        emit(ChatError(errorMessage));
        
        // Restore previous state after brief delay
        await Future.delayed(const Duration(seconds: 2));
        if (currentState is ChatMessagesLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      print('Send message error in bloc: $e');
      
      final currentState = state;
      emit(ChatError(e.toString()));

      // Restore previous state after error
      await Future.delayed(const Duration(seconds: 2));
      if (currentState is ChatMessagesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onChatMarkAsRead(
    ChatMarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await apiService.markMessagesAsRead(event.chatId);
      // Don't emit any state here - this is a fire-and-forget operation
    } catch (e) {
      print('Error marking messages as read: $e');
      // Silently fail - not critical
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