import 'package:dio/dio.dart';
import '../models/user_model.dart';


class AuthRemoteDataSource {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://vecindappback-production.up.railway.app',
    headers: {
      'accept': '*/*',
      'Content-Type': 'application/json'
    },
  ));

  Future<String> login(UserModel user) async {
    try {
      print("📤 [remote_data_source] Enviando petición a la API...");

      final response = await dio.post(
        '/auth/login',
        data: user.toJson(),
      );

      print("📥 [remote_data_source] Respuesta recibida: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) { // ✅ Aceptamos 201 también
        final token = response.data['access_token'];
        print("✅ [remote_data_source] Token obtenido: $token");
        return token;
      } else {
        print("❌ [remote_data_source] Error HTTP ${response.statusCode}: ${response.data}");
        throw Exception("Error en la autenticación: Código ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ [remote_data_source] Excepción de Dio: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception("Error en la autenticación: ${e.response?.statusCode}");
    } catch (e) {
      print("❌ [remote_data_source] Excepción inesperada: $e");
      throw Exception("Error inesperado en la autenticación");
    }
  }
}
