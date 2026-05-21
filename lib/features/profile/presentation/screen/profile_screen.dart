import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';
import 'package:t_app/features/chat/presentation/cubit/direct_conversation_cubit.dart';
import 'package:t_app/features/chat/presentation/cubit/direct_conversation_state.dart';
import 'package:t_app/features/chat/presentation/screen/chat_thread_screen.dart';
import 'package:t_app/features/home/presentation/widget/create_post_card.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_detail_screen.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';
import 'package:t_app/features/profile/data/profile_mock_data.dart';
import 'package:t_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:t_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:t_app/features/profile/presentation/screen/profile_connections_screen.dart';
import 'package:t_app/features/settings/presentation/screen/settings_screen.dart';
import 'package:t_app/features/uploads/data/upload_image_result.dart';
import 'package:t_app/features/uploads/domain/uploads_image_repository.dart';
import 'package:t_app/features/users/data/user_profile.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ProfileScreen(
          userId: userId,
          bottomPadding: MediaQuery.paddingOf(context).bottom + 24,
          showBackButton: true,
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
    required this.bottomPadding,
    this.showBackButton = false,
  });

  final String userId;
  final double bottomPadding;
  final bool showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Chủ đề',
    'Câu trả lời',
    'File phương tiện',
    'Bài đăng lại',
  ];

  late final TabController _tabController;
  late final ProfileCubit _profileCubit;
  late final DirectConversationCubit _directConversationCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _profileCubit = ProfileCubit(
      repository: context.read<UsersProfileRepository>(),
    )..loadProfile(widget.userId);
    _directConversationCubit = DirectConversationCubit(
      repository: context.read<ChatRepository>(),
    );
  }

  @override
  void dispose() {
    _profileCubit.close();
    _directConversationCubit.close();
    _tabController.dispose();
    super.dispose();
  }

  void _openThreadDetail(ThreadItemModel thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailScreen(rootThread: thread),
      ),
    );
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _EditProfileSheet(
          profile: profile,
          uploadsRepository: context.read<UploadsImageRepository>(),
        );
      },
    );

    if (result == null) {
      return;
    }

    await _profileCubit.updateProfile(
      displayName: result.displayName,
      bio: result.bio,
      avatarUrl: result.avatarUrl,
    );
  }

  Future<void> _openMessage(UserProfile profile) {
    return _directConversationCubit.createDirectConversation(profile.id);
  }

  void _openConnections(ProfileConnectionsMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProfileConnectionsScreen(userId: widget.userId, mode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<DirectConversationCubit, DirectConversationState>(
      bloc: _directConversationCubit,
      listener: (context, state) {
        if (state.status == DirectConversationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Không thể mở cuộc trò chuyện.',
              ),
            ),
          );
          return;
        }

        final conversation = state.conversation;
        if (state.status == DirectConversationStatus.created &&
            conversation != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatThreadScreen(conversation: conversation),
            ),
          );
        }
      },
      child: BlocConsumer<ProfileCubit, ProfileState>(
        bloc: _profileCubit,
        listenWhen: (previous, current) {
          return previous.isSaving && !current.isSaving;
        },
        listener: (context, state) {
          final errorMessage = state.errorMessage;
          if (errorMessage != null && errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
            return;
          }

          final profile = state.profile;
          if (profile != null) {
            context.read<AuthCubit>().replaceUserProfile(profile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật trang cá nhân.')),
            );
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (state.status == ProfileStatus.loading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileStatus.failure && profile == null) {
            return _ProfileMessage(
              message: state.errorMessage ?? 'Không thể tải hồ sơ.',
            );
          }

          if (profile == null) {
            return const _ProfileMessage(message: 'Không thể tải hồ sơ.');
          }
          final currentUserId = context.read<AuthCubit>().state.user?.id;
          final isMe = currentUserId == profile.id;

          return DefaultTabController(
            length: _tabs.length,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ProfileTopBar(showBackButton: widget.showBackButton),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProfileHeaderSection(
                          profile: profile,
                          isMe: isMe,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProfileInterestChips(profile: profile),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProfileConnectionsSummary(
                          profile: profile,
                          onFollowersTap: () => _openConnections(
                            ProfileConnectionsMode.followers,
                          ),
                          onFollowingTap: () => _openConnections(
                            ProfileConnectionsMode.following,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<
                        DirectConversationCubit,
                        DirectConversationState
                      >(
                        bloc: _directConversationCubit,
                        builder: (context, conversationState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProfileActionButtons(
                              isMe: isMe,
                              isFollowing: profile.isFollowing,
                              isSaving: state.isSaving,
                              isFollowUpdating: state.isFollowUpdating,
                              isMessageLoading:
                                  conversationState.status ==
                                  DirectConversationStatus.creating,
                              onEditProfile: () => _openEditProfile(profile),
                              onShareProfile: () {},
                              onFollow: () =>
                                  _profileCubit.followUser(profile.id),
                              onUnfollow: () =>
                                  _profileCubit.unfollowUser(profile.id),
                              onMessage: () => _openMessage(profile),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ProfileTabsHeaderDelegate(
                    child: ColoredBox(
                      color: colorScheme.surface,
                      child: ProfileTabsSection(controller: _tabController),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _ProfileThreadsTab(
                    profile: profile,
                    threads: state.threads,
                    isMe: isMe,
                    onThreadTap: _openThreadDetail,
                    bottomPadding: widget.bottomPadding,
                  ),
                  const _ProfilePlaceholderTab(
                    label: 'Chưa có câu trả lời nào.',
                  ),
                  const _ProfilePlaceholderTab(
                    label: 'Chưa có file phương tiện nào.',
                  ),
                  const _ProfilePlaceholderTab(
                    label: 'Chưa có bài đăng lại nào.',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TopBarIconButton(
            icon: showBackButton
                ? Icons.arrow_back_rounded
                : Icons.bar_chart_rounded,
            onTap: showBackButton
                ? () => Navigator.of(context).maybePop()
                : () {},
          ),
          const Spacer(),
          _TopBarIconButton(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 10),
          _TopBarIconButton(icon: Icons.camera_alt_outlined, onTap: () {}),
          const SizedBox(width: 10),
          _TopBarIconButton(
            icon: Icons.menu_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 22,
      onTap: onTap,
      child: Icon(
        icon,
        size: 30,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    required this.profile,
    required this.isMe,
  });

  final UserProfile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      profile.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2442),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                profile.username,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(profile.bio ?? '', style: theme.textTheme.titleSmall),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: [
              Positioned(
                right: 0,
                child: AvatarView(user: _profileToUser(profile), radius: 40),
              ),
              if (isMe)
                Positioned(
                  left: 0,
                  bottom: 14,
                  child: _ProfileAddButton(
                    width: 38,
                    height: 38,
                    color: colorScheme.surface,
                    borderColor: colorScheme.outlineVariant.withValues(
                      alpha: 0.8,
                    ),
                    iconColor: colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

User _profileToUser(UserProfile profile) {
  return User(
    id: profile.id,
    name: profile.displayName,
    username: profile.username,
    avatarUrl: profile.avatarUrl,
  );
}

class ProfileInterestChips extends StatelessWidget {
  const ProfileInterestChips({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tags = profile.tags;

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tag = tags[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              tag,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ignore: unused_element
class _LegacyProfileFollowersPreview extends StatelessWidget {
  const _LegacyProfileFollowersPreview({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 28,
          child: Stack(
            children: List.generate(profileFollowerPreviewAssets.length, (
              index,
            ) {
              return Positioned(
                left: index * 18,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.surface,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(
                      profileFollowerPreviewAssets[index],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${profile.followersCount} người theo dõi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProfileConnectionsSummary extends StatelessWidget {
  const ProfileConnectionsSummary({
    super.key,
    required this.profile,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  final UserProfile profile;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        SizedBox(
          width: 72,
          height: 28,
          child: Stack(
            children: List.generate(profileFollowerPreviewAssets.length, (
              index,
            ) {
              return Positioned(
                left: index * 18,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.surface,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(
                      profileFollowerPreviewAssets[index],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        InkWell(
          onTap: onFollowersTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${profile.followersCount} nguoi theo doi',
              style: textStyle,
            ),
          ),
        ),
        InkWell(
          onTap: onFollowingTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${profile.followingCount} dang theo doi',
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileFollowersPreview extends StatelessWidget {
  const ProfileFollowersPreview({
    super.key,
    required this.profile,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  final UserProfile profile;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        SizedBox(
          width: 72,
          height: 28,
          child: Stack(
            children: List.generate(profileFollowerPreviewAssets.length, (
              index,
            ) {
              return Positioned(
                left: index * 18,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.surface,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: AssetImage(
                      profileFollowerPreviewAssets[index],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Text('${profile.followersCount} người theo dõi', style: textStyle),
        Text('${profile.followingCount} đang theo dõi', style: textStyle),
      ],
    );
  }
}

// ignore: unused_element
class _LegacyProfileActionButtons extends StatelessWidget {
  const _LegacyProfileActionButtons({
    required this.isSaving,
    required this.onEditProfile,
  });

  final bool isSaving;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onEditProfile,
      child: Row(
        children: [
          Expanded(
            child: _ProfileActionButton(label: 'Chỉnh sửa trang cá nhân'),
          ),
          const SizedBox(width: 12),
          Expanded(child: _ProfileActionButton(label: 'Chia sẻ trang cá nhân')),
        ],
      ),
    );
  }
}

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.isMe,
    required this.isFollowing,
    required this.isSaving,
    required this.isFollowUpdating,
    required this.isMessageLoading,
    required this.onEditProfile,
    required this.onShareProfile,
    required this.onFollow,
    required this.onUnfollow,
    required this.onMessage,
  });

  final bool isMe;
  final bool isFollowing;
  final bool isSaving;
  final bool isFollowUpdating;
  final bool isMessageLoading;
  final VoidCallback onEditProfile;
  final VoidCallback onShareProfile;
  final VoidCallback onFollow;
  final VoidCallback onUnfollow;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isMe
              ? _ProfileActionButton(
                  label: 'Chỉnh sửa trang cá nhân',
                  onTap: isSaving ? null : onEditProfile,
                  isLoading: isSaving,
                )
              : FollowButton(
                  isFollowing: isFollowing,
                  isLoading: isFollowUpdating,
                  onTap: isFollowing ? onUnfollow : onFollow,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isMe
              ? _ProfileActionButton(
                  label: 'Chia sẻ trang cá nhân',
                  onTap: onShareProfile,
                )
              : MessageButton(isLoading: isMessageLoading, onTap: onMessage),
        ),
      ],
    );
  }
}

class FollowButton extends StatelessWidget {
  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.isLoading,
    required this.onTap,
  });

  final bool isFollowing;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProfileActionButton(
      label: isFollowing ? 'Đang theo dõi' : 'Theo dõi',
      onTap: isLoading ? null : onTap,
      isLoading: isLoading,
      isPrimary: !isFollowing,
    );
  }
}

class MessageButton extends StatelessWidget {
  const MessageButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProfileActionButton(
      label: 'Nhắn tin',
      onTap: isLoading ? null : onTap,
      isLoading: isLoading,
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
  });

  final String displayName;
  final String? bio;
  final String? avatarUrl;
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.profile,
    required this.uploadsRepository,
  });

  final UserProfile profile;
  final UploadsImageRepository uploadsRepository;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _avatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (image == null) {
      return;
    }

    final contentType = image.mimeType ?? _guessImageMimeType(image.name);
    if (!_isSupportedImageType(contentType)) {
      _showMessage('Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final upload = await widget.uploadsRepository.uploadImage(
        fileName: image.name,
        bytes: await image.readAsBytes(),
        contentType: contentType,
        type: UploadImageType.profileAvatar,
      );

      if (!mounted) {
        return;
      }

      setState(() => _avatarUrl = upload.secureUrl);
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể tải ảnh lên. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _save() {
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();

    if (displayName.isEmpty) {
      _showMessage('Tên hiển thị không được để trống.');
      return;
    }

    Navigator.of(context).pop(
      _ProfileEditResult(
        displayName: displayName,
        bio: bio.isEmpty ? null : bio,
        avatarUrl: _avatarUrl,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Chỉnh sửa trang cá nhân',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AvatarView(
                  user: User(
                    id: widget.profile.id,
                    name: widget.profile.displayName,
                    username: widget.profile.username,
                    avatarUrl: _avatarUrl,
                  ),
                  radius: 42,
                ),
                if (_isUploading)
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isUploading ? null : _pickAvatar,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Đổi ảnh đại diện'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Tiểu sử',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _isUploading ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

String _guessImageMimeType(String fileName) {
  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  if (lowerName.endsWith('.webp')) {
    return 'image/webp';
  }

  return 'image/png';
}

bool _isSupportedImageType(String contentType) {
  return contentType == 'image/jpeg' ||
      contentType == 'image/png' ||
      contentType == 'image/webp';
}

class _ProfileAddButton extends StatelessWidget {
  const _ProfileAddButton({
    required this.width,
    required this.height,
    required this.color,
    required this.borderColor,
    required this.iconColor,
  });

  final double width;
  final double height;
  final Color color;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: borderColor),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(Icons.add_rounded, size: 28, color: iconColor),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const dashCount = 16;
    const gapRadians = 0.16;
    final radius = (size.width / 2) - 1.6;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * 3.141592653589793 / dashCount);
      final sweepAngle = (2 * 3.141592653589793 / dashCount) - gapRadians;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final foreground = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final background = isPrimary ? colorScheme.primary : colorScheme.surface;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isPrimary
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

class ProfileTabsSection extends StatelessWidget {
  const ProfileTabsSection({super.key, required this.controller});

  final TabController controller;

  static const _tabs = [
    'Chủ đề',
    'Câu trả lời',
    'File phương tiện',
    'Bài đăng lại',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: colorScheme.onSurface,
          indicatorWeight: 2,
          dividerColor: Theme.of(context).dividerColor,
          labelPadding: const EdgeInsets.only(left: 13, right: 13),
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ],
    );
  }
}

class ProfileComposerPreview extends StatelessWidget {
  const ProfileComposerPreview({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CreatePostCard(
        currentUser: User(
          id: profile.id,
          name: profile.displayName,
          username: profile.username,
          avatarUrl: profile.avatarUrl,
        ),
      ),
    );
  }
}

class _ProfileThreadsTab extends StatelessWidget {
  const _ProfileThreadsTab({
    required this.profile,
    required this.threads,
    required this.isMe,
    required this.onThreadTap,
    required this.bottomPadding,
  });

  final UserProfile profile;
  final List<ThreadItemModel> threads;
  final bool isMe;
  final ValueChanged<ThreadItemModel> onThreadTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: threads.length + (isMe ? 1 : 0),
      itemBuilder: (context, index) {
        if (isMe && index == 0) {
          return ProfileComposerPreview(profile: profile);
        }

        final thread = threads[index - (isMe ? 1 : 0)];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: ThreadItemWidget(
            thread: thread,
            onTap: () => onThreadTap(thread),
            onReplyTap: () => onThreadTap(thread),
            showReplyHint: false,
          ),
        );
      },
      separatorBuilder: (_, __) => const PostDivider(),
    );
  }
}

class _ProfilePlaceholderTab extends StatelessWidget {
  const _ProfilePlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ProfileTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileTabsHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 49;

  @override
  double get maxExtent => 49;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _ProfileTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
