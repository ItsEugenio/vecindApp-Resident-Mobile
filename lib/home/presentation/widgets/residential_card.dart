import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../detailResidential/data/datasources/residential_remote_datasource.dart';
import '../../../detailResidential/data/repositories/residential_repository_impl.dart';
import '../../../detailResidential/presentation/blocs/residential_detail_bloc.dart';
import '../../domain/entities/residential.dart';
import '../../presentation/blocs/residential_bloc.dart';
import '../../../detailResidential/presentation/pages/detail_residential.dart'; // ✅ Importamos DetailResidential

class ResidentialCard extends StatelessWidget {
  final Residential residential;

  const ResidentialCard({required this.residential, Key? key}) : super(key: key);

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar Residencial"),
          content: Text("¿Seguro que deseas eliminar ${residential.nombreNeighborhood}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ResidentialBloc>().add(DeleteResidential(residential.id));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ResidentialDetailBloc(
                ResidentialRepositoryImpl(ResidentialRemoteDataSource()),
              )..add(FetchResidentialById(residential.id)), // ✅ Llama el evento al crear la pantalla
              child: DetailResidential(residentialId: residential.id),
            ),
          ),
        );

      },

      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: ListTile(
          title: Text("${residential.nombreNeighborhood} - ${residential.calle} ${residential.numeroCasa}"),
          subtitle: Text(residential.modoVisita ? "Modo Visita" : "Residencia Permanente"),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ),
    );
  }
}
