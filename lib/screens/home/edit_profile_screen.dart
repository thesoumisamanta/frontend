import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _businessEmailController;
  late bool _isPrivate;
  
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);
    _websiteController = TextEditingController(text: widget.user.website);
    _businessEmailController = TextEditingController(
      text: widget.user.businessEmail,
    );
    _isPrivate = widget.user.isPrivate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _businessEmailController.dispose();
    super.dispose();
  }

  // Show image source picker (Camera or Gallery)
  Future<void> _showImageSourcePicker(bool isProfile) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose ${isProfile ? 'Profile' : 'Cover'} Photo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isProfile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isProfile);
                },
              ),
              if ((isProfile && _profileImage != null) || 
                  (!isProfile && _coverImage != null)) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isProfile) {
                        _profileImage = null;
                      } else {
                        _coverImage = null;
                      }
                    });
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: isProfile ? 1000 : 1920,
        maxHeight: isProfile ? 1000 : 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else {
            _coverImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _saveProfile() {
    final data = {
      'fullName': _fullNameController.text.trim(),
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'website': _websiteController.text.trim(),
      'businessEmail': _businessEmailController.text.trim(),
      'isPrivate': _isPrivate,
    };

    context.read<UserBloc>().add(
      UserUpdateProfile(
        data,
        profileImage: _profileImage,
        coverImage: _coverImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocConsumer<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
                Navigator.of(context).pop(true); // Return true to indicate update
              } else if (state is UserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is UserLoading;
              return TextButton(
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Photo Section
            Stack(
              children: [
                // Cover Photo
                GestureDetector(
                  onTap: () => _showImageSourcePicker(false),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(_coverImage!),
                              fit: BoxFit.cover,
                            )
                          : (widget.user.coverPhoto != null &&
                                  widget.user.coverPhoto!.url.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(widget.user.coverPhoto!.url),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _coverImage == null &&
                            (widget.user.coverPhoto == null ||
                                widget.user.coverPhoto!.url.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 48, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                'Add Cover Photo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                
                // Edit Cover Photo Button
                if (_coverImage != null ||
                    (widget.user.coverPhoto != null &&
                        widget.user.coverPhoto!.url.isNotEmpty))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => _showImageSourcePicker(false),
                      ),
                    ),
                  ),

                // Profile Picture (overlapping cover photo)
                Positioned(
                  bottom: -50,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => _showImageSourcePicker(true),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : NetworkImage(widget.user.profilePicture.url)
                                    as ImageProvider,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Full Name
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.info),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Website
                  TextField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  // Business Email (only for business accounts)
                  if (widget.user.accountType == 'business') ...[
                    TextField(
                      controller: _businessEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Business Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Private Account Toggle
                  Card(
                    child: SwitchListTile(
                      title: const Text('Private Account'),
                      subtitle: const Text('Only followers can see your posts'),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}