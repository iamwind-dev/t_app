import '../entities/register_user.dart';
import '../repositories/register_repository.dart';

class RegisterUser {
  final RegisterRepository repository;

  const RegisterUser(this.repository);

  Future<bool> call(RegisterUserEntity user) {
    return repository.register(user);
  }
}
