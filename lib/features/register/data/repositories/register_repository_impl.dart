import '../../domain/entities/register_user.dart';
import '../../domain/repositories/register_repository.dart';
import '../datasources/register_local_data_source.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterLocalDataSource localDataSource;

  const RegisterRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> register(RegisterUserEntity user) {
    return localDataSource.register(user);
  }
}
