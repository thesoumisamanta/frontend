import 'package:flutter/material.dart';
import '../models/story_model.dart';
import 'cached_image.dart';

class StoryList extends StatelessWidget {
  final List<StoryGroup> storyGroups;

  const StoryList({super.key, required this.storyGroups});

  @override
  Widget build(BuildContext context) {
    if (storyGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storyGroups.length,
        itemBuilder: (context, index) {
          final group = storyGroups[index];
          return _StoryCircle(
            storyGroup: group,
            onTap: () {
              // Navigate to story viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story viewer coming soon')),
              );
            },
          );
        },
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  final StoryGroup storyGroup;
  final VoidCallback onTap;

  const _StoryCircle({
    required this.storyGroup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: storyGroup.hasUnviewed
                    ? LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.orange,
                        ],
                      )
                    : null,
                border: storyGroup.hasUnviewed
                    ? null
                    : Border.all(color: Colors.grey, width: 2),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: DecorationImage(
                    image: CachedImageProvider(
                      storyGroup.user.profilePicture.url,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              child: Text(
                storyGroup.user.username,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}