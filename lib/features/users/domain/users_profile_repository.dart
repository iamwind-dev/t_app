import '../data/user_posts_page.dart';
import '../data/user_profile.dart';
import '../data/user_profiles_page.dart';

abstract interface class UsersProfileRepository {
  Future<UserProfile> getProfileById(String userId);

  Future<UserProfile> getProfileByUsername(String username);

  Future<UserPostsPage> getUserPosts(String userId, {String? cursor});

  Future<UserProfilesPage> getFollowers(String userId, {String? cursor});

  Future<UserProfilesPage> getFollowing(String userId, {String? cursor});

  Future<UserProfile> updateMe({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  });

  Future<UserProfile> followUser(String userId);

  Future<UserProfile> unfollowUser(String userId);
}
