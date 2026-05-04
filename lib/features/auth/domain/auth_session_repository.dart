import '../data/auth_session.dart';
import '../data/auth_user.dart';

abstract interface class AuthSessionRepository {
  Future<AuthSession> login({
    required String identifier,
    required String password,
  });

  Future<AuthUser?> loadCurrentUser();

  Future<void> logOut();
}
