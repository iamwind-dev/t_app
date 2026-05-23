import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/core/theme/theme_mode_cubit.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/settings/presentation/screen/change_password_screen.dart';
import 'package:t_app/features/settings/presentation/screen/privacy_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedThemeMode = context.select(
      (ThemeModeCubit cubit) => cubit.state,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            _SettingsHeader(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 8),
            _SettingsSection(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Tài khoản',
                  subtitle: 'Thông tin cá nhân, bảo mật và xác minh',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Quyền riêng tư',
                  subtitle:
                      'Người theo dõi, nhắc đến và trạng thái hoạt động',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacySettingsScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo',
                  subtitle: 'Lượt thích, phản hồi, tin nhắn và đề xuất',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              children: [
                _ThemeModeTile(selectedThemeMode: selectedThemeMode),
                _SettingsTile(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Đã lưu',
                  subtitle: 'Xem lại chủ đề và bài viết bạn đã lưu',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Lượt thích của bạn',
                  subtitle: 'Quản lý các nội dung bạn đã thích',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Trợ giúp',
                  subtitle: 'Trung tâm trợ giúp và báo cáo sự cố',
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Giới thiệu',
                  subtitle: 'Điều khoản, chính sách và thông tin ứng dụng',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsSection(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Đăng xuất',
                  titleColor: colorScheme.error,
                  showChevron: false,
                  onTap: () => _confirmLogout(context),
                ),
              ],
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

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất?'),
          content: const Text('Bạn sẽ quay lại màn hình đăng nhập.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    Navigator.of(context).pop();
    await context.read<AuthCubit>().logOut();
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

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
                'Cài đặt',
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.showChevron = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final bool showChevron;
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
            Icon(icon, size: 25, color: titleColor ?? colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? colorScheme.onSurface,
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
            if (showChevron) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.selectedThemeMode});

  final ThemeMode selectedThemeMode;

  @override
  Widget build(BuildContext context) {
    final label = switch (selectedThemeMode) {
      ThemeMode.system => 'Theo hệ thống',
      ThemeMode.light => 'Sáng',
      ThemeMode.dark => 'Tối',
    };

    return _SettingsTile(
      icon: Icons.dark_mode_outlined,
      title: 'Giao diện',
      subtitle: label,
      onTap: () => _showThemeModeSheet(context),
    );
  }

  Future<void> _showThemeModeSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final selected = sheetContext.select(
          (ThemeModeCubit cubit) => cubit.state,
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeModeOption(
                value: ThemeMode.system,
                selected: selected,
                label: 'Theo hệ thống',
              ),
              _ThemeModeOption(
                value: ThemeMode.light,
                selected: selected,
                label: 'Sáng',
              ),
              _ThemeModeOption(
                value: ThemeMode.dark,
                selected: selected,
                label: 'Tối',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.value,
    required this.selected,
    required this.label,
  });

  final ThemeMode value;
  final ThemeMode selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = value == selected;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: colorScheme.primary)
          : null,
      onTap: () {
        context.read<ThemeModeCubit>().setThemeMode(value);
        Navigator.of(context).pop();
      },
    );
  }
}
