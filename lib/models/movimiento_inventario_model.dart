class MovimientoInventarioModel {
  final int? id;

  final DateTime fecha;

  final String tipo;

  final String nombreItem;

  final String emoji;

  final String unidad;

  final int? referenciaId;

  final int? insumoId;

  final int? productoId;

  final double cantidad;

  final int signo;

  final String? observacion;

  const MovimientoInventarioModel({
    this.id,
    required this.fecha,
    required this.tipo,
    required this.nombreItem,
    required this.emoji,
    required this.unidad,
    this.referenciaId,
    this.insumoId,
    this.productoId,
    required this.cantidad,
    required this.signo,
    this.observacion,
  });

  MovimientoInventarioModel copyWith({
    int? id,
    DateTime? fecha,
    String? tipo,
    String? nombreItem,
    String? emoji,
    String? unidad,
    int? referenciaId,
    int? insumoId,
    int? productoId,
    double? cantidad,
    int? signo,
    String? observacion,
  }) {
    return MovimientoInventarioModel(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      nombreItem: nombreItem ?? this.nombreItem,
      emoji: emoji ?? this.emoji,
      unidad: unidad ?? this.unidad,
      referenciaId: referenciaId ?? this.referenciaId,
      insumoId: insumoId ?? this.insumoId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      signo: signo ?? this.signo,
      observacion: observacion ?? this.observacion,
    );
  }
}
