import 'package:flutter/widgets.dart';

abstract final class ChatWidgetKeys {
  static const inboxConversationPreview = Key(
    'chat.inbox.conversation_preview',
  );
  static const conversationBackButton = Key('chat.conversation.back_button');
  static const conversationComposerAdd = Key('chat.conversation.composer.add');
}
