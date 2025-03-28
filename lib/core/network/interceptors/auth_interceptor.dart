import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../storage/storage.dart';
import '../../../login/presentation/pages/login_page.dart';

class AuthInterceptor extends Interceptor {
  final BuildContext context; // Necesario para navegar a Login

  AuthInterceptor(this.context);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      print("🔴 Token expirado. Redirigiendo a Login...");

      // Eliminar el token porque ya no es válido
      await Storage.removeToken();

      // Redirigir a la pantalla de Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
    super.onError(err, handler);
  }
}
