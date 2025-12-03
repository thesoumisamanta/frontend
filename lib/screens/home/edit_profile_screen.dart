import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/helpers/global_methods.dart';
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
                GlobalMethods.showSuccessSnackBar(
                  context,
                  'Profile updated successfully',
                );
                Navigator.of(context).pop(true);
              } else if (state is UserError) {
                GlobalMethods.showErrorSnackBar(context, state.message);
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
                  onTap: () => GlobalMethods.showImageSourcePicker(
                    context: context,
                    isProfile: false, // FALSE for cover photo
                    currentImage: _coverImage,
                    networkImageUrl: widget.user.coverPhoto?.url,
                    onImagePicked: (image) {
                      setState(() => _coverImage = image);
                    },
                  ),
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
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey[600],
                              ),
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

                // Edit Cover Photo Button (overlay)
                if (_coverImage != null ||
                    (widget.user.coverPhoto != null &&
                        widget.user.coverPhoto!.url.isNotEmpty))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () => GlobalMethods.showImageSourcePicker(
                          context: context,
                          isProfile: false, // FALSE for cover photo
                          currentImage: _coverImage,
                          networkImageUrl: widget.user.coverPhoto?.url,
                          onImagePicked: (image) {
                            setState(() => _coverImage = image);
                          },
                        ),
                      ),
                    ),
                  ),

                // Profile Picture (positioned over cover photo)
                Positioned(
                  bottom: -50,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => GlobalMethods.showImageSourcePicker(
                      context: context,
                      isProfile: true, // TRUE for profile photo
                      currentImage: _profileImage,
                      networkImageUrl: widget.user.profilePicture.url,
                      onImagePicked: (image) {
                        setState(() => _profileImage = image);
                      },
                    ),
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