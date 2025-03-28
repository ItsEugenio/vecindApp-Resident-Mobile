import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/storage.dart';
import '../../../login/presentation/pages/login_page.dart';
import '../blocs/residential_bloc.dart';
import '../widgets/residential_card.dart';
import '../widgets/custom_appbar_clipper.dart'; // ✅ Importamos el CustomAppBarClipper
import '../../../core/services/firebase_service.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    context.read<ResidentialBloc>().add(FetchResidentials());
    _firebaseService.initializeFCM();
  }

  void _logout(BuildContext context) async {
    await Storage.removeToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  void _showAddResidentialDialog(BuildContext context) {
    final TextEditingController codigoVecindarioController = TextEditingController();
    final TextEditingController calleController = TextEditingController();
    final TextEditingController numeroCasaController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Registrar Residencial"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codigoVecindarioController,
                  decoration: InputDecoration(labelText: "Código Vecindario"),
                  validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: calleController,
                  decoration: InputDecoration(labelText: "Calle"),
                  validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
                ),
                TextFormField(
                  controller: numeroCasaController,
                  decoration: InputDecoration(labelText: "Número Casa"),
                  validator: (value) => value == null || value.isEmpty ? "Campo requerido" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newResidential = {
                    "codigoVecindario": codigoVecindarioController.text,
                    "calle": calleController.text,
                    "numeroCasa": numeroCasaController.text
                  };
                  context.read<ResidentialBloc>().add(AddResidential(newResidential));
                  Navigator.pop(context);
                }
              },
              child: Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 AppBar Personalizado con Logo en el centro y Logout a la derecha
          ClipPath(
            clipper: CustomAppBarClipper(),
            child: Container(
              height: 115,
              color: Color(0xFF003C8F),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 48), // Espacio para balancear el diseño
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/logoVA1.png',
                        height: 70, // Ajusta el tamaño del logo
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Contenido debajo del AppBar
          Padding(
            padding: EdgeInsets.only(top: 100, left: 16, right: 16),
            child: BlocConsumer<ResidentialBloc, ResidentialState>(
              listener: (context, state) {
                if (state is ResidentialAdded || state is ResidentialDeleted) {
                  context.read<ResidentialBloc>().add(FetchResidentials());
                }
              },
              builder: (context, state) {
                if (state is ResidentialLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ResidentialLoaded) {
                  if (state.residentials.isEmpty) {
                    return Center(child: Text("No hay residenciales registrados."));
                  }
                  return ListView.builder(
                    itemCount: state.residentials.length,
                    itemBuilder: (context, index) {
                      return ResidentialCard(residential: state.residentials[index]);
                    },
                  );
                } else {
                  return Center(child: Text("Error al cargar los residenciales"));
                }
              },
            ),
          ),
        ],
      ),

      // 🔹 Botón Flotante para Agregar Residencial
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddResidentialDialog(context),
        backgroundColor: Color(0xFF003C8F),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
