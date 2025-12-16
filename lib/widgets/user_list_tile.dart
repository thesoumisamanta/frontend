import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import 'cached_image.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isCurrentUser;

  const UserListTile({
    super.key,
    required this.user,
    this.onTap,
    this.trailing,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedImageProvider(user.profilePicture.url),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: Colors.blue),
          ],
        ],
      ),
      subtitle: Text(isCurrentUser ? "You" : user.fullName, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
