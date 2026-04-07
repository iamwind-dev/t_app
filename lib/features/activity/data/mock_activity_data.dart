import 'package:t_app/features/activity/data/models/activity_item_model.dart';
import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';

const _sua = User(
  id: 'activity_user_1',
  name: 'Suagaoo',
  username: 'suagaoo',
  avatarAssetPath: 'assets/images/home_avatar_ruchi.png',
);

const _duy = User(
  id: 'activity_user_2',
  name: 'Duyluannice',
  username: 'duyluannice',
  avatarAssetPath: 'assets/images/home_avatar_krunal.png',
);

const _bb = User(
  id: 'activity_user_3',
  name: 'bb_haykhocnhe',
  username: 'bb_haykhocnhe',
  avatarAssetPath: 'assets/images/home_avatar_payal.png',
);

const _nhims = User(
  id: 'activity_user_4',
  name: 'nhims2_',
  username: 'nhims2_',
  avatarAssetPath: 'assets/images/home_avatar_figma.png',
);

const _playboy = User(
  id: 'activity_user_5',
  name: 'playboiquangnam',
  username: 'playboiquangnam',
);

const _fuwg = User(
  id: 'activity_user_6',
  name: 'fuwg.thaow',
  username: 'fuwg.thaow',
  avatarAssetPath: 'assets/images/home_avatar_payal.png',
);

const _tlat = User(
  id: 'activity_user_7',
  name: 'tlat.moe',
  username: 'tlat.moe',
  avatarAssetPath: 'assets/images/home_avatar_ruchi.png',
);

const activityItems = [
  ActivityItemModel(
    id: 'activity_1',
    type: ActivityItemType.followSuggestion,
    user: _sua,
    timestampLabel: '2 ngày',
    subtitle: 'Gợi ý theo dõi',
    hasPurpleBadge: true,
  ),
  ActivityItemModel(
    id: 'activity_2',
    type: ActivityItemType.contentRecommendation,
    user: _duy,
    timestampLabel: '3 ngày',
    subtitle: 'Vì bạn theo dõi',
    contentPreview:
        'Chơi Quiz + Giveaway dọn kho tháng 4/2026:\nKỳ này có mấy món như sau nhen...',
    mediaThumbnail: 'assets/images/home_post_sample.jpg',
    likeCount: 1400,
    commentCount: 31,
    repostCount: 384,
    shareCount: 395,
    thread: ThreadItemModel(
      id: 'activity_thread_1',
      rootThreadId: 'activity_thread_1',
      author: _duy,
      createdAt: '3 ngày',
      content:
          'Chơi Quiz + Giveaway dọn kho tháng 4/2026:\nKỳ này có mấy món như sau nhen...',
      imageUrls: ['assets/images/home_post_sample.jpg'],
      likesCount: 1400,
      replyCount: 31,
      repostCount: 384,
      shareCount: 395,
    ),
  ),
  ActivityItemModel(
    id: 'activity_3',
    type: ActivityItemType.followSuggestion,
    user: _bb,
    timestampLabel: '3 ngày',
    subtitle: 'Gợi ý theo dõi',
    hasPurpleBadge: true,
  ),
  ActivityItemModel(
    id: 'activity_4',
    type: ActivityItemType.followSuggestion,
    user: _nhims,
    timestampLabel: '6 ngày',
    subtitle: 'Gợi ý theo dõi',
    hasPurpleBadge: true,
  ),
  ActivityItemModel(
    id: 'activity_5',
    type: ActivityItemType.followSuggestion,
    user: _playboy,
    timestampLabel: '31/3/26',
    subtitle: 'Gợi ý theo dõi',
    hasPurpleBadge: true,
  ),
  ActivityItemModel(
    id: 'activity_6',
    type: ActivityItemType.followSuggestion,
    user: _fuwg,
    timestampLabel: '30/3/26',
    subtitle: 'Gợi ý theo dõi',
    hasPurpleBadge: true,
  ),
  ActivityItemModel(
    id: 'activity_7',
    type: ActivityItemType.contentRecommendation,
    user: _tlat,
    timestampLabel: '28/3/26',
    subtitle: 'Thread gợi ý',
    contentPreview: 'Oy cái theme messenger mới xinh v 🤣',
    mediaThumbnail: 'assets/images/home_post_sample.jpg',
    likeCount: 0,
    commentCount: 0,
    repostCount: 0,
    shareCount: 0,
    thread: ThreadItemModel(
      id: 'activity_thread_2',
      rootThreadId: 'activity_thread_2',
      author: _tlat,
      createdAt: '28/3/26',
      content: 'Oy cái theme messenger mới xinh v 🤣',
      imageUrls: ['assets/images/home_post_sample.jpg'],
    ),
  ),
];
