import 'package:equatable/equatable.dart';

import 'user_profile.dart';

class UserProfilesPage extends Equatable {
  const UserProfilesPage({required this.items, required this.pageInfo});

  factory UserProfilesPage.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final pageInfo = json['pageInfo'];

    return UserProfilesPage(
      items: items is List
          ? items
                .whereType<Map<String, dynamic>>()
                .map(UserProfile.fromJson)
                .toList(growable: false)
          : const [],
      pageInfo: pageInfo is Map<String, dynamic>
          ? UserProfilesPageInfo.fromJson(pageInfo)
          : const UserProfilesPageInfo(nextCursor: null, hasNextPage: false),
    );
  }

  final List<UserProfile> items;
  final UserProfilesPageInfo pageInfo;

  @override
  List<Object?> get props => [items, pageInfo];
}

class UserProfilesPageInfo extends Equatable {
  const UserProfilesPageInfo({
    required this.nextCursor,
    required this.hasNextPage,
  });

  factory UserProfilesPageInfo.fromJson(Map<String, dynamic> json) {
    return UserProfilesPageInfo(
      nextCursor: json['nextCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  final String? nextCursor;
  final bool hasNextPage;

  @override
  List<Object?> get props => [nextCursor, hasNextPage];
}
