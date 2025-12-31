import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../widgets/cached_image.dart';
import 'profile_screen.dart';
import 'post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Store bloc references to avoid context issues
  late final NotificationBloc _notificationBloc;
  late final UserBloc _userBloc;
  late final PostBloc _postBloc;
  late final CommentBloc _commentBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Get bloc references
    _notificationBloc = context.read<NotificationBloc>();
    _userBloc = context.read<UserBloc>();
    _postBloc = context.read<PostBloc>();
    _commentBloc = context.read<CommentBloc>();
    
    // Only load if we don't have notifications already
    final currentState = _notificationBloc.state;
    if (currentState is! NotificationLoaded) {
      _notificationBloc.add(const NotificationLoad(refresh: true));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = _notificationBloc.state;
      if (state is NotificationLoaded && state.hasMore) {
        _notificationBloc.add(const NotificationLoad());
      }
    }
  }

  Future<void> _onRefresh() async {
    _notificationBloc.add(const NotificationLoad(refresh: true));
  }

  void _handleNotificationTap(
    String notificationId,
    String type,
    String senderId,
    String? postId,
  ) {
    // Mark as read
    _notificationBloc.add(NotificationMarkAsRead(notificationId));

    // Navigate based on type
    if (type == 'follow') {
      // Navigate to the sender's profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _userBloc),
              BlocProvider.value(value: _postBloc),
            ],
            child: ProfileScreen(userId: senderId),
          ),
        ),
      ).then((_) {
        // Refresh notifications when coming back
        if (mounted) {
          _notificationBloc.add(const NotificationLoad(refresh: true));
        }
      });
    } else if (postId != null && (type == 'like' || type == 'comment' || type == 'dislike')) {
      // Navigate to the post detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _postBloc),
              BlocProvider.value(value: _commentBloc),
            ],
            child: PostDetailScreen(postId: postId),
          ),
        ),
      ).then((_) {
        // Refresh notifications when coming back
        if (mounted) {
          _notificationBloc.add(const NotificationLoad(refresh: true));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            bloc: _notificationBloc,
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    _notificationBloc.add(const NotificationMarkAllAsRead());
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          bloc: _notificationBloc,
          builder: (context, state) {
            // Handle initial and loading states together
            if (state is NotificationLoading || state is NotificationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: state.notifications.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return state.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 80);
                  }

                  final notification = state.notifications[index];

                  return ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        // Navigate to sender's profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: _userBloc),
                                BlocProvider.value(value: _postBloc),
                              ],
                              child: ProfileScreen(
                                userId: notification.sender.id,
                              ),
                            ),
                          ),
                        ).then((_) {
                          if (mounted) {
                            _notificationBloc.add(
                              const NotificationLoad(refresh: true),
                            );
                          }
                        });
                      },
                      child: CircleAvatar(
                        backgroundImage: CachedImageProvider(
                          notification.sender.profilePicture.url,
                        ),
                      ),
                    ),
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        children: [
                          TextSpan(
                            text: notification.sender.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ${notification.message.replaceFirst(
                              notification.sender.username,
                              '',
                            )}',
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      timeago.format(notification.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      notification.getNotificationIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                    tileColor: notification.isRead
                        ? null
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    onTap: () => _handleNotificationTap(
                      notification.id,
                      notification.type,
                      notification.sender.id,
                      notification.post,
                    ),
                  );
                },
              );
            }

            // Fallback - show loading instead of error
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}