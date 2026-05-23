import '../../domain/entities/register_user.dart';

abstract class RegisterLocalDataSource {
  Future<bool> register(RegisterUserEntity user);
}

class RegisterLocalDataSourceImpl implements RegisterLocalDataSource {
  @override
  Future<bool> register(RegisterUserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
