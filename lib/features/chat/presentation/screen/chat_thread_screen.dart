import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_app/core/keys/chat/chat_widget_keys.dart';
import 'package:t_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/data/chat_message.dart';
import 'package:t_app/features/chat/data/chat_socket_service.dart';
import 'package:t_app/features/chat/data/chat_user.dart';
import 'package:t_app/features/chat/domain/chat_repository.dart';
import 'package:t_app/features/chat/presentation/cubit/chat_thread_cubit.dart';
import 'package:t_app/features/chat/presentation/cubit/chat_thread_state.dart';

import '../theme/chat_thread_tokens.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, required this.conversation});

  final ChatConversation conversation;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final ChatThreadCubit _cubit;

  @override
  void initState() {
    super.initState();
    final currentUserId =
        context.read<AuthCubit>().state.user?.id ?? 'current_user';
    _cubit =
        ChatThreadCubit(
            repository: context.read<ChatRepository>(),
            socketService: context.read<ChatSocketService>(),
            conversation: widget.conversation,
            currentUserId: currentUserId,
          )
          ..attachSocketListeners()
          ..loadMessages();
    unawaited(_cubit.joinRealtime());
  }

  @override
  void dispose() {
    unawaited(_cubit.leaveRealtime());
    _cubit.close();
    super.dispose();
  }

  /// Confirms deletion before calling the REST-backed delete flow.
  Future<void> _handleDeleteMessage(ChatMessage message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tin nhắn?'),
          content: const Text('Tin nhắn này sẽ bị xóa khỏi cuộc trò chuyện của bạn và người nhận.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final errorMessage = await _cubit.deleteMessage(message);
    if (errorMessage == null || !mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ChatThreadCubit, ChatThreadState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ChatThreadTokens.pageBackground(context),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _ConversationHeader(
                    conversation: state.conversation,
                    currentUserId: state.currentUserId,
                  ),
                  Expanded(
                    child: _ConversationBody(
                      state: state,
                      onDeleteMessage: _handleDeleteMessage,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _MessageComposer(
              onSend: context.read<ChatThreadCubit>().sendMessage,
              onTypingStart: () {
                unawaited(context.read<ChatThreadCubit>().typingStart());
              },
              onTypingStop: () {
                unawaited(context.read<ChatThreadCubit>().typingStop());
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({
    required this.conversation,
    required this.currentUserId,
  });

  final ChatConversation conversation;
  final String currentUserId;

  ChatUser? get _user => conversation.otherMember(currentUserId)?.user;

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return SizedBox(
      height: ChatThreadTokens.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ChatThreadTokens.headerHorizontalPadding,
        ),
        child: Row(
          children: [
            _HeaderIconButton(
              key: ChatWidgetKeys.conversationBackButton,
              assetPath: 'assets/icons/chat_thread_back.svg',
              size: ChatThreadTokens.headerBackSize,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: ChatThreadTokens.headerBackToAvatarGap),
            _CircleAvatarImage(
              user: user,
              size: ChatThreadTokens.headerAvatarSize,
            ),
            const SizedBox(width: ChatThreadTokens.headerAvatarToTextGap),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Không xác định',
                    style: ChatThreadTokens.headerUsername(context),
                  ),
                  // Text(
                  //   user?.displayName ?? '',
                  //   style: ChatThreadTokens.headerName(context),
                  // ),
                ],
              ),
            ),
            const _MoreButton(),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    super.key,
    required this.assetPath,
    required this.size,
    required this.onTap,
  });

  final String assetPath;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.square(
        dimension: ChatThreadTokens.headerActionSize,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _TintedSvg(
            assetPath: assetPath,
            width: size,
            height: size,
            color: ChatThreadTokens.primaryText(context),
          ),
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: ChatThreadTokens.headerActionSize,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : ChatThreadTokens.headerMoreDotGap,
              ),
              child: _TintedSvg(
                assetPath: 'assets/icons/chat_thread_dot.svg',
                width: ChatThreadTokens.headerMoreDotSize,
                height: ChatThreadTokens.headerMoreDotSize,
                color: ChatThreadTokens.primaryText(context),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ConversationBody extends StatefulWidget {
  const _ConversationBody({required this.state, required this.onDeleteMessage});

  final ChatThreadState state;
  final ValueChanged<ChatMessage> onDeleteMessage;

  @override
  State<_ConversationBody> createState() => _ConversationBodyState();
}

class _ConversationBodyState extends State<_ConversationBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 100) {
      context.read<ChatThreadCubit>().loadOlderMessages();
    }
  }

  @override
  void didUpdateWidget(covariant _ConversationBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.isLoadingOlder &&
        !widget.state.isLoadingOlder &&
        widget.state.messages.length > oldWidget.state.messages.length) {
      if (_scrollController.hasClients) {
        final oldMaxScroll = _scrollController.position.maxScrollExtent;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          final newMaxScroll = _scrollController.position.maxScrollExtent;
          if (newMaxScroll > oldMaxScroll) {
            final diff = newMaxScroll - oldMaxScroll;
            _scrollController.jumpTo(_scrollController.offset + diff);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.status == ChatThreadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.state.status == ChatThreadStatus.failure && widget.state.messages.isEmpty) {
      return Center(
        child: Text(
          widget.state.errorMessage ?? 'Không thể tải tin nhắn.',
          style: ChatThreadTokens.profileMeta(context),
        ),
      );
    }

    if (widget.state.messages.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tin nhắn nào.',
          style: ChatThreadTokens.profileMeta(context),
        ),
      );
    }

    String? lastMineId;
    for (final message in widget.state.messages) {
      if (message.sender.id == widget.state.currentUserId) {
        lastMineId = message.id;
        break;
      }
    }

    final showLoadingIndicator = widget.state.hasMoreOlder || widget.state.isLoadingOlder;
    final totalItemsCount = widget.state.messages.length + (showLoadingIndicator ? 1 : 0);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.only(
              bottom: ChatThreadTokens.bodyBottomGap,
            ),
            itemCount: totalItemsCount,
            itemBuilder: (context, index) {
              if (showLoadingIndicator && index == widget.state.messages.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: widget.state.isLoadingOlder
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              }

              final message = widget.state.messages[index];
              final isMine = message.sender.id == widget.state.currentUserId;
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: isMine
                    ? _OutgoingMessage(
                        message: message,
                        showStatus: message.id == lastMineId,
                        onLongPress: () => widget.onDeleteMessage(message),
                      )
                    : _IncomingMessage(message: message),
              );
            },
          ),
        ),
        _TypingIndicator(typingUsers: widget.state.typingUsers),
      ],
    );
  }
}


class _IncomingMessage extends StatelessWidget {
  const _IncomingMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatThreadTokens.messageRowHorizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _CircleAvatarImage(
            user: message.sender,
            size: ChatThreadTokens.messageAvatarSize,
          ),
          const SizedBox(width: ChatThreadTokens.incomingBubbleGap),
          Flexible(
            child: _Bubble(
              text: message.displayContent,
              backgroundColor: ChatThreadTokens.incomingBubble(context),
              textStyle: ChatThreadTokens.message(context),
              borderRadius: ChatThreadTokens.incomingBubbleBorderRadius,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutgoingMessage extends StatelessWidget {
  const _OutgoingMessage({
    required this.message,
    required this.showStatus,
    required this.onLongPress,
  });

  final ChatMessage message;
  final bool showStatus;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 80,
        right: ChatThreadTokens.outgoingRightPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
            child: _Bubble(
              text: message.displayContent,
              backgroundColor: ChatThreadTokens.outgoingBubble(context),
              textStyle: ChatThreadTokens.outgoingMessage(context),
              borderRadius: ChatThreadTokens.outgoingBubbleBorderRadius,
            ),
          ),
          if (showStatus) ...[
            const SizedBox(height: 4),
            Text(
              _statusText(message.status),
              style: ChatThreadTokens.profileMeta(context),
            ),
          ],
        ],
      ),
    );
  }

  String _statusText(MessageDeliveryStatus status) {
    return switch (status) {
      MessageDeliveryStatus.sending => 'Đang gửi...',
      MessageDeliveryStatus.sent => 'Đã gửi',
      MessageDeliveryStatus.seen => 'Đã xem',
      MessageDeliveryStatus.failed => 'Gửi lỗi',
    };
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.typingUsers});

  final Map<String, String> typingUsers;

  @override
  Widget build(BuildContext context) {
    if (typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    final username = typingUsers.values.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$username đang nhập...',
          style: ChatThreadTokens.profileMeta(context),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
    required this.borderRadius,
  });

  final String text;
  final Color backgroundColor;
  final TextStyle textStyle;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(text, style: textStyle),
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.onSend,
    required this.onTypingStart,
    required this.onTypingStop,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onTypingStart;
  final VoidCallback onTypingStop;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _typingIdleTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _stopTyping();
    _typingIdleTimer?.cancel();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    widget.onSend(text);
    _controller.clear();
    _stopTyping();
  }

  void _handleTextChanged(String value) {
    if (value.trim().isEmpty) {
      _stopTyping();
      return;
    }

    if (!_isTyping) {
      _isTyping = true;
      widget.onTypingStart();
    }
    _typingIdleTimer?.cancel();
    _typingIdleTimer = Timer(const Duration(milliseconds: 1500), _stopTyping);
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _stopTyping();
    }
  }

  void _stopTyping() {
    if (!_isTyping) {
      return;
    }

    _isTyping = false;
    _typingIdleTimer?.cancel();
    widget.onTypingStop();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ChatThreadTokens.pageBackground(context),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: ChatThreadTokens.composerHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ChatThreadTokens.composerLeftPadding,
              ChatThreadTokens.composerVerticalPadding,
              ChatThreadTokens.composerRightPadding,
              ChatThreadTokens.composerVerticalPadding,
            ),
            child: Row(
              children: [
                _ComposerAddButton(key: ChatWidgetKeys.conversationComposerAdd),
                const SizedBox(width: ChatThreadTokens.composerHorizontalGap),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ChatThreadTokens.incomingBubble(context),
                      borderRadius: ChatThreadTokens.composerBorderRadius,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onChanged: _handleTextChanged,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin...',
                        hintStyle: ChatThreadTokens.composerPlaceholder(
                          context,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal:
                              ChatThreadTokens.composerInputHorizontalPadding,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                    color: ChatThreadTokens.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerAddButton extends StatelessWidget {
  const _ComposerAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ChatThreadTokens.incomingBubble(context),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: ChatThreadTokens.composerButtonSize,
        child: Center(
          child: _TintedSvg(
            assetPath: 'assets/icons/chat_thread_plus.svg',
            width: ChatThreadTokens.composerIconSize,
            height: ChatThreadTokens.composerIconSize,
            color: ChatThreadTokens.secondaryText(context),
          ),
        ),
      ),
    );
  }
}

class _CircleAvatarImage extends StatelessWidget {
  const _CircleAvatarImage({required this.user, required this.size});

  final ChatUser? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl;
    return ClipOval(
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Image.asset(
              'assets/images/chat_thread_avatar.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Image.network(
              avatarUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
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
