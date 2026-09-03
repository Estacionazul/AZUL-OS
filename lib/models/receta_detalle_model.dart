class RecetaDetalleModel {
  final int? id;
  final int recetaId;
  final int insumoId;
  final double cantidad;
  final String unidad;
  final int orden;

  const RecetaDetalleModel({
    this.id,
    required this.recetaId,
    required this.insumoId,
    required this.cantidad,
    required this.unidad,
    this.orden = 0,
  });

  RecetaDetalleModel copyWith({
    int? id,
    int? recetaId,
    int? insumoId,
    double? cantidad,
    String? unidad,
    int? orden,
  }) {
    return RecetaDetalleModel(
      id: id ?? this.id,
      recetaId: recetaId ?? this.recetaId,
      insumoId: insumoId ?? this.insumoId,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      orden: orden ?? this.orden,
    );
  }
}
