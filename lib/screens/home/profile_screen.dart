import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // Generate initials from full name
  String _getInitials(String fullName) {
    List<String> names = fullName.trim().split(' ');
    if (names.isEmpty) return '?';
    
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }
    
    return (names[0].substring(0, 1) + names[names.length - 1].substring(0, 1))
        .toUpperCase();
  }

  // Generate random color based on name (consistent for same name)
  Color _getRandomColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    return colors[hash.abs() % colors.length];
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
                            // Cover Photo and Profile Section
                            SizedBox(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Cover Photo or Placeholder
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

                                  Positioned(
                                    left: 16,
                                    bottom: -80,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage:
                                                      CachedImageProvider(
                                                    user.profilePicture!.url,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 30),
                                            Row(
                                              children: [
                                                Text(
                                                  user.fullName,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (isOwnProfile)
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              EditProfileScreen(
                                                            user: user,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child: Icon(
                                                        Icons.edit_outlined,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Text(
                                              '@${user.username}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),

                                            if (user.bio.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                  right: 14,
                                                ),
                                                child: Text(
                                                  user.bio,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 100),
                            // Stats
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
                            const SizedBox(height: 14),
                            // Action Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  if (!isOwnProfile)
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