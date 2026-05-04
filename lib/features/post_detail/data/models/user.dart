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
  });

  final String id;
  final String name;
  final String username;
  final String? avatarAssetPath;
  final String? avatarUrl;
  final String? subtitle;
  final bool isVerified;

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    avatarAssetPath,
    avatarUrl,
    subtitle,
    isVerified,
  ];
}
