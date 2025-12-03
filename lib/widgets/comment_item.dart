import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/screens/home/user_list_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/comment_model.dart';
import '../blocs/comment/comment_bloc.dart';
import '../blocs/comment/comment_event.dart';
import '../blocs/comment/comment_state.dart';
import 'cached_image.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final Function(String commentId, String username)? onReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    this.onReply,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;
  List<CommentModel> _replies = [];
  bool _isLoadingReplies = false;

  void _toggleReplies() async {
    if (!_showReplies && _replies.isEmpty) {
      // Load replies
      setState(() => _isLoadingReplies = true);
      context.read<CommentBloc>().add(CommentLoadReplies(widget.comment.id));
    } else {
      setState(() => _showReplies = !_showReplies);
    }
  }

  void _showCommentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
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

  void _showEditDialog() {
    final controller = TextEditingController(text: widget.comment.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your comment',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<CommentBloc>().add(
                  CommentUpdate(widget.comment.id, controller.text.trim()),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CommentBloc>().add(CommentDelete(widget.comment.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLikesList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsersListScreen(
          title: 'Likes',
          fetchUsers: () => context.read<CommentBloc>().getCommentLikes(widget.comment.id),
        ),
      ),
    );
  }

  void _showDislikesList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsersListScreen(
          title: 'Dislikes',
          fetchUsers: () => context.read<CommentBloc>().getCommentDislikes(widget.comment.id),
        ),
      ),
    );
  }

  void _handleReply() {
    if (widget.onReply != null) {
      widget.onReply!(widget.comment.id, widget.comment.user.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Indent based on depth level
    final indent = widget.comment.depth * 16.0;

    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentRepliesLoaded && state.commentId == widget.comment.id) {
          setState(() {
            _replies = state.replies;
            _showReplies = true;
            _isLoadingReplies = false;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: indent, top: 8.0, right: 8.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Comment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedImageProvider(
                    widget.comment.user.profilePicture.url,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Comment Bubble
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.comment.user.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.comment.user.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  onPressed: _showCommentOptions,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.comment.isDeleted ? '[Deleted]' : widget.comment.text,
                              style: TextStyle(
                                fontStyle: widget.comment.isDeleted ? FontStyle.italic : null,
                                color: widget.comment.isDeleted ? Colors.grey : null,
                              ),
                            ),
                            if (widget.comment.isEdited && !widget.comment.isDeleted)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '(edited)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Actions Row
                      Wrap(
                        spacing: 16,
                        children: [
                          Text(
                            timeago.format(widget.comment.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          // Like
                          GestureDetector(
                            onTap: () {
                              context.read<CommentBloc>().add(
                                CommentLike(widget.comment.id),
                              );
                            },
                            onLongPress: widget.comment.likesCount > 0 ? _showLikesList : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.comment.hasLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 16,
                                  color: widget.comment.hasLiked ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.comment.likesCount.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Dislike
                          GestureDetector(
                            onTap: () {
                              context.read<CommentBloc>().add(
                                CommentDislike(widget.comment.id),
                              );
                            },
                            onLongPress: widget.comment.dislikesCount > 0 ? _showDislikesList : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.comment.hasDisliked
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_outlined,
                                  size: 16,
                                  color: widget.comment.hasDisliked ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.comment.dislikesCount.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Reply Button
                          GestureDetector(
                            onTap: _handleReply,
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          // View Replies
                          if (widget.comment.repliesCount > 0)
                            GestureDetector(
                              onTap: _toggleReplies,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showReplies
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.comment.repliesCount} ${widget.comment.repliesCount == 1 ? 'reply' : 'replies'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Show Replies
            if (_isLoadingReplies)
              const Padding(
                padding: EdgeInsets.only(left: 48, top: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            
            if (_showReplies && _replies.isNotEmpty)
              ..._replies.map((reply) => CommentItem(
                comment: reply,
                postId: widget.postId,
                onReply: widget.onReply,
              )),
          ],
        ),
      ),
    );
  }
}