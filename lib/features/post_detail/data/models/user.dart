import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.username,
    this.avatarAssetPath,
    this.avatarUrl,
    this.subtitle,
    this.isVerified = false,
    this.isFollowing = false,
  });

  final String id;
  final String name;
  final String username;
  final String? avatarAssetPath;
  final String? avatarUrl;
  final String? subtitle;
  final bool isVerified;
  final bool isFollowing;

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarAssetPath,
    String? avatarUrl,
    String? subtitle,
    bool? isVerified,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subtitle: subtitle ?? this.subtitle,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    avatarAssetPath,
    avatarUrl,
    subtitle,
    isVerified,
    isFollowing,
  ];
}
