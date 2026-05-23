import 'package:t_app/features/auth/data/auth_user.dart';
import 'package:t_app/features/chat/data/chat_conversation.dart';
import 'package:t_app/features/chat/data/chat_message.dart';
import 'package:t_app/features/chat/data/chat_user.dart';
import 'package:t_app/features/users/data/user_profile.dart';

class DemoData {
  const DemoData._();

  static const currentUser = AuthUser(
    id: 'demo_user',
    email: 'demo@together.local',
    username: '__win.d',
    displayName: 'Thaii Duong',
  );

  static const currentProfile = UserProfile(
    id: 'demo_user',
    username: '__win.d',
    displayName: 'Thaii Duong',
    bio: 'Tài khoản xem thử giao diện',
    followersCount: 224,
    followingCount: 108,
    postCount: 3,
    isFollowing: false,
    tags: ['leomessi', 'FCBarcelona', 'Bóng đá', '+4'],
  );

  static const searchProfile = UserProfile(
    id: 'demo_friend',
    username: 'minhthu.design',
    displayName: 'Nguyen Minh Thu',
    bio: 'Nhà thiết kế sản phẩm',
    followersCount: 1280,
    followingCount: 240,
    postCount: 18,
    isFollowing: false,
    tags: ['Thiết kế', 'Flutter', 'Giao diện'],
  );

  static final now = DateTime(2026, 5, 10, 10);

  static const me = ChatUser(
    id: 'demo_user',
    username: '__win.d',
    displayName: 'Thaii Duong',
  );

  static const friend = ChatUser(
    id: 'demo_friend',
    username: 'minhthu.design',
    displayName: 'Nguyen Minh Thu',
  );

  static List<ChatConversation> conversations() {
    final time = now.toUtc();
    return [
      ChatConversation(
        id: 'demo_conversation_1',
        type: 'direct',
        members: [
          ChatConversationMember(user: me, joinedAt: time),
          ChatConversationMember(user: friend, joinedAt: time),
        ],
        lastMessage: ChatMessage(
          id: 'demo_message_2',
          conversationId: 'demo_conversation_1',
          sender: friend,
          type: 'text',
          content: 'Mở UI chat lên xem thử nha.',
          text: 'Mở UI chat lên xem thử nha.',
          createdAt: time,
          updatedAt: time,
        ),
        unreadCount: 1,
        createdAt: time,
        updatedAt: time,
      ),
    ];
  }

  static List<ChatMessage> messages(String conversationId) {
    final time = now.toUtc();
    return [
      ChatMessage(
        id: 'demo_message_2',
        conversationId: conversationId,
        sender: friend,
        type: 'text',
        content: 'Mở UI chat lên xem thử nha.',
        text: 'Mở UI chat lên xem thử nha.',
        createdAt: time,
        updatedAt: time,
      ),
      ChatMessage(
        id: 'demo_message_1',
        conversationId: conversationId,
        sender: me,
        type: 'text',
        content: 'Đang bỏ qua API để test giao diện.',
        text: 'Đang bỏ qua API để test giao diện.',
        createdAt: time.subtract(const Duration(minutes: 2)),
        updatedAt: time.subtract(const Duration(minutes: 2)),
      ),
    ];
  }
}
