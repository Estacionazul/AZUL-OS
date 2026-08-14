class ClienteModel {
  final String id;
  final String nombre;

  final String? dni;
  final String? ruc;

  final String telefono;
  final String? correo;
  final String? direccion;

  final DateTime? fechaRegistro;
  final DateTime? ultimaVisita;

  final double totalGastado;
  final int cantidadCompras;

  final String? observaciones;

  // Reglas de negocio (no existen en la tabla todavía)
  final bool esVip;
  final int puntos;

  const ClienteModel({
    required this.id,
    required this.nombre,

    this.dni,
    this.ruc,

    required this.telefono,
    this.correo,
    this.direccion,

    this.fechaRegistro,
    this.ultimaVisita,

    this.totalGastado = 0,
    this.cantidadCompras = 0,

    this.observaciones,

    this.esVip = false,
    this.puntos = 0,
  });

  bool get cumpleHoy => false;
}