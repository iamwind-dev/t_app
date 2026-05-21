import 'package:t_app/core/network/api_client.dart';
import 'package:t_app/features/users/domain/users_profile_repository.dart';

import 'user_posts_page.dart';
import 'user_profile.dart';
import 'user_profiles_page.dart';

class UsersRepository implements UsersProfileRepository {
  const UsersRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<UserProfile> getProfileById(String userId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/$userId',
      decode: _asMap,
    );

    return UserProfile.fromJson(_readUser(response));
  }

  @override
  Future<UserProfile> getProfileByUsername(String username) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/users/username/${Uri.encodeComponent(username)}',
      decode: _asMap,
    );

    return UserProfile.fromJson(_readUser(response));
  }

  @override
  Future<UserPostsPage> getUserPosts(String userId, {String? cursor}) {
    return _apiClient.get<UserPostsPage>(
      '/users/$userId/posts',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => UserPostsPage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<UserProfilesPage> getFollowers(String userId, {String? cursor}) {
    return _apiClient.get<UserProfilesPage>(
      '/users/$userId/followers',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => UserProfilesPage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<UserProfilesPage> getFollowing(String userId, {String? cursor}) {
    return _apiClient.get<UserProfilesPage>(
      '/users/$userId/following',
      queryParameters: {'limit': 20, if (cursor != null) 'cursor': cursor},
      decode: (value) => UserProfilesPage.fromJson(_asMap(value)),
    );
  }

  @override
  Future<UserProfile> updateMe({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        if (username != null) 'username': username,
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
      decode: _asMap,
    );

    return UserProfile.fromJson(_readUser(response));
  }

  @override
  Future<UserProfile> followUser(String userId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/$userId/follow',
      decode: _asMap,
    );

    return UserProfile.fromJson(_readUser(response));
  }

  @override
  Future<UserProfile> unfollowUser(String userId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/users/$userId/follow',
      decode: _asMap,
    );

    return UserProfile.fromJson(_readUser(response));
  }

  static Map<String, dynamic> _readUser(Map<String, dynamic> response) {
    final user = response['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    throw const FormatException('User response missing user.');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw const FormatException('Expected a JSON object.');
  }
}
