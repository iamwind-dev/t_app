import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/users/data/user_profile.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';
import 'package:t_app/features/users/presentation/widgets/user_avatar_button.dart';
import 'package:t_app/features/users/presentation/widgets/user_name_button.dart';

enum ProfileConnectionsMode { followers, following }

class ProfileConnectionsScreen extends StatefulWidget {
  const ProfileConnectionsScreen({
    super.key,
    required this.userId,
    required this.mode,
  });

  final String userId;
  final ProfileConnectionsMode mode;

  @override
  State<ProfileConnectionsScreen> createState() =>
      _ProfileConnectionsScreenState();
}

class _ProfileConnectionsScreenState extends State<ProfileConnectionsScreen> {
  late final UsersProfileRepository _repository;
  List<UserProfile> _items = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = context.read<UsersProfileRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = switch (widget.mode) {
        ProfileConnectionsMode.followers => await _repository.getFollowers(
          widget.userId,
        ),
        ProfileConnectionsMode.following => await _repository.getFollowing(
          widget.userId,
        ),
      };
      if (!mounted) {
        return;
      }

      setState(() {
        _items = page.items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Không thể tải danh sách.';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(UserProfile profile) async {
    final updated = profile.isFollowing
        ? await _repository.unfollowUser(profile.id)
        : await _repository.followUser(profile.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _items = _items
          .map((item) => item.id == profile.id ? updated : item)
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == ProfileConnectionsMode.followers
        ? 'Người theo dõi'
        : 'Đang theo dõi';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                itemBuilder: (context, index) {
                  final profile = _items[index];
                  return ListTile(
                    leading: UserAvatarButton(
                      userId: profile.id,
                      avatarUrl: profile.avatarUrl,
                      displayName: profile.displayName,
                      username: profile.username,
                      size: 44,
                    ),
                    title: UserNameButton(
                      userId: profile.id,
                      label: profile.username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(profile.displayName),
                    trailing: FilledButton.tonal(
                      onPressed: () => _toggleFollow(profile),
                      child: Text(
                        profile.isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
