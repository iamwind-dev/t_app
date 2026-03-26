import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    loadHomeFeed();
  }

  void loadHomeFeed() {
    final mockPosts = <ThreadPost>[
      const ThreadPost(
        author: 'Ruchi_shah',
        avatarAsset: 'assets/images/home_avatar_ruchi.png',
        timeAgo: '49m',
        content:
            'Failures are stepping stones to success.\nEmbrace them, learn from them, and keep moving forward',
        threadStackAsset: 'assets/images/home_thread_stack_1.png',
        threadStackHeight: 147,
        likeCount: '3',
        replyCount: '1',
        repostCount: '0',
        sendCount: '0',
        comments: [
          ThreadComment(
            author: 'nhuxinhnaa',
            avatarAsset: 'assets/images/home_avatar_payal.png',
            timeAgo: '23 giờ',
            content: 'giọng Huế nghe hayyyyy vãi',
            showLikeBadge: true,
            likeCount: '5',
            replyCount: '0',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '1 like',
      ),
      const ThreadPost(
        author: 'Payal_shah',
        avatarAsset: 'assets/images/home_avatar_payal.png',
        timeAgo: '44m',
        content: 'Yes',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '6',
        replyCount: '3',
        repostCount: '2',
        sendCount: '1',
        primaryMeta: '1 like',
      ),
      const ThreadPost(
        author: 'Krunal modi',
        avatarAsset: 'assets/images/home_avatar_krunal.png',
        timeAgo: '50m',
        content: 'Hey @zuck where is my verified?',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '10.7k',
        replyCount: '546',
        repostCount: '19',
        sendCount: '11',
        postImageAsset: 'assets/images/home_post_sample.jpg',
        postImageHeight: 220,
        primaryMeta: '2 replies',
        secondaryMeta: 'People liked your content',
      ),
      const ThreadPost(
        author: 'figma',
        avatarAsset: 'assets/images/home_avatar_figma.png',
        timeAgo: '6m',
        content: 'Hello new (old) friends ✌️',
        threadStackAsset: 'assets/images/home_thread_stack_3.png',
        threadStackHeight: 40,
        likeCount: '32k',
        replyCount: '1.2k',
        repostCount: '320',
        sendCount: '48',
        isVerified: true,
        primaryMeta: '32k replies',
        secondaryMeta: 'Liked by cursodefigmapro and others',
      ),
      const ThreadPost(
        author: 'DesignDaily',
        timeAgo: '12m',
        content:
            'Daily tip: keep spacing consistent with an 8pt grid. Your UI instantly feels cleaner.',
        threadStackAsset: 'assets/images/home_thread_stack_1.png',
        threadStackHeight: 154,
        likeCount: '128',
        replyCount: '14',
        repostCount: '5',
        sendCount: '3',
        comments: [
          ThreadComment(
            author: 'pixel_anna',
            timeAgo: '9m',
            content: '8pt grid is a game changer for handoff.',
            likeCount: '8',
            replyCount: '1',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '14 replies',
      ),
      const ThreadPost(
        author: 'FlutterNerd',
        timeAgo: '19m',
        content:
            'Built a sticky bottom nav with scroll-aware animation today. Super smooth now 🚀',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '2.4k',
        replyCount: '197',
        repostCount: '63',
        sendCount: '24',
        postImageAsset: 'assets/images/home_post_sample.jpg',
        postImageHeight: 210,
        primaryMeta: 'Trending in Mobile Dev',
      ),
      const ThreadPost(
        author: 'TheProductClub',
        timeAgo: '34m',
        content:
            'Question for everyone: what is one habit that made your product thinking better?',
        threadStackAsset: 'assets/images/home_thread_stack_3.png',
        threadStackHeight: 148,
        likeCount: '402',
        replyCount: '81',
        repostCount: '11',
        sendCount: '7',
        comments: [
          ThreadComment(
            author: 'james_pm',
            timeAgo: '30m',
            content: 'Talking to users every single week.',
            showLikeBadge: true,
            likeCount: '21',
            replyCount: '4',
            repostCount: '1',
            sendCount: '0',
          ),
          ThreadComment(
            author: 'linhux',
            timeAgo: '25m',
            content: 'Writing assumptions before building any feature.',
            likeCount: '13',
            replyCount: '2',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '81 replies',
        secondaryMeta: 'People are discussing this',
      ),
      const ThreadPost(
        author: 'open_source',
        timeAgo: '1h',
        content:
            'Shipped another tiny improvement today. Small wins every day compound over time.',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '98',
        replyCount: '12',
        repostCount: '4',
        sendCount: '2',
        isVerified: true,
        primaryMeta: '12 replies',
      ),
      const ThreadPost(
        author: 'CafeCodeVN',
        timeAgo: '1h',
        content:
            'Sang nay ngoi debug tu 7h, cuoi cung loi lai den tu 1 dau phay sai. Lam dev la vay do.',
        threadStackAsset: 'assets/images/home_thread_stack_1.png',
        threadStackHeight: 154,
        likeCount: '286',
        replyCount: '42',
        repostCount: '7',
        sendCount: '4',
        comments: [
          ThreadComment(
            author: 'duypham',
            timeAgo: '58m',
            content: 'Bug nho nhat thuong an nhieu thoi gian nhat.',
            likeCount: '11',
            replyCount: '2',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '42 replies',
        secondaryMeta: 'Developers can relate',
      ),
      const ThreadPost(
        author: 'makerspace',
        timeAgo: '1h',
        content:
            'Prototype nhanh khong co nghia la lam au. Chi can dung muc do chi tiet de test dung gia thuyet.',
        threadStackAsset: 'assets/images/home_thread_stack_3.png',
        threadStackHeight: 148,
        likeCount: '1.8k',
        replyCount: '125',
        repostCount: '33',
        sendCount: '12',
        comments: [
          ThreadComment(
            author: 'linh.product',
            timeAgo: '55m',
            content:
                'Dung, prototype tot la prototype tra loi duoc cau hoi lon nhat.',
            showLikeBadge: true,
            likeCount: '17',
            replyCount: '3',
            repostCount: '1',
            sendCount: '0',
          ),
          ThreadComment(
            author: 'hieutran',
            timeAgo: '48m',
            content:
                'Team minh giam duoc kha nhieu scope creep sau khi lam theo cach nay.',
            likeCount: '9',
            replyCount: '1',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '125 replies',
      ),
      const ThreadPost(
        author: 'photo.walks',
        timeAgo: '2h',
        content:
            'Golden hour in Sai Gon hits different when the streets slow down for five minutes.',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '5.1k',
        replyCount: '302',
        repostCount: '57',
        sendCount: '18',
        postImageAsset: 'assets/images/home_post_sample.jpg',
        postImageHeight: 236,
        primaryMeta: '302 replies',
        secondaryMeta: 'Popular in Photography',
      ),
      const ThreadPost(
        author: 'buildinpublic',
        timeAgo: '2h',
        content:
            'Posting this here so I stay accountable: ship the onboarding flow before midnight.',
        threadStackAsset: 'assets/images/home_thread_stack_2.png',
        threadStackHeight: 106,
        likeCount: '742',
        replyCount: '58',
        repostCount: '9',
        sendCount: '6',
        isVerified: true,
        primaryMeta: '58 replies',
      ),
      const ThreadPost(
        author: 'ux.notes',
        timeAgo: '3h',
        content:
            'Neu user phai dung lai de nghi xem nut nay dung de lam gi, thi do khong con la UI "truc quan" nua.',
        threadStackAsset: 'assets/images/home_thread_stack_1.png',
        threadStackHeight: 154,
        likeCount: '963',
        replyCount: '76',
        repostCount: '21',
        sendCount: '10',
        comments: [
          ThreadComment(
            author: 'quangui',
            timeAgo: '2h',
            content:
                'Text tren button va hierarchy van la hai thu bi lam au nhat.',
            likeCount: '14',
            replyCount: '2',
            repostCount: '0',
            sendCount: '0',
          ),
        ],
        primaryMeta: '76 replies',
        secondaryMeta: 'Saved by 200+ designers',
      ),
    ];

    emit(
      state.copyWith(
        feedItems: mockPosts
            .map(ThreadItemData.fromThreadPost)
            .toList(growable: false),
      ),
    );
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}
