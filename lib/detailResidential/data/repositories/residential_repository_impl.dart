import '../../domain/entities/residential.dart';
import '../../domain/repositories/residential_repository.dart';
import '../datasources/residential_remote_datasource.dart';

class ResidentialRepositoryImpl implements ResidentialRepository {
  final ResidentialRemoteDataSource dataSource;

  ResidentialRepositoryImpl(this.dataSource);

  @override
  Future<Residential> getResidentialById(int id) async {
    return await dataSource.getResidentialById(id);
  }

  @override
  Future<String> generateGuestCode(int residenciaId, int usos) async {
    return await dataSource.generateGuestCode(residenciaId, usos);
  }

  @override
  Future<void> toggleVisitMode(int residenciaId, bool modoVisita) async {
    await dataSource.toggleVisitMode(residenciaId, modoVisita);
  }

}
