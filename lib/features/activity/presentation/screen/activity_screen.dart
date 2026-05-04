import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/activity/data/models/activity_item_model.dart';
import 'package:t_app/features/activity/domain/notifications_activity_repository.dart';
import 'package:t_app/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:t_app/features/activity/presentation/cubit/activity_state.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_detail_screen.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';
import 'package:t_app/features/users/presentation/widgets/user_avatar_button.dart';
import 'package:t_app/features/users/presentation/widgets/user_name_button.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late ActivityFilter _activeFilter;
  late final ActivityCubit _activityCubit;

  @override
  void initState() {
    super.initState();
    _activeFilter = ActivityFilter.all;
    _activityCubit = ActivityCubit(
      notificationsRepository: context.read<NotificationsActivityRepository>(),
      usersRepository: context.read<UsersProfileRepository>(),
    )..loadNotifications();
  }

  @override
  void dispose() {
    _activityCubit.close();
    super.dispose();
  }

  List<ActivityItemModel> _filteredItems(List<ActivityItemModel> items) {
    switch (_activeFilter) {
      case ActivityFilter.all:
        return items;
      case ActivityFilter.follows:
        return items
            .where((item) => item.type == ActivityItemType.followSuggestion)
            .toList(growable: false);
      case ActivityFilter.conversations:
        return items
            .where(
              (item) => item.type == ActivityItemType.contentRecommendation,
            )
            .toList(growable: false);
    }
  }

  void _openThread(ActivityItemModel item) {
    if (item.thread == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailScreen(rootThread: item.thread!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      bloc: _activityCubit,
      builder: (context, state) {
        final items = _filteredItems(state.items);

        return ListView.separated(
          padding: EdgeInsets.only(top: 18, bottom: widget.bottomPadding),
          itemCount: items.length + 2,
          separatorBuilder: (_, index) =>
              index < 2 ? const SizedBox.shrink() : const PostDivider(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ActivityHeader(
                activeFilter: _activeFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
              );
            }

            if (index == 1) {
              if (state.status == ActivityStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.only(top: 36),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == ActivityStatus.failure) {
                return _ActivityMessage(
                  message: state.errorMessage ?? 'Unable to load activity.',
                );
              }

              if (items.isEmpty) {
                return const _ActivityMessage(
                  message: 'Chưa có hoạt động nào.',
                );
              }

              return const SizedBox(height: 8);
            }

            final item = items[index - 2];
            switch (item.type) {
              case ActivityItemType.followSuggestion:
                return FollowSuggestionActivityItem(
                  item: item,
                  onFollowTap: () => _activityCubit.toggleFollow(item),
                );
              case ActivityItemType.contentRecommendation:
                return ContentRecommendationActivityItem(
                  item: item,
                  onTap: () => _openThread(item),
                );
            }
          },
        );
      },
    );
  }
}

class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ActivityHeader extends StatelessWidget {
  const ActivityHeader({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final ActivityFilter activeFilter;
  final ValueChanged<ActivityFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 18),
          ActivityFilterChips(
            activeFilter: activeFilter,
            onChanged: onFilterChanged,
          ),
        ],
      ),
    );
  }
}

class ActivityFilterChips extends StatelessWidget {
  const ActivityFilterChips({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  final ActivityFilter activeFilter;
  final ValueChanged<ActivityFilter> onChanged;

  static const _entries = [
    (ActivityFilter.all, 'Tất cả'),
    (ActivityFilter.follows, 'Lượt theo dõi'),
    (ActivityFilter.conversations, 'Cuộc trò chuyện'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _entries
            .map((entry) {
              final isActive = activeFilter == entry.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onChanged(entry.$1),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Text(
                      entry.$2,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class FollowSuggestionActivityItem extends StatelessWidget {
  const FollowSuggestionActivityItem({
    super.key,
    required this.item,
    required this.onFollowTap,
  });

  final ActivityItemModel item;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityAvatar(item: item, radius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: UserNameButton(
                          userId: item.user.id,
                          label: item.user.username,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timestampLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _FollowButton(isFollowed: item.isFollowed, onTap: onFollowTap),
        ],
      ),
    );
  }
}

class ContentRecommendationActivityItem extends StatelessWidget {
  const ContentRecommendationActivityItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ActivityItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActivityAvatar(item: item, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: UserNameButton(
                                    userId: item.user.id,
                                    label: item.user.username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.timestampLabel,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (item.contentPreview != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.contentPreview!,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      height: 1.35,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Icon(
                            Icons.more_horiz_rounded,
                            size: 22,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 14),
                          if (item.mediaThumbnail != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                item.mediaThumbnail!,
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (item.thread != null) ...[
                    const SizedBox(height: 14),
                    ThreadActionsRow(thread: item.thread!, onReplyTap: onTap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityAvatar extends StatelessWidget {
  const _ActivityAvatar({required this.item, required this.radius});

  final ActivityItemModel item;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        UserAvatarButton(
          userId: item.user.id,
          avatarUrl: item.user.avatarUrl,
          avatarAssetPath: item.user.avatarAssetPath,
          displayName: item.user.name,
          username: item.user.username,
          size: radius * 2,
        ),
        if (item.hasPurpleBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowed, required this.onTap});

  final bool isFollowed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFollowed ? colorScheme.surfaceContainerHigh : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFollowed
                ? colorScheme.outlineVariant.withValues(alpha: 0.45)
                : Colors.white,
          ),
        ),
        child: Text(
          isFollowed ? 'Đang theo dõi' : 'Theo dõi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isFollowed ? colorScheme.onSurface : Colors.black,
          ),
        ),
      ),
    );
  }
}
