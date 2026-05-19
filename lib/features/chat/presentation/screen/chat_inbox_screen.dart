import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_app/core/keys/chat/chat_widget_keys.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';
import 'package:t_app/features/chat/presentation/cubit/chat_inbox_cubit.dart';
import 'package:t_app/features/chat/presentation/cubit/chat_inbox_state.dart';
import 'package:t_app/features/users/presentation/widgets/user_avatar_button.dart';
import 'package:t_app/features/users/presentation/widgets/user_name_button.dart';

import '../theme/chat_inbox_tokens.dart';
import 'chat_thread_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  late final ChatInboxCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChatInboxCubit(repository: context.read<ChatRepository>())
      ..loadConversations();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openConversation(ChatConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatThreadScreen(conversation: conversation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ChatInboxTokens.pageBackground(context),
      child: BlocBuilder<ChatInboxCubit, ChatInboxState>(
        bloc: _cubit,
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.only(
              top: ChatInboxTokens.headerTopPadding,
              bottom: widget.bottomPadding,
            ),
            children: [
              const _InboxHeader(),
              const SizedBox(height: ChatInboxTokens.titleToSearchGap),
              const _InboxSearchField(),
              const SizedBox(height: ChatInboxTokens.searchToFiltersGap),
              const _InboxFilters(),
              const SizedBox(height: ChatInboxTokens.filtersToListGap),
              if (state.status == ChatInboxStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (state.status == ChatInboxStatus.failure)
                _InboxMessage(
                  message: state.errorMessage ?? 'Không thể tải tin nhắn.',
                )
              else if (state.conversations.isEmpty)
                const _InboxMessage(message: 'Chưa có cuộc trò chuyện nào.')
              else
                ...state.conversations.map(
                  (conversation) => _InboxPreviewTile(
                    conversation: conversation,
                    onTap: () => _openConversation(conversation),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InboxHeader extends StatelessWidget {
  const _InboxHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatInboxTokens.horizontalPadding,
      ),
      child: SizedBox(
        height: ChatInboxTokens.headerHeight,
        child: Row(
          children: [
            Expanded(
              child: Text('Tin nhắn', style: ChatInboxTokens.title(context)),
            ),
            SizedBox.square(
              dimension: 48,
              child: Center(
                child: SizedBox(
                  width: 31,
                  height: 31,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 4,
                        bottom: 5,
                        child: _TintedSvg(
                          assetPath: 'assets/icons/chat_inbox_compose_line.svg',
                          width: 14.4,
                          height: 2.4,
                          color: ChatInboxTokens.primaryText(context),
                        ),
                      ),
                      Positioned(
                        left: 2,
                        top: 2,
                        child: _TintedSvg(
                          assetPath: 'assets/icons/chat_inbox_compose_pen.svg',
                          width: 25.2,
                          height: 25.2,
                          color: ChatInboxTokens.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxSearchField extends StatelessWidget {
  const _InboxSearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatInboxTokens.horizontalPadding,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ChatInboxTokens.searchFieldBackground(context),
          borderRadius: ChatInboxTokens.searchBorderRadius,
        ),
        child: SizedBox(
          height: ChatInboxTokens.searchHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ChatInboxTokens.searchHorizontalPadding,
            ),
            child: Row(
              children: [
                _TintedSvg(
                  assetPath: 'assets/icons/chat_inbox_search.svg',
                  width: ChatInboxTokens.searchIconSize,
                  height: ChatInboxTokens.searchIconSize,
                  color: ChatInboxTokens.mutedIcon(context),
                ),
                const SizedBox(width: ChatInboxTokens.searchIconGap),
                Text('Tìm kiếm', style: ChatInboxTokens.searchHint(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InboxFilters extends StatelessWidget {
  const _InboxFilters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: ChatInboxTokens.horizontalPadding,
      ),
      child: const Row(
        children: [
          _FilterIconChip(),
          SizedBox(width: ChatInboxTokens.filterGap),
          _FilterTextChip(label: 'Hộp thư', width: 106, isSelected: true),
          SizedBox(width: ChatInboxTokens.filterGap),
          _FilterTextChip(label: 'Tin nhắn đang chờ', width: 158),
        ],
      ),
    );
  }
}

class _FilterIconChip extends StatelessWidget {
  const _FilterIconChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChatInboxTokens.pageBackground(context),
        borderRadius: ChatInboxTokens.chipBorderRadius,
        border: Border.all(color: ChatInboxTokens.chipBorder(context)),
      ),
      child: SizedBox(
        width: 45,
        height: 31,
        child: Center(
          child: _TintedSvg(
            assetPath: 'assets/icons/chat_inbox_filter.svg',
            width: 18,
            height: 18,
            color: ChatInboxTokens.primaryText(context),
          ),
        ),
      ),
    );
  }
}

class _FilterTextChip extends StatelessWidget {
  const _FilterTextChip({
    required this.label,
    required this.width,
    this.isSelected = false,
  });

  final String label;
  final double width;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected
            ? ChatInboxTokens.chipBackground(context)
            : ChatInboxTokens.pageBackground(context),
        borderRadius: ChatInboxTokens.chipBorderRadius,
        border: Border.all(color: ChatInboxTokens.chipBorder(context)),
      ),
      child: SizedBox(
        width: width,
        height: ChatInboxTokens.filterHeight,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            style: ChatInboxTokens.chipLabel(context),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _InboxPreviewTile extends StatelessWidget {
  const _InboxPreviewTile({required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';
    final user = conversation.otherMember(currentUserId)?.user;
    final title = user?.username ?? 'Không xác định';
    final subtitle = conversation.lastMessage?.text ?? 'Chưa có tin nhắn';

    return GestureDetector(
      key: ChatWidgetKeys.inboxConversationPreview,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ChatInboxTokens.horizontalPadding,
          0,
          ChatInboxTokens.horizontalPadding,
          18,
        ),
        child: Row(
          children: [
            UserAvatarButton(
              userId: user?.id ?? '',
              avatarUrl: user?.avatarUrl,
              avatarAssetPath:
                  (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                  ? 'assets/images/chat_inbox_avatar.png'
                  : null,
              displayName: user?.displayName,
              username: user?.username,
              size: ChatInboxTokens.avatarSize,
            ),
            const SizedBox(width: ChatInboxTokens.previewTextGap),
            Expanded(
              child: SizedBox(
                height: ChatInboxTokens.avatarSize,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserNameButton(
                      userId: user?.id ?? '',
                      label: title,
                      style: ChatInboxTokens.username(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$subtitle - ${conversation.unreadCount} mới',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ChatInboxTokens.metadata(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatInboxTokens.horizontalPadding,
        vertical: 24,
      ),
      child: Text(
        message,
        style: ChatInboxTokens.metadata(context),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TintedSvg extends StatelessWidget {
  const _TintedSvg({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.color,
  });

  final String assetPath;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
