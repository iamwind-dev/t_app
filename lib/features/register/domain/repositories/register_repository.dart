import '../entities/register_user.dart';

abstract class RegisterRepository {
  Future<bool> register(RegisterUserEntity user);
}
