import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../screens/home/post_detail_screen.dart';
import 'cached_image.dart';

class ProfilePostGrid extends StatelessWidget {
  final List<PostModel> posts;
  final TabController tabController;

  const ProfilePostGrid({
    super.key,
    required this.posts,
    required this.tabController,
  });

  List<PostModel> _filterPostsByType(String type) {
    if (type == 'all') return posts;
    return posts.where((post) => post.postType == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: tabController,
        children: [
          _buildGrid(context, _filterPostsByType('all')),
          _buildGrid(context, _filterPostsByType('video')),
          _buildGrid(context, _filterPostsByType('short')),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<PostModel> filteredPosts) {
    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: post.id),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedImage(
                imageUrl: post.media.isNotEmpty
                    ? (post.media.first.thumbnail ?? post.media.first.url)
                    : 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
              ),
              if (post.postType == 'video' || post.postType == 'short')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    post.postType == 'video'
                        ? Icons.videocam
                        : Icons.play_circle_outline,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              if (post.media.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.collections,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}