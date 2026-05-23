import '../entities/register_user.dart';
import '../../../auth/data/auth_session.dart';

abstract class RegisterRepository {
  Future<AuthSession> register(RegisterUserEntity user);
}
