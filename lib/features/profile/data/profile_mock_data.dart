import 'package:t_app/features/post_detail/data/models/thread_item_model.dart';
import 'package:t_app/features/post_detail/data/models/user.dart';

const profileUser = User(
  id: 'profile_user_1',
  name: 'Thaii Duong',
  username: '__win.d',
  avatarAssetPath: 'assets/images/home_avatar_payal.png',
  subtitle: 'Threads profile',
);

const profileBio = '🐺';
const profileInterestTags = ['leomessi', 'FCBarcelona', 'Football', '+4'];
const profileFollowersCount = 224;

const profileFollowerPreviewAssets = [
  'assets/images/home_avatar_figma.png',
  'assets/images/home_avatar_krunal.png',
  'assets/images/home_avatar_ruchi.png',
];

const profileThreads = [
  ThreadItemModel(
    id: 'profile_thread_1',
    rootThreadId: 'profile_thread_1',
    author: profileUser,
    createdAt: '5/7/24',
    content: 'Sinh nhật Threads',
    likesCount: 2,
    replyCount: 0,
  ),
  ThreadItemModel(
    id: 'profile_thread_2',
    rootThreadId: 'profile_thread_2',
    author: profileUser,
    createdAt: '30/7/23',
    content: 'Khi anh biết em rời xa\nAnh đã mất một bó hoa...',
    likesCount: 0,
    replyCount: 0,
  ),
  ThreadItemModel(
    id: 'profile_thread_3',
    rootThreadId: 'profile_thread_3',
    author: profileUser,
    createdAt: '9/7/23',
    content: 'Chúng ta sẽ khóc vì những thứ làm ta cười :D',
    likesCount: 3,
    replyCount: 0,
  ),
];
