import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> login(String email, String password) {
    return remoteDataSource.login(UserModel(email: email, password: password));
  }
}
