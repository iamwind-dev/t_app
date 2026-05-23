import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/data/shared_reel_message.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';
import 'package:t_app/features/reels/domain/entities/reel.dart';

Future<void> showShareReelSheet(
  BuildContext context, {
  required Reel reel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _ShareReelSheet(reel: reel);
    },
  );
}

class _ShareReelSheet extends StatefulWidget {
  const _ShareReelSheet({required this.reel});

  final Reel reel;

  @override
  State<_ShareReelSheet> createState() => _ShareReelSheetState();
}

class _ShareReelSheetState extends State<_ShareReelSheet> {
  late final Future<List<ChatConversation>> _conversationsFuture;
  String? _sendingConversationId;

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _loadRecentConversations();
  }

  Future<List<ChatConversation>> _loadRecentConversations() async {
    final page = await context.read<ChatRepository>().listConversations();
    return page.items;
  }

  Future<void> _shareToConversation(ChatConversation conversation) async {
    if (_sendingConversationId != null) {
      return;
    }

    setState(() {
      _sendingConversationId = conversation.id;
    });

    try {
      final recipientUsername =
          conversation.otherMember(_currentUserId(context))?.user.username ??
          'message';

      await context.read<ChatRepository>().sendTextMessage(
        conversationId: conversation.id,
        text: encodeSharedReelMessage(widget.reel),
      );

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Shared to $recipientUsername.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot share reel right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _sendingConversationId = null;
      });
    }
  }

  String _currentUserId(BuildContext context) {
    return context.read<AuthCubit>().state.user?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final height = MediaQuery.sizeOf(context).height * 0.46;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Share',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Recent messages',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<ChatConversation>>(
                future: _conversationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 92,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final conversations = snapshot.data ?? const <ChatConversation>[];
                  if (conversations.isEmpty) {
                    return Container(
                      height: 92,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No recent conversations yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final user = conversation
                            .otherMember(_currentUserId(context))
                            ?.user;
                        final isSending = _sendingConversationId == conversation.id;

                        return _ShareAvatarTile(
                          username: user?.username ?? 'User',
                          avatarUrl: user?.avatarUrl,
                          isSending: isSending,
                          onTap: () => _shareToConversation(conversation),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Share to',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 88,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _PlatformShareTile(
                      icon: Icons.link_rounded,
                      label: 'Copy link',
                    ),
                    SizedBox(width: 12),
                    _PlatformShareTile(
                      icon: Icons.sms_outlined,
                      label: 'Messages',
                    ),
                    SizedBox(width: 12),
                    _PlatformShareTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Stories',
                    ),
                    SizedBox(width: 12),
                    _PlatformShareTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'More',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareAvatarTile extends StatelessWidget {
  const _ShareAvatarTile({
    required this.username,
    required this.avatarUrl,
    required this.isSending,
    required this.onTap,
  });

  final String username;
  final String? avatarUrl;
  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isSending ? null : onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: avatarUrl == null || avatarUrl!.isEmpty
                      ? Text(
                          username.isEmpty ? '?' : username[0].toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (isSending)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformShareTile extends StatelessWidget {
  const _PlatformShareTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
