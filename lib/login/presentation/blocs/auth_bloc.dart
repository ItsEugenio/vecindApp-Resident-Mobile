import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../core/storage/storage.dart';

sealed class AuthEvent {}
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      print("🟢 [auth_bloc] Evento LoginEvent recibido. Iniciando autenticación...");
      emit(AuthLoading());

      try {
        final token = await loginUseCase.execute(event.email, event.password);
        print("✅ [auth_bloc] Autenticación exitosa, guardando token...");

        await Storage.saveToken(token);
        print("🔄 [auth_bloc] Token guardado en SharedPreferences: $token");

        emit(AuthSuccess());
      } catch (e) {
        print("❌ [auth_bloc] Error en la autenticación: $e");
        emit(AuthFailure());
      }
    });
  }
}
