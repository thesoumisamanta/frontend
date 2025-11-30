import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String? chatId;

  const ChatScreen({
    super.key,
    required this.userId,
    this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentChatId;

  @override
  void initState() {
    super.initState();
    if (widget.chatId != null) {
      _currentChatId = widget.chatId;
      _loadMessages();
    } else {
      _getOrCreateChat();
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _getOrCreateChat() {
    context.read<ChatBloc>().add(ChatGetOrCreate(widget.userId));
  }

  void _loadMessages() {
    if (_currentChatId != null) {
      context.read<ChatBloc>().add(
            ChatLoadMessages(chatId: _currentChatId!, refresh: true),
          );
      context.read<ChatBloc>().add(ChatMarkAsRead(_currentChatId!));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatMessagesLoaded && state.hasMore) {
        context.read<ChatBloc>().add(
              ChatLoadMessages(chatId: _currentChatId!),
            );
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentChatId == null) {
      return;
    }

    context.read<ChatBloc>().add(
          ChatSendMessage(
            chatId: _currentChatId!,
            text: _messageController.text.trim(),
          ),
        );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = authState.user.id;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) {
                setState(() {
                  _currentChatId = state.chat.id;
                });
                _loadMessages();
              } else if (state is ChatMessagesLoaded) {
                if (state.messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients &&
                        _scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent) {
                      _scrollToBottom();
                    }
                  });
                }
              } else if (state is ChatError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChatMessagesLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: state.messages.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: false,
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                final message = state.messages[index];
                                final isMine = message.isMine(currentUserId);

                                return MessageBubble(
                                  message: message,
                                  isMine: isMine,
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                maxLines: 5,
                                minLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _sendMessage,
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const Center(child: Text('Something went wrong'));
            },
          ),
        );
      },
    );
  }
}