import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GlobalMethods {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  static Future<File?> pickImage(
    ImageSource source, {
    double? maxWidth,
    double? maxHeight,
    bool isProfile = false,
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth ?? (isProfile ? 1000.0 : 1920.0),
        maxHeight: maxHeight ?? (isProfile ? 1000.0 : 1080.0),
        imageQuality: 85,
      );

      if (picked != null) {
        return File(picked.path);
      }
      return null;
    } catch (e) {
      debugPrint("Image pick error: $e");
      return null;
    }
  }

  /// Bottom sheet image picker (Camera / Gallery / Remove)
  static Future<void> showImageSourcePicker({
    required BuildContext context,
    required Function(File?) onImagePicked,
    required bool isProfile,
    File? currentImage,
    String? networkImageUrl, // Added to check if there's a network image
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose ${isProfile ? "Profile" : "Cover"} Photo",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Camera Option
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    File? img = await pickImage(
                      ImageSource.camera,
                      isProfile: isProfile,
                    );
                    onImagePicked(img);
                  },
                ),
                
                // Gallery Option
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    File? img = await pickImage(
                      ImageSource.gallery,
                      isProfile: isProfile,
                    );
                    onImagePicked(img);
                  },
                ),
                
                // Remove Photo Option (only show if there's an image)
                if (currentImage != null || 
                    (networkImageUrl != null && networkImageUrl.isNotEmpty)) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Remove Photo"),
                    onTap: () {
                      Navigator.pop(context);
                      onImagePicked(null); // Remove image
                    },
                  ),
                ],
                
                const SizedBox(height: 10),
                
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}