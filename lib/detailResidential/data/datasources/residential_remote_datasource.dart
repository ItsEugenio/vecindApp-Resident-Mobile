import 'package:dio/dio.dart';
import '../../../core/storage/storage.dart';
import '../models/residential_model.dart';

class ResidentialRemoteDataSource {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://vecindappback-production.up.railway.app',
    headers: {'accept': '*/*', 'Content-Type': 'application/json'},
  ));

  Future<ResidentialModel> getResidentialById(int id) async {
    try {
      final token = await Storage.getToken();
      final response = await dio.get(
        '/residents/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ResidentialModel.fromJson(response.data);
      } else {
        throw Exception("Error al obtener el residencial");
      }
    } catch (e) {
      throw Exception("Error en getResidentialById: $e");
    }
  }

  Future<String> generateGuestCode(int residenciaId, int usos) async {
    try {
      final token = await Storage.getToken();
      final response = await dio.post(
        '/residents/generate-multiple-codes',
        data: {'residenciaId': residenciaId, 'usos': usos},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        return response.data["codigoInvitado"];
      } else {
        throw Exception("Error al generar el código de invitado");
      }
    } catch (e) {
      throw Exception("Error en generateGuestCode: $e");
    }
  }

  Future<void> toggleVisitMode(int residenciaId, bool modoVisita) async {
    try {
      final token = await Storage.getToken();
      final response = await dio.patch(
        '/residents/toggle-visit-mode',
        data: {"residenciaId": residenciaId, "modoVisita": modoVisita},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        print("✅ [RemoteData] Modo visita actualizado correctamente.");
      } else {
        throw Exception("Error al actualizar el modo visita");
      }
    } catch (e) {
      print("❌ [RemoteData] Error en toggleVisitMode: $e");
      throw Exception("Error al actualizar el modo visita");
    }
  }
}
