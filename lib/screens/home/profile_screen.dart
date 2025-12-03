import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/helpers/global_methods.dart';
import 'package:frontend/utils/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/profile_post_grid.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'chat_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<UserBloc>().add(UserLoadProfile(widget.userId));
    context.read<PostBloc>().add(
      PostLoadUserPosts(userId: widget.userId, refresh: true),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleFollowToggle() {
    context.read<UserBloc>().add(UserFollowToggle(widget.userId));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleProfileImagePick(File? image) {
    if (image != null) {
      setState(() => _profileImage = image);

      // Immediately update profile picture on backend
      final data = <String, dynamic>{};
      context.read<UserBloc>().add(
        UserUpdateProfile(data, profileImage: image),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = authState.user;
        final isOwnProfile = currentUser.id == widget.userId;

        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserProfileLoaded) {
                  return Text(state.user.username);
                }
                return const Text('Profile');
              },
            ),
            actions: [
              if (isOwnProfile)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UserBloc>().add(
                            UserLoadProfile(widget.userId),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is UserProfileLoaded) {
                final user = state.user;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserBloc>().add(
                      UserLoadProfile(widget.userId),
                    );
                    context.read<PostBloc>().add(
                      PostLoadUserPosts(userId: widget.userId, refresh: true),
                    );
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Profile Header
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // FIXED: Restructured to ensure proper touch detection
                            Column(
                              children: [
                                // Cover Photo Section
                                user.coverPhoto != null
                                    ? Container(
                                        height: 120,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedImageProvider(
                                              user.coverPhoto!.url,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                      ),

                                // Profile Picture Section (outside of Stack for proper touch)
                                Transform.translate(
                                  offset: const Offset(0, -50),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Profile Picture with Camera Icon
                                        GestureDetector(
                                          onTap: isOwnProfile
                                              ? () {
                                                  GlobalMethods.showImageSourcePicker(
                                                    context: context,
                                                    isProfile: true,
                                                    currentImage: _profileImage,
                                                    networkImageUrl:
                                                        user.profilePicture.url,
                                                    onImagePicked:
                                                        _handleProfileImagePick,
                                                  );
                                                }
                                              : null,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    width: 4,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage:
                                                      _profileImage != null
                                                      ? FileImage(
                                                          _profileImage!,
                                                        )
                                                      : CachedImageProvider(
                                                              user
                                                                  .profilePicture
                                                                  .url,
                                                            )
                                                            as ImageProvider,
                                                ),
                                              ),

                                              // Camera Icon - Now properly clickable
                                              if (isOwnProfile)
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        GlobalMethods.showImageSourcePicker(
                                                          context: context,
                                                          isProfile: true,
                                                          currentImage:
                                                              _profileImage,
                                                          networkImageUrl: user
                                                              .profilePicture
                                                              .url,
                                                          onImagePicked:
                                                              _handleProfileImagePick,
                                                        );
                                                      },
                                                      customBorder:
                                                          const CircleBorder(),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppColors
                                                                  .primary,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // User Info Section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 50),

                                              // Name and Edit Icon
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      user.fullName,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isOwnProfile) ...[
                                                    const SizedBox(width: 8),
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  EditProfileScreen(
                                                                    user: user,
                                                                  ),
                                                            ),
                                                          ).then((updated) {
                                                            // Refresh profile if updated
                                                            if (updated ==
                                                                true) {
                                                              context
                                                                  .read<
                                                                    UserBloc
                                                                  >()
                                                                  .add(
                                                                    UserLoadProfile(
                                                                      widget
                                                                          .userId,
                                                                    ),
                                                                  );
                                                            }
                                                          });
                                                        },
                                                        customBorder:
                                                            const CircleBorder(),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                4.0,
                                                              ),
                                                          child: Icon(
                                                            Icons.edit_outlined,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),

                                              // Username
                                              Text(
                                                '@${user.username}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),

                                              // Bio
                                              if (user.bio.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  user.bio,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(
                                  user.postsCount.toString(),
                                  'Posts',
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowersScreen(
                                          userId: widget.userId,
                                          initialTab: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildStatColumn(
                                    user.followersCount.toString(),
                                    'Followers',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FollowersScreen(
                                          userId: widget.userId,
                                          initialTab: 1,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildStatColumn(
                                    user.followingCount.toString(),
                                    'Following',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Action Buttons
                            if (!isOwnProfile)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _handleFollowToggle,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: state.isFollowing
                                              ? Colors.grey[300]
                                              : AppColors.primary,
                                        ),
                                        child: Text(
                                          state.isFollowing
                                              ? 'Unfollow'
                                              : 'Follow',
                                          style: TextStyle(
                                            color: state.isFollowing
                                                ? AppColors.primary
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.isFollowing &&
                                        user.accountType != 'business') ...[
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                userId: widget.userId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.chat_bubble_outline,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Tabs
                      SliverToBoxAdapter(
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(icon: Icon(Icons.grid_on)),
                            Tab(icon: Icon(Icons.movie)),
                            Tab(icon: Icon(Icons.play_circle_outline)),
                          ],
                        ),
                      ),

                      // Tab Content
                      BlocBuilder<PostBloc, PostState>(
                        builder: (context, postState) {
                          if (postState is PostUserPostsLoaded &&
                              postState.userId == widget.userId) {
                            return ProfilePostGrid(
                              posts: postState.posts,
                              tabController: _tabController,
                            );
                          }
                          return const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Something went wrong'));
            },
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
