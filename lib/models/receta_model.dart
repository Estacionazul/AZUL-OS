class RecetaModel {
  final int? id;
  final int productoId;
  final String nombre;
  final bool activo;
  final DateTime? fechaCreacion;

  const RecetaModel({
    this.id,
    required this.productoId,
    required this.nombre,
    this.activo = true,
    this.fechaCreacion,
  });

  RecetaModel copyWith({
    int? id,
    int? productoId,
    String? nombre,
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return RecetaModel(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
