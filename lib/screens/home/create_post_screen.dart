import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../blocs/story/story_bloc.dart';
import '../../blocs/story/story_event.dart';
import '../../blocs/story/story_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<File> _selectedMedia = [];
  String _postType = 'image';
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedMedia.addAll(images.map((img) => File(img.path)));
          if (_selectedMedia.length > 10) {
            _selectedMedia.removeRange(10, _selectedMedia.length);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(File(video.path));
          _postType = 'video';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _createStory() async {
    try {
      final XFile? media = await showDialog<XFile>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create Story'),
          content: const Text('Choose media type'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text('Photo'),
              onPressed: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, image);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text('Video'),
              onPressed: () async {
                final XFile? video =
                    await _picker.pickVideo(source: ImageSource.gallery);
                Navigator.pop(context, video);
              },
            ),
          ],
        ),
      );

      if (media != null) {
        context.read<StoryBloc>().add(
              StoryCreate(
                mediaFile: File(media.path),
              ),
            );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating story: $e')),
      );
    }
  }

  void _createPost() {
    if (_selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select media')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    context.read<PostBloc>().add(
          PostCreate(
            caption: _captionController.text,
            postType: _postType,
            mediaFiles: _selectedMedia,
            location: _locationController.text,
            tags: tags.isEmpty ? null : tags,
          ),
        );
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
      if (_selectedMedia.isEmpty) {
        _postType = 'image';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create'),
        actions: [
          BlocConsumer<PostBloc, PostState>(
            listener: (context, state) {
              if (state is PostCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post created successfully')),
                );
                _captionController.clear();
                _locationController.clear();
                _tagsController.clear();
                setState(() {
                  _selectedMedia.clear();
                  _postType = 'image';
                });
                context.read<PostBloc>().add(const PostLoadFeed(refresh: true));
              } else if (state is PostError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final isCreating = state is PostCreating;
              return TextButton(
                onPressed: isCreating ? null : _createPost,
                child: isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              );
            },
          ),
        ],
      ),
      body: BlocListener<StoryBloc, StoryState>(
        listener: (context, state) {
          if (state is StoryCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Story created successfully')),
            );
            context.read<StoryBloc>().add(const StoryLoadFollowing());
          } else if (state is StoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                      onPressed: _pickMedia,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam),
                      label: const Text('Add Video'),
                      onPressed: _pickVideo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Create Story'),
                onPressed: _createStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),

              // Selected Media Preview
              if (_selectedMedia.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedMedia[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () => _removeMedia(index),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Caption
              TextField(
                controller: _captionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Write a caption...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Add location',
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  prefixIcon: Icon(Icons.tag),
                  hintText: 'Add tags (comma separated)',
                ),
              ),
              const SizedBox(height: 16),

              // Post Type
              if (_selectedMedia.isNotEmpty && _postType == 'image') ...[
                DropdownButtonFormField<String>(
                  value: _postType,
                  decoration: const InputDecoration(
                    labelText: 'Post Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'image', child: Text('Image Post')),
                    DropdownMenuItem(value: 'short', child: Text('Short')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _postType = value!;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}