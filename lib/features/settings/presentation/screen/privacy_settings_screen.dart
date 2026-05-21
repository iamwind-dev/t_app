import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isPrivateProfile = false;
  bool _showActivityStatus = true;
  bool _allowMessageRequests = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            _PrivacyHeader(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 6),
            _PrivacySwitchTile(
              icon: Icons.lock_outline_rounded,
              title: 'Trang cá nhân riêng tư',
              subtitle:
                  'Chỉ người theo dõi đã được duyệt mới xem được chủ đề của bạn.',
              value: _isPrivateProfile,
              onChanged: (value) {
                setState(() => _isPrivateProfile = value);
              },
            ),
            const _PrivacyDivider(),
            _PrivacySwitchTile(
              icon: Icons.circle_outlined,
              title: 'Trạng thái hoạt động',
              subtitle: 'Cho người khác biết khi bạn đang hoạt động.',
              value: _showActivityStatus,
              onChanged: (value) {
                setState(() => _showActivityStatus = value);
              },
            ),
            const _PrivacyDivider(),
            _PrivacySwitchTile(
              icon: Icons.mail_outline_rounded,
              title: 'Yêu cầu nhắn tin',
              subtitle: 'Cho phép người bạn không theo dõi gửi yêu cầu tin nhắn.',
              value: _allowMessageRequests,
              onChanged: (value) {
                setState(() => _allowMessageRequests = value);
              },
            ),
            const SizedBox(height: 18),
            const _PrivacySectionTitle('Tương tác'),
            _PrivacyTile(
              icon: Icons.alternate_email_rounded,
              title: 'Lượt nhắc đến',
              subtitle: 'Mọi người',
              onTap: () => _showComingSoon(context),
            ),
            _PrivacyTile(
              icon: Icons.reply_outlined,
              title: 'Trả lời',
              subtitle: 'Người theo dõi bạn',
              onTap: () => _showComingSoon(context),
            ),
            _PrivacyTile(
              icon: Icons.repeat_rounded,
              title: 'Đăng lại',
              subtitle: 'Cho phép đăng lại chủ đề của bạn',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 18),
            const _PrivacySectionTitle('Nội dung bạn thấy'),
            _PrivacyTile(
              icon: Icons.volume_off_outlined,
              title: 'Tài khoản đã tắt tiếng',
              onTap: () => _showComingSoon(context),
            ),
            _PrivacyTile(
              icon: Icons.visibility_off_outlined,
              title: 'Từ bị ẩn',
              subtitle: 'Ẩn bình luận và chủ đề chứa từ bạn chọn',
              onTap: () => _showComingSoon(context),
            ),
            _PrivacyTile(
              icon: Icons.block_rounded,
              title: 'Trang cá nhân bị chặn',
              onTap: () => _showComingSoon(context),
            ),
            const SizedBox(height: 18),
            const _PrivacySectionTitle('Kết nối'),
            _PrivacyTile(
              icon: Icons.group_outlined,
              title: 'Trang cá nhân bạn theo dõi',
              onTap: () => _showComingSoon(context),
            ),
            _PrivacyTile(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Đồng bộ người liên hệ',
              subtitle: 'Tìm bạn bè từ danh bạ của bạn',
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng này sẽ được cập nhật sau.')),
    );
  }
}

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Quay lại',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Quyền riêng tư',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _PrivacySectionTitle extends StatelessWidget {
  const _PrivacySectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        child: Row(
          children: [
            Icon(icon, size: 25, color: colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySwitchTile extends StatelessWidget {
  const _PrivacySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
      child: Row(
        children: [
          Icon(icon, size: 25, color: colorScheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _PrivacyDivider extends StatelessWidget {
  const _PrivacyDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 57),
      child: Divider(height: 1, color: Theme.of(context).dividerColor),
    );
  }
}
