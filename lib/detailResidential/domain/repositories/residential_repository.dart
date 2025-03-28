import '../entities/residential.dart';

abstract class ResidentialRepository {
  Future<Residential> getResidentialById(int id);
  Future<String> generateGuestCode(int residenciaId, int usos);
  Future<void> toggleVisitMode(int residenciaId, bool modoVisita);
}