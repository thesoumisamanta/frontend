import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/comment/comment_state.dart';
import '../../widgets/comment_item.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final bool isBottomSheet;
  final ScrollController? scrollController;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.isBottomSheet = false,
    this.scrollController,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late ScrollController _internalScrollController;
  final FocusNode _commentFocusNode = FocusNode();

  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _internalScrollController = widget.scrollController ?? ScrollController();
    _internalScrollController.addListener(_onScroll);

    // Load comments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentBloc>().add(
        CommentLoadPostComments(postId: widget.postId, refresh: true),
      );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_internalScrollController.position.pixels >=
        _internalScrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<CommentBloc>().state;
      if (state is CommentPostCommentsLoaded && state.hasMore) {
        context.read<CommentBloc>().add(
          CommentLoadPostComments(postId: widget.postId),
        );
      }
    }
  }

  void _handleReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    context.read<CommentBloc>().add(
      CommentCreate(
        postId: widget.postId,
        text: _commentController.text.trim(),
        parentCommentId: _replyingToCommentId,
      ),
    );

    _commentController.clear();
    _cancelReply();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBottomSheet) {
      // For bottom sheet, don't show AppBar
      return Column(
        children: [
          Expanded(
            child: _buildCommentsList(),
          ),
          _buildCommentInput(),
        ],
      );
    }

    // For full screen (if still needed)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildCommentsList(),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentCreated) {
          context.read<CommentBloc>().add(
            CommentLoadPostComments(
              postId: widget.postId,
              refresh: true,
            ),
          );
        } else if (state is CommentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is CommentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<CommentBloc>().add(
            CommentLoadPostComments(
              postId: widget.postId,
              refresh: true,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return current is CommentLoading || 
               current is CommentPostCommentsLoaded;
      },
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CommentPostCommentsLoaded) {
          if (state.comments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No comments yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to comment',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _internalScrollController,
            itemCount: state.comments.length + 1,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            itemBuilder: (context, index) {
              if (index == state.comments.length) {
                return state.hasMore
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox(height: 80);
              }
              return CommentItem(
                comment: state.comments[index],
                postId: widget.postId,
                onReply: _handleReply,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCommentInput() {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replying indicator
            if (_replyingToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Replying to @$_replyingToUsername',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _cancelReply,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            if (_replyingToUsername != null) const SizedBox(height: 8),

            // Comment input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyingToUsername != null
                          ? 'Reply to @$_replyingToUsername...'
                          : 'Add a comment...',
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
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    final isCreating = state is CommentCreating;
                    return IconButton(
                      onPressed: isCreating ? null : _addComment,
                      icon: isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                            ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}