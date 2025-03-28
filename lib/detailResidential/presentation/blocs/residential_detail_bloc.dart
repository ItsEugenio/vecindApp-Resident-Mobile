import 'dart:developer'; // Para logs detallados
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/residential.dart';
import '../../domain/repositories/residential_repository.dart';

/// 🎯 Eventos
sealed class ResidentialDetailEvent {}

class FetchResidentialById extends ResidentialDetailEvent {
  final int id;
  FetchResidentialById(this.id);
}

class GenerateGuestCode extends ResidentialDetailEvent {
  final int residenciaId;
  final int usos;
  GenerateGuestCode({required this.residenciaId, required this.usos});
}

class ToggleVisitMode extends ResidentialDetailEvent {
  final int residenciaId;
  final bool modoVisita;
  ToggleVisitMode({required this.residenciaId, required this.modoVisita});
}

/// 🎯 Estados
sealed class ResidentialDetailState {}

class ResidentialDetailInitial extends ResidentialDetailState {}

class ResidentialDetailLoading extends ResidentialDetailState {}

class ResidentialDetailLoaded extends ResidentialDetailState {
  final Residential residential;
  ResidentialDetailLoaded(this.residential);
}

class ResidentialDetailError extends ResidentialDetailState {
  final String message;
  ResidentialDetailError(this.message);
}

/// 📌 Bloc
class ResidentialDetailBloc extends Bloc<ResidentialDetailEvent, ResidentialDetailState> {
  final ResidentialRepository repository;

  ResidentialDetailBloc(this.repository) : super(ResidentialDetailInitial()) {

    /// ✅ Obtener residencial por ID
    on<FetchResidentialById>((event, emit) async {
      log("🔄 [BlocR] Iniciando carga de residencial con ID: ${event.id}");
      emit(ResidentialDetailLoading());
      try {
        final residential = await repository.getResidentialById(event.id);
        log("✅ [BlocR] Residencial cargado correctamente: ${residential.nombreNeighborhood}");
        emit(ResidentialDetailLoaded(residential));
      } catch (e) {
        log("❌ [BlocR] Error al cargar residencial: $e");
        emit(ResidentialDetailError("Error al obtener los datos del residencial."));
      }
    });

    /// ✅ Generar código de invitado
    on<GenerateGuestCode>((event, emit) async {
      print("📤 [BlocR] Evento `GenerateGuestCode` recibido: ResidenciaID=${event.residenciaId}, Usos=${event.usos}");

      try {
        await repository.generateGuestCode(event.residenciaId, event.usos);
        print("✅ [BlocR] Código generado con éxito, recargando datos...");

        /// 🔄 Volver a cargar el residencial
        add(FetchResidentialById(event.residenciaId));
      } catch (e) {
        print("❌ [BlocR] Error al generar código: $e");
        emit(ResidentialDetailError("Error al generar el código de invitado."));
      }
    });

    on<ToggleVisitMode>((event, emit) async {
      print("📤 [BlocR] Enviando petición `toggleVisitMode`...");

      try {
        await repository.toggleVisitMode(event.residenciaId, event.modoVisita); // ✅ Ejecuta la acción sin devolver nada.

        print("✅ [BlocR] Modo visita actualizado correctamente. Recargando datos...");
        add(FetchResidentialById(event.residenciaId)); // 🔄 Volver a cargar el residencial.

      } catch (e) {
        print("❌ [BlocR] Excepción en toggleVisitMode: $e");
        emit(ResidentialDetailError("Error al actualizar el modo visita."));
      }
    });


  }
}
