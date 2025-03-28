class ResidentialModel {
  final int id;
  final String calle;
  final String numeroCasa;
  final String nombreNeighborhood;
  final bool modoVisita;
  final String codigoInvitado;

  ResidentialModel({
    required this.id,
    required this.calle,
    required this.numeroCasa,
    required this.nombreNeighborhood, // ✅ Se asigna correctamente
    required this.modoVisita,
    required this.codigoInvitado,
  });

  factory ResidentialModel.fromJson(Map<String, dynamic> json) {
    return ResidentialModel(
      id: json['id'] as int,
      calle: json['calle'] as String,
      numeroCasa: json['numeroCasa'] as String,
      nombreNeighborhood: json['nombreNeighborhood'] ?? "Sin Nombre", // ✅ Asigna correctamente desde GET
      modoVisita: json['modoVisita'] ?? false,
      codigoInvitado: json['codigoInvitado'] is String ? json['codigoInvitado'] as String : "",
    );
  }
}
