import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/comment/comment_state.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comment_item.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  String? _replyingToCommentId;
  String? _replyingToUsername;
  
  late final PostBloc _postBloc;
  late final CommentBloc _commentBloc;
  
  bool _isPostLoaded = false;
  bool _areCommentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _postBloc = context.read<PostBloc>();
    _commentBloc = context.read<CommentBloc>();

    // Check if post is already loaded
    final currentPostState = _postBloc.state;
    if (currentPostState is PostSingleLoaded && 
        currentPostState.post.id == widget.postId) {
      _isPostLoaded = true;
    }
    
    // Check if comments are already loaded
    final currentCommentState = _commentBloc.state;
    if (currentCommentState is CommentPostCommentsLoaded && 
        currentCommentState.postId == widget.postId) {
      _areCommentsLoaded = true;
    }

    // Load only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPostLoaded) {
        _postBloc.add(PostLoadSingle(widget.postId));
      }
      if (!_areCommentsLoaded) {
        _commentBloc.add(
          CommentLoadPostComments(postId: widget.postId, refresh: true),
        );
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = _commentBloc.state;
      if (state is CommentPostCommentsLoaded && state.hasMore) {
        _commentBloc.add(
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

    _commentBloc.add(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // Post Section
          BlocBuilder<PostBloc, PostState>(
            bloc: _postBloc,
            builder: (context, state) {
              // Show loading only if not already loaded
              if (state is PostLoading && !_isPostLoaded) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is PostSingleLoaded) {
                _isPostLoaded = true;
                return PostCard(post: state.post, showComments: false);
              }

              if (state is PostError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _postBloc.add(PostLoadSingle(widget.postId));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // If we have loaded state cached, don't show "not found"
              if (_isPostLoaded) {
                return const SizedBox.shrink();
              }

              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text('Post not found')),
              );
            },
          ),

          const Divider(height: 1),

          // Comments Section
          Expanded(
            child: BlocConsumer<CommentBloc, CommentState>(
              bloc: _commentBloc,
              listener: (context, state) {
                if (state is CommentCreated) {
                  _commentBloc.add(
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
                  _commentBloc.add(
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
                // Show loading only if not already loaded
                if (state is CommentLoading && !_areCommentsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CommentPostCommentsLoaded) {
                  _areCommentsLoaded = true;
                  
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
                    controller: _scrollController,
                    itemCount: state.comments.length + 1,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
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

                // If we have loaded comments cached, don't show empty
                if (_areCommentsLoaded) {
                  return const SizedBox.shrink();
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),

      // Comment Input
      bottomNavigationBar: Container(
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
                    bloc: _commentBloc,
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
      ),
    );
  }
}