import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.followersCount,
    required this.followingCount,
    required this.postCount,
    required this.isFollowing,
    this.bio,
    this.avatarUrl,
    this.tags = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postCount: json['postCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      tags: _readTags(json['tags']),
    );
  }

  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int postCount;
  final bool isFollowing;
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    bio,
    avatarUrl,
    followersCount,
    followingCount,
    postCount,
    isFollowing,
    tags,
  ];

  static List<String> _readTags(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList(growable: false);
  }
}
