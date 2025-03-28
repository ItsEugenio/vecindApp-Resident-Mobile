import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../login/presentation/pages/login_page.dart';
import '../../domain/repositories/residential_repository.dart';
import '../../domain/entities/residential.dart';

// 🎯 Eventos del Bloc
sealed class ResidentialEvent {}

class FetchResidentials extends ResidentialEvent {} // GET
class AddResidential extends ResidentialEvent {
  final Map<String, String> newResidential;
  AddResidential(this.newResidential);
}
class DeleteResidential extends ResidentialEvent {
  final int id;
  DeleteResidential(this.id);
}

// 🎯 Estados del Bloc
sealed class ResidentialState {}

class ResidentialInitial extends ResidentialState {}
class ResidentialLoading extends ResidentialState {}
class ResidentialLoaded extends ResidentialState {
  final List<Residential> residentials;
  ResidentialLoaded(this.residentials);
}
class ResidentialError extends ResidentialState {}
class ResidentialAdded extends ResidentialState {
  final Residential residential;
  ResidentialAdded(this.residential);
}
class ResidentialDeleted extends ResidentialState {}

// 🎯 Implementación del Bloc
class ResidentialBloc extends Bloc<ResidentialEvent, ResidentialState> {
  final ResidentialRepository repository;
  BuildContext? _context;

  ResidentialBloc(this.repository) : super(ResidentialInitial()) {
    on<FetchResidentials>((event, emit) async {
      emit(ResidentialLoading());
      try {
        final residentials = await repository.getResidentials();
        emit(ResidentialLoaded(residentials));
      } catch (e) {
        emit(ResidentialError());
      }
    });

    on<AddResidential>((event, emit) async {
      try {
        final newResidential = await repository.registerToNeighborhood(event.newResidential);

        print("✅ [ResidentialBloc] Residencial agregado: ${newResidential.nombreNeighborhood}");

        // ✅ Si el POST fue exitoso, ejecutamos inmediatamente el GET
        final updatedResidentials = await repository.getResidentials();

        emit(ResidentialLoaded(updatedResidentials)); // 🔄 Actualizar UI con los datos reales de la API
      } catch (e) {
        print("❌ [ResidentialBloc] Error en AddResidential: $e"); // 🔍 Agregar log
        emit(ResidentialError());
      }
    });

    on<DeleteResidential>((event, emit) async {
      try {
        await repository.deleteResidential(event.id);
        final updatedResidentials = await repository.getResidentials();
        emit(ResidentialLoaded(updatedResidentials));
      } catch (e) {
        emit(ResidentialError());
      }
    });
  }

  // Configurar el contexto para manejar la redirección al login
  void setContext(BuildContext context) {
    _context = context;
  }

  void handleExpiredToken() {
    if (_context != null) {
      Navigator.of(_context!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }
}
