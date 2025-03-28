import '../../domain/entities/residential.dart';

class ResidentialModel extends Residential {
  ResidentialModel({
    required int id,
    required String calle,
    required String numeroCasa,
    required String nombreNeighborhood,
    required bool modoVisita,
    required String codigoInvitado,
    required int codeUses,
  }) : super(
    id: id,
    calle: calle,
    numeroCasa: numeroCasa,
    nombreNeighborhood: nombreNeighborhood,
    modoVisita: modoVisita,
    codigoInvitado: codigoInvitado,
    codeUses: codeUses,
  );

  factory ResidentialModel.fromJson(Map<String, dynamic> json) {
    return ResidentialModel(
      id: json['id'],
      calle: json['calle'],
      numeroCasa: json['numeroCasa'],
      nombreNeighborhood: json['nombreNeighborhood'],
      modoVisita: json['modoVisita'] ?? false,
      codigoInvitado: json['codigoInvitado'] ?? "",
      codeUses: json['codeUses'] ?? 0,
    );
  }
}
