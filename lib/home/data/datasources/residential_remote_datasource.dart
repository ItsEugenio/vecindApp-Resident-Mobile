import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/storage/storage.dart';
import '../models/residential_model.dart';
import '../../../core/network/interceptors/auth_interceptor.dart';

class ResidentialRemoteDataSource {
  final Dio dio;

  ResidentialRemoteDataSource(BuildContext context)
      : dio = Dio(BaseOptions(
    baseUrl: 'https://vecindappback-production.up.railway.app',
    headers: {
      'accept': '*/*',
      'Content-Type': 'application/json',
    },
  )) {
    dio.interceptors.add(AuthInterceptor(context)); //  interceptor
  }

  // GET Residenciales
  Future<List<ResidentialModel>> getResidentials() async {
    try {
      final token = await Storage.getToken();
      final response = await dio.get(
        '/residents',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print("📥 [remote_data_source] Respuesta GET /residents: ${response.data}");
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ResidentialModel.fromJson(json))
            .toList();
      } else {
        throw Exception("Error al obtener residenciales");
      }
    } catch (e) {
      print("❌ [remote_data_source] Error en getResidentials: $e");
      throw Exception("Error en getResidentials: $e");
    }
  }

  // POST Registro en Vecindario
  Future<ResidentialModel> registerToNeighborhood(Map<String, String> data) async {
    try {
      final token = await Storage.getToken();
      print("📤 [remote_data_source] Datos enviados al POST: $data");

      final response = await dio.post(
        '/residents/register',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("📥 [remote_data_source] Respuesta de la API: ${response.data}");

      if (response.statusCode == 201) {
        return ResidentialModel.fromJson(response.data);
      } else {
        throw Exception("Error al registrar vecindario. Código: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [remote_data_source] Error en registerToNeighborhood: $e");
      throw Exception("Error en registerToNeighborhood: $e");
    }
  }




  Future<void> deleteResidential(int id) async {
    try {
      final token = await Storage.getToken();
      final response = await dio.delete(
        '/residents/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ [remote_data_source] Residencial eliminado correctamente.");
      } else {
        throw Exception("Error al eliminar el residencial");
      }
    } catch (e) {
      print("❌ [remote_data_source] Error en deleteResidential: $e");
      throw Exception("Error al eliminar el residencial");
    }
  }


}
