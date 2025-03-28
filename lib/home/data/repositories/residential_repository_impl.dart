import '../../domain/entities/residential.dart';
import '../../domain/repositories/residential_repository.dart';
import '../datasources/residential_remote_datasource.dart';
import '../models/residential_model.dart';

class ResidentialRepositoryImpl implements ResidentialRepository {
  final ResidentialRemoteDataSource dataSource;

  ResidentialRepositoryImpl(this.dataSource);

  @override
  Future<List<Residential>> getResidentials() async {
    final residentialModels = await dataSource.getResidentials();
    return residentialModels.map((model) => _mapModelToEntity(model)).toList();
  }

  @override
  Future<Residential> registerToNeighborhood(Map<String, String> data) async {
    final residentialModel = await dataSource.registerToNeighborhood(data);
    return _mapModelToEntity(residentialModel);
  }

  @override
  Future<void> deleteResidential(int id) async {
    await dataSource.deleteResidential(id);
  }


  Residential _mapModelToEntity(ResidentialModel model) {
    return Residential(
      id: model.id,
      calle: model.calle,
      numeroCasa: model.numeroCasa,
      nombreNeighborhood: model.nombreNeighborhood,
      modoVisita: model.modoVisita,
      codigoInvitado: model.codigoInvitado,
    );
  }
}
