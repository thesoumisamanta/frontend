import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String? chatId;
  final String? username;
  final String? profilePictureUrl;

  const ChatScreen({
    super.key,
    required this.userId,
    this.chatId,
    this.username,
    this.profilePictureUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentChatId;
  bool _isSending = false;
  String? _displayUsername;
  String? _displayProfilePicture;
  DateTime? _lastSeen;

  @override
  void initState() {
    super.initState();
    _displayUsername = widget.username;
    _displayProfilePicture = widget.profilePictureUrl;
    
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
    if (_messageController.text.trim().isEmpty || _currentChatId == null || _isSending) {
      return;
    }

    setState(() => _isSending = true);

    context.read<ChatBloc>().add(
          ChatSendMessage(
            chatId: _currentChatId!,
            text: _messageController.text.trim(),
          ),
        );

    _messageController.clear();
    
    // Reset sending state after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isSending = false);
      }
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _getOnlineStatus() {
    if (_lastSeen == null) {
      return 'Tap to view profile';
    }
    
    final difference = DateTime.now().difference(_lastSeen!);
    
    if (difference.inMinutes < 5) {
      return 'Online';
    } else {
      return 'Last seen ${timeago.format(_lastSeen!)}';
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
            titleSpacing: 0,
            title: InkWell(
              onTap: () {
                // Navigate to user profile
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _displayProfilePicture != null
                        ? CachedImageProvider(_displayProfilePicture!)
                        : null,
                    child: _displayProfilePicture == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Username and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _displayUsername ?? 'Chat',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getOnlineStatus(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  // TODO: Implement video call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video call coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  // TODO: Implement voice call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice call coming soon')),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle menu actions
                  if (value == 'view_profile') {
                    Navigator.pop(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_profile',
                    child: Text('View profile'),
                  ),
                  const PopupMenuItem(
                    value: 'mute',
                    child: Text('Mute notifications'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear chat'),
                  ),
                ],
              ),
            ],
          ),
          body: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) {
                setState(() {
                  _currentChatId = state.chat.id;
                  // Extract user info from chat
                  final otherParticipant = state.chat.participants.firstWhere(
                    (p) => p.id != currentUserId,
                    orElse: () => state.chat.participants.first,
                  );
                  _displayUsername = otherParticipant.username;
                  _displayProfilePicture = otherParticipant.profilePicture.url;
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
                  
                  // Update last seen from the last message
                  final lastMessage = state.messages.last;
                  if (lastMessage.sender.id == widget.userId) {
                    setState(() {
                      _lastSeen = lastMessage.createdAt;
                    });
                  }
                }
              } else if (state is ChatError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () {
                        if (_currentChatId != null) {
                          _loadMessages();
                        } else {
                          _getOrCreateChat();
                        }
                      },
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              // Handle initial and loading states together
              if (state is ChatLoading || state is ChatInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChatMessagesLoaded) {
                return Column(
                  children: [
                    Expanded(
                      child: state.messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No messages yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Say hi to ${_displayUsername ?? 'start chatting'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                              ),
                              child: ListView.builder(
                                controller: _scrollController,
                                reverse: false,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.emoji_emotions_outlined,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        // TODO: Implement emoji picker
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Emoji picker coming soon'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        decoration: const InputDecoration(
                                          hintText: 'Message',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                        ),
                                        maxLines: 5,
                                        minLines: 1,
                                        enabled: !_isSending,
                                        textCapitalization: TextCapitalization.sentences,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.attach_file,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        // TODO: Implement file attachment
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('File attachment coming soon'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        // TODO: Implement camera
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Camera coming soon'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(28),
                              child: InkWell(
                                onTap: _isSending ? null : _sendMessage,
                                borderRadius: BorderRadius.circular(28),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: _isSending
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Show loading indicator for any unknown state
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}