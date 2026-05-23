import '../entities/register_user.dart';
import '../repositories/register_repository.dart';
import '../../../auth/data/auth_session.dart';

class RegisterUser {
  final RegisterRepository repository;

  const RegisterUser(this.repository);

  Future<AuthSession> call(RegisterUserEntity user) {
    return repository.register(user);
  }
}
