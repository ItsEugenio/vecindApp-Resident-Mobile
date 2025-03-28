import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<String> execute(String email, String password) async {
    try {
      return await repository.login(email, password);
    } catch (e) {
      print("🚨 [login_usecase] Error en loginUseCase.execute: $e");
      rethrow; // Para que el Bloc pueda capturar y manejar el error
    }
  }
}
