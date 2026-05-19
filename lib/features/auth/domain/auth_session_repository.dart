import '../data/auth_session.dart';
import '../data/auth_user.dart';

abstract interface class AuthSessionRepository {
  Future<AuthSession> login({
    required String identifier,
    required String password,
  });

  Future<AuthSession> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
  });

  Future<AuthUser?> loadCurrentUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> logOut();
}
