import '../../domain/entities/register_user.dart';
import '../../domain/repositories/register_repository.dart';
import '../../../auth/data/auth_session.dart';
import '../datasources/register_remote_data_source.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  const RegisterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthSession> register(RegisterUserEntity user) {
    return remoteDataSource.register(user);
  }
}
