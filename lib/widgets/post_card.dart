import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../screens/home/profile_screen.dart';
import '../screens/home/post_detail_screen.dart';
import 'cached_image.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool showComments;

  const PostCard({
    super.key,
    required this.post,
    this.showComments = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: post.user.id),
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
                    child: Text(
                      post.location,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: post.media.length,
                itemBuilder: (context, index) {
                  final media = post.media[index];
                  if (media.type == 'image') {
                    return CachedImage(
                      imageUrl: media.url,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        if (media.thumbnail != null)
                          CachedImage(
                            imageUrl: media.thumbnail!,
                            fit: BoxFit.cover,
                          ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: post.hasLiked ? Colors.blue : null,
                  ),
                  onPressed: () {
                    context.read<PostBloc>().add(PostLike(post.id));
                  },
                ),
                Text(post.likesCount.toString()),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    post.hasDisliked
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    color: post.hasDisliked ? Colors.red : null,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: post.id),
                        ),
                      );
                    },
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
          ),

          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

          // Tags
          if (post.tags.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                children: post.tags
                    .map(
                      (tag) => Text(
                        '#$tag',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
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