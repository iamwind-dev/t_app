import 'package:flutter/material.dart';
import 'package:t_app/features/home/presentation/cubits/home_state.dart';
import 'package:t_app/features/home/presentation/widget/create_post_card.dart';
import 'package:t_app/features/home/presentation/widget/post_divider.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/presentation/screen/thread_detail_screen.dart';
import 'package:t_app/features/post_detail/presentation/widget/avatar_view.dart';
import 'package:t_app/features/post_detail/presentation/widget/thread_item_widget.dart';
import 'package:t_app/features/profile/data/profile_mock_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.bottomPadding,
  });

  final double bottomPadding;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    'Thread',
    'Câu trả lời',
    'File phương tiện',
    'Bài đăng lại',
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: _tabs.length,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const ProfileTopBar(),
                const SizedBox(height: 22),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileHeaderSection(),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileInterestChips(),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileFollowersPreview(),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileActionButtons(),
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
              onThreadTap: _openThreadDetail,
              bottomPadding: widget.bottomPadding,
            ),
            const _ProfilePlaceholderTab(label: 'Chưa có câu trả lời nào.'),
            const _ProfilePlaceholderTab(label: 'Chưa có file phương tiện nào.'),
            const _ProfilePlaceholderTab(label: 'Chưa có bài đăng lại nào.'),
          ],
        ),
      ),
    );
  }
}

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TopBarIconButton(
            icon: Icons.bar_chart_rounded,
            onTap: () {},
          ),
          const Spacer(),
          _TopBarIconButton(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 10),
          _TopBarIconButton(icon: Icons.camera_alt_outlined, onTap: () {}),
          const SizedBox(width: 10),
          _TopBarIconButton(icon: Icons.menu_rounded, onTap: () {}),
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
  const ProfileHeaderSection({super.key});

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
                      profileUser.name,
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
                profileUser.username,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profileBio,
                style: theme.textTheme.titleSmall,
              ),
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
                child: AvatarView(user: profileUser, radius: 40),
              ),
              Positioned(
                left: 0,
                bottom: 14,
                child: _ProfileAddButton(
                  width: 38,
                  height: 38,
                  color: colorScheme.surface,
                  borderColor: colorScheme.outlineVariant.withValues(alpha: 0.8),
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

class ProfileInterestChips extends StatelessWidget {
  const ProfileInterestChips({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profileInterestTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tag = profileInterestTags[index];
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

class ProfileFollowersPreview extends StatelessWidget {
  const ProfileFollowersPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 28,
          child: Stack(
            children: List.generate(profileFollowerPreviewAssets.length, (index) {
              return Positioned(
                left: index * 18,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.surface,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage:
                        AssetImage(profileFollowerPreviewAssets[index]),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$profileFollowersCount người theo dõi',
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

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _ProfileActionButton(label: 'Chỉnh sửa trang cá nhân')),
        SizedBox(width: 12),
        Expanded(child: _ProfileActionButton(label: 'Chia sẻ trang cá nhân')),
      ],
    );
  }
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
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.add_rounded,
          size: 28,
          color: iconColor,
        ),
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
  const _ProfileActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ProfileTabsSection extends StatelessWidget {
  const ProfileTabsSection({super.key, required this.controller});

  final TabController controller;

  static const _tabs = [
    'Thread',
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
          unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14
          ),
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ],
    );
  }
}

class ProfileComposerPreview extends StatelessWidget {
  const ProfileComposerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return CreatePostCard(
      currentUser: const FeedUser(
        username: '__win.d',
        avatarAsset: 'assets/images/home_avatar_payal.png',
      ),
    );
  }
}

class _ProfileThreadsTab extends StatelessWidget {
  const _ProfileThreadsTab({
    required this.onThreadTap,
    required this.bottomPadding,
  });

  final ValueChanged<ThreadItemModel> onThreadTap;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: profileThreads.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const ProfileComposerPreview();
        }

        final thread = profileThreads[index - 1];
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
