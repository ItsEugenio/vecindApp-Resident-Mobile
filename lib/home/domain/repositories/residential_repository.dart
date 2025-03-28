import '../entities/residential.dart';

abstract class ResidentialRepository {
  Future<List<Residential>> getResidentials();
  Future<Residential> registerToNeighborhood(Map<String, String> data);
  Future<void> deleteResidential(int id);
}
