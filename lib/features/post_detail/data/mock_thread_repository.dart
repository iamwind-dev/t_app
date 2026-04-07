import 'models/thread_item_model.dart';
import 'models/user.dart';

class MockThreadRepository {
  const MockThreadRepository();

  List<ThreadItemModel> fetchRootThreads() => _rootThreads;
}

const _thu = User(
  id: 'user_1',
  name: 'Nguyen Minh Thu',
  username: '@minhthu.design',
  avatarAssetPath: 'assets/images/home_avatar_ruchi.png',
  subtitle: 'Product Designer at Together',
  isVerified: true,
);

const _nam = User(
  id: 'user_2',
  name: 'Tran Hoang Nam',
  username: '@nam.dev',
  avatarAssetPath: 'assets/images/home_avatar_krunal.png',
  subtitle: 'Flutter Developer',
);

const _han = User(
  id: 'user_3',
  name: 'Le Bao Han',
  username: '@han.content',
  avatarAssetPath: 'assets/images/home_avatar_payal.png',
  subtitle: 'Content Creator',
);

const _figma = User(
  id: 'user_4',
  name: 'Figma',
  username: '@figma',
  avatarAssetPath: 'assets/images/home_avatar_figma.png',
  subtitle: 'Design tools',
  isVerified: true,
);

const _rootThreads = [
  ThreadItemModel(
    id: 'thread_101',
    rootThreadId: 'thread_101',
    author: _thu,
    createdAt: '2 giờ trước',
    content:
        'Cuối tuần rồi mình hoàn thiện bản redesign cho màn hình cộng đồng của app. '
        'Mình ưu tiên ba thứ: phần header tác giả rõ ràng, nội dung bài viết dễ đọc và khu vực thread đủ thoáng để người dùng theo dõi thảo luận.\n\n'
        'Mọi người thấy hướng UI này ổn chưa, hay cần tăng độ tương phản cho khu vực action?',
    imageUrls: [
      'assets/images/home_post_sample.jpg',
      'assets/images/home_post_sample.jpg',
      'assets/images/home_post_sample.jpg',
    ],
    likesCount: 248,
    replyCount: 8,
    shareCount: 12,
    replyPreviewAvatars: [
      'assets/images/home_avatar_krunal.png',
      'assets/images/home_avatar_payal.png',
      'assets/images/home_avatar_figma.png',
    ],
    previewReplies: [
      ThreadItemModel(
        id: 'thread_101_1',
        parentId: 'thread_101',
        rootThreadId: 'thread_101',
        author: _nam,
        createdAt: '1 giờ trước',
        content:
            'Khoảng cách giữa header và nội dung đang rất ổn. Nhìn vào là đọc được ngay.',
        likesCount: 24,
        replyCount: 3,
        repostCount: 2,
        shareCount: 1,
      ),
      ThreadItemModel(
        id: 'thread_101_2',
        parentId: 'thread_101',
        rootThreadId: 'thread_101',
        author: _han,
        createdAt: '58 phút trước',
        content:
            'Grid ảnh gọn, không làm màn hình bị quá dài. Mình thích cách xử lý này.',
        imageUrls: ['assets/images/home_post_sample.jpg'],
        likesCount: 17,
        replyCount: 1,
      ),
    ],
    children: [
      ThreadItemModel(
        id: 'thread_101_1',
        parentId: 'thread_101',
        rootThreadId: 'thread_101',
        author: _nam,
        createdAt: '1 giờ trước',
        content:
            'Khoảng cách giữa header và nội dung đang rất ổn. Nhìn vào là đọc được ngay.',
        likesCount: 24,
        replyCount: 3,
        repostCount: 2,
        shareCount: 1,
        replyPreviewAvatars: [
          'assets/images/home_avatar_payal.png',
          'assets/images/home_avatar_figma.png',
          'assets/images/home_avatar_ruchi.png',
        ],
        children: [
          ThreadItemModel(
            id: 'thread_101_1_1',
            parentId: 'thread_101_1',
            rootThreadId: 'thread_101',
            author: _han,
            createdAt: '46 phút trước',
            content:
                'Mình đồng ý. Phần hierarchy giữa author và body đang rất rõ, nhất là trên mobile.',
            likesCount: 6,
            replyCount: 2,
            replyPreviewAvatars: [
              'assets/images/home_avatar_figma.png',
              'assets/images/home_avatar_ruchi.png',
            ],
            children: [
              ThreadItemModel(
                id: 'thread_101_1_2',
                parentId: 'thread_101_1_1',
                rootThreadId: 'thread_101',
                author: _figma,
                createdAt: '34 phút trước',
                content:
                    'Nếu giữ spacing hiện tại và tăng thêm chút emphasis cho action bar thì thread sẽ rất dễ follow.',
                likesCount: 4,
                replyCount: 1,
                replyPreviewAvatars: ['assets/images/home_avatar_ruchi.png'],
                children: [
                  ThreadItemModel(
                    id: 'thread_101_1_3',
                    parentId: 'thread_101_1_2',
                    rootThreadId: 'thread_101',
                    author: _thu,
                    createdAt: '20 phút trước',
                    content:
                        'Chuẩn. Mình sẽ giữ khung hiện tại và chỉ tinh chỉnh contrast ở action cho dễ đọc hơn.',
                    likesCount: 3,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ThreadItemModel(
        id: 'thread_101_2',
        parentId: 'thread_101',
        rootThreadId: 'thread_101',
        author: _han,
        createdAt: '58 phút trước',
        content:
            'Grid ảnh gọn, không làm màn hình bị quá dài. Mình thích cách xử lý này.',
        imageUrls: ['assets/images/home_post_sample.jpg'],
        likesCount: 17,
        replyCount: 1,
        replyPreviewAvatars: [
          'assets/images/home_avatar_krunal.png',
          'assets/images/home_avatar_figma.png',
        ],
        children: [
          ThreadItemModel(
            id: 'thread_101_2_1',
            parentId: 'thread_101_2',
            rootThreadId: 'thread_101',
            author: _nam,
            createdAt: '41 phút trước',
            content:
                'Giờ chuyển sang carousel ngang thì trải nghiệm xem ảnh tự nhiên hơn hẳn, không bị cảm giác grid cứng nữa.',
            likesCount: 5,
          ),
        ],
      ),
      ThreadItemModel(
        id: 'thread_101_3',
        parentId: 'thread_101',
        rootThreadId: 'thread_101',
        author: _figma,
        createdAt: '35 phút trước',
        content:
            'Nếu thêm composer cố định ở cuối màn thì trải nghiệm reply sẽ còn rõ hơn nữa.',
        likesCount: 9,
        replyCount: 1,
        repostCount: 1,
        replyPreviewAvatars: [
          'assets/images/home_avatar_payal.png',
          'assets/images/home_avatar_krunal.png',
          'assets/images/home_avatar_ruchi.png',
        ],
        children: [
          ThreadItemModel(
            id: 'thread_101_3_1',
            parentId: 'thread_101_3',
            rootThreadId: 'thread_101',
            author: _thu,
            createdAt: '16 phút trước',
            content:
                'Composer cố định là hợp lý. Nếu làm thì mình muốn vẫn giữ khoảng thở cho phần thread phía trên.',
            likesCount: 2,
          ),
        ],
      ),
    ],
  ),
  ThreadItemModel(
    id: 'thread_102',
    rootThreadId: 'thread_102',
    author: _nam,
    createdAt: '54 phút trước',
    content:
        'Hôm nay mình vừa refactor lại flow state cho app Flutter. Tách model và mock repository xong thì code sạch hơn hẳn.',
    likesCount: 83,
    replyCount: 1,
    shareCount: 4,
    previewReplies: [
      ThreadItemModel(
        id: 'thread_102_1',
        parentId: 'thread_102',
        rootThreadId: 'thread_102',
        author: _thu,
        createdAt: '40 phút trước',
        content: 'Đúng hướng rồi, sau này thay API thật sẽ dễ hơn nhiều.',
        likesCount: 8,
      ),
    ],
    children: [
      ThreadItemModel(
        id: 'thread_102_1',
        parentId: 'thread_102',
        rootThreadId: 'thread_102',
        author: _thu,
        createdAt: '40 phút trước',
        content: 'Đúng hướng rồi, sau này thay API thật sẽ dễ hơn nhiều.',
        likesCount: 8,
      ),
    ],
  ),
  ThreadItemModel(
    id: 'thread_103',
    rootThreadId: 'thread_103',
    author: _figma,
    createdAt: '15 phút trước',
    content:
        'Hello new friends. We are exploring cleaner collaboration patterns for product teams this week.',
    imageUrls: ['assets/images/home_post_sample.jpg'],
    likesCount: 320,
    shareCount: 21,
    replyCount: 0,
  ),
];
