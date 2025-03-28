import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/residential_detail_bloc.dart';
import '../../domain/entities/residential.dart';

class DetailResidential extends StatelessWidget {
  final int residentialId;

  const DetailResidential({Key? key, required this.residentialId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Disparar evento al abrir la vista
    context.read<ResidentialDetailBloc>().add(FetchResidentialById(residentialId));

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Residencial")),
      body: BlocConsumer<ResidentialDetailBloc, ResidentialDetailState>(
        listener: (context, state) {
          if (state is ResidentialDetailLoaded) {
            print("✅ [UI] Datos actualizados: Código Invitado = ${state.residential.codigoInvitado}");
          }
        },
        builder: (context, state) {
          if (state is ResidentialDetailLoading) {
            print("🔄 [UI] Cargando datos del residencial...");
            return const Center(child: CircularProgressIndicator());
          } else if (state is ResidentialDetailLoaded) {
            print("✅ [UI] Datos del residencial cargados.");
            return Column(
              children: [
                _buildDetailCard(state.residential),
                _buildGuestCodeCard(context, state.residential),
                _buildVisitModeCard(context, state.residential),
              ],
            );
          } else {
            print("❌ [UI] Error al cargar el residencial.");
            return const Center(child: Text("Error al cargar"));
          }
        },
      ),
    );
  }

  // 📌 Card de información del residencial
  Widget _buildDetailCard(Residential residential) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Calle", residential.calle),
              _buildDetailRow("Número de Casa", residential.numeroCasa),
              _buildDetailRow("Nombre del Vecindario", residential.nombreNeighborhood),
              _buildDetailRow("Modo Visita", residential.modoVisita ? "Sí" : "No"),
              _buildDetailRow("Usos de Código", residential.codeUses.toString()),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Card de Código Invitado
  Widget _buildGuestCodeCard(BuildContext context, Residential residential) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Código de Invitado",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                residential.codigoInvitado.isNotEmpty ? residential.codigoInvitado : "No disponible",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _showGenerateCodeDialog(context),
                child: const Text("Generar Código"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Card para activar/desactivar Modo Visita
  Widget _buildVisitModeCard(BuildContext context, Residential residential) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Modo Visita",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: residential.modoVisita,
                onChanged: (newValue) => _showConfirmVisitModeDialog(context, newValue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Modal para confirmar activación/desactivación de Modo Visita
  void _showConfirmVisitModeDialog(BuildContext context, bool newValue) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(newValue ? "Activar Modo Visita" : "Desactivar Modo Visita"),
          content: Text(newValue
              ? "¿Estás seguro de que quieres activar el Modo Visita?"
              : "¿Estás seguro de que quieres desactivar el Modo Visita?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                print("📤 [UI] Enviando evento `ToggleVisitMode` con modoVisita: $newValue");

                // ✅ Enviar el evento al Bloc
                context.read<ResidentialDetailBloc>().add(
                  ToggleVisitMode(residenciaId: residentialId, modoVisita: newValue),
                );

                Navigator.pop(dialogContext);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  // 📌 Modal para generar código de invitado
  void _showGenerateCodeDialog(BuildContext context) {
    final TextEditingController usosController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Generar Código de Invitado"),
          content: TextField(
            controller: usosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Cantidad de Usos (mínimo 1)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final usos = int.tryParse(usosController.text) ?? 0;
                if (usos >= 1) {
                  print("📤 [UI] Enviando evento `GenerateGuestCode` con usos: $usos");

                  context.read<ResidentialDetailBloc>().add(
                    GenerateGuestCode(residenciaId: residentialId, usos: usos),
                  );

                  Navigator.pop(dialogContext);
                } else {
                  print("⚠️ [UI] Número de usos inválido.");
                }
              },
              child: const Text("Generar"),
            ),
          ],
        );
      },
    );
  }

  // 📌 Componente de fila para detalles
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
