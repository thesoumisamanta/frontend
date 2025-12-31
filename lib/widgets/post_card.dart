import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/blocs/comment/comment_bloc.dart';
import 'package:frontend/blocs/post/post_bloc.dart';
import 'package:frontend/screens/home/comments_screen.dart';
import 'package:frontend/screens/home/post_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';
import '../models/post_model.dart';
import '../blocs/post/post_event.dart';
import '../screens/home/profile_screen.dart';
import '../blocs/user/user_bloc.dart';
import 'cached_image.dart';
import 'video_player_widget.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool showComments;

  const PostCard({super.key, required this.post, this.showComments = true});

  void _navigateToPostDetail(BuildContext context) {
    // Force all videos to update their visibility (this will pause/dispose them)
    VisibilityDetectorController.instance.notifyNow();
    
    // Small delay to ensure cleanup happens
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        // Get bloc references
        final postBloc = context.read<PostBloc>();
        final commentBloc = context.read<CommentBloc>();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: postBloc),
                BlocProvider.value(value: commentBloc),
              ],
              child: PostDetailScreen(postId: post.id),
            ),
          ),
        ).then((_) {
          // When returning, trigger visibility update again
          VisibilityDetectorController.instance.notifyNow();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    final bool hasLiked = user != null
        ? (post.likes.contains(user.id) || post.hasLiked)
        : false;
    final bool hasDisliked = user != null
        ? (post.dislikes.contains(user.id) || post.hasDisliked)
        : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        ListTile(
          leading: GestureDetector(
            onTap: () {
              final userBloc = context.read<UserBloc>();
              final postBloc = context.read<PostBloc>();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: userBloc),
                      BlocProvider.value(value: postBloc),
                    ],
                    child: ProfileScreen(userId: post.user.id),
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: CachedImageProvider(
                post.user.profilePicture.url,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                post.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (post.user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 16, color: Colors.blue),
              ],
            ],
          ),
          subtitle: Row(
            children: [
              Text(timeago.format(post.createdAt)),
              if (post.location.isNotEmpty) ...[
                const Text(' • '),
                const Icon(Icons.location_on, size: 12),
                Flexible(
                  child: Text(post.location, overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPostOptions(context);
            },
          ),
        ),

        // Media
        if (post.media.isNotEmpty)
          GestureDetector(
            onTap: () => _navigateToPostDetail(context),
            child: SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: post.media.length,
                padEnds: false,
                physics: const PageScrollPhysics(),
                itemBuilder: (context, index) {
                  final media = post.media[index];
                  if (media.type == 'image') {
                    return CachedImage(imageUrl: media.url, fit: BoxFit.cover);
                  } else {
                    // Video - will only initialize when visible
                    return VideoPlayerWidget(
                      videoUrl: media.url,
                      thumbnail: media.thumbnail,
                      autoPlay: false, // Changed to false - user must tap to play
                    );
                  }
                },
              ),
            ),
          ),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action buttons
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: hasLiked ? Colors.blue : null,
                    ),
                    onPressed: () {
                      context.read<PostBloc>().add(PostLike(post.id));
                    },
                  ),
                  Text(post.likesCount.toString()),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      hasDisliked
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      color: hasDisliked ? Colors.red : null,
                    ),
                    onPressed: () {
                      context.read<PostBloc>().add(PostDislike(post.id));
                    },
                  ),
                  Text(post.dislikesCount.toString()),
                  const SizedBox(width: 16),
                  if (showComments)
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () => _showComments(context),
                    ),
                  if (showComments) Text(post.commentsCount.toString()),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      context.read<PostBloc>().add(PostShare(post.id));
                    },
                  ),
                ],
              ),
              
              // Caption
              if (post.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      children: [
                        TextSpan(
                          text: '${post.user.username} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: CommentsScreen(
                      postId: post.id,
                      isBottomSheet: true,
                      scrollController: scrollController,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                context.read<PostBloc>().add(PostDelete(post.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}