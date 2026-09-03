class ProduccionModel {
  final int? id;
  final int recetaId;
  final int productoId;
  final double cantidad;
  final DateTime fecha;
  final String? observacion;

  ProduccionModel({
    this.id,
    required this.recetaId,
    required this.productoId,
    required this.cantidad,
    required this.fecha,
    this.observacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'receta_id': recetaId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'observacion': observacion,
    };
  }

  factory ProduccionModel.fromMap(Map<String, dynamic> map) {
    return ProduccionModel(
      id: map['id'],
      recetaId: map['receta_id'],
      productoId: map['producto_id'],
      cantidad: (map['cantidad'] as num).toDouble(),
      fecha: DateTime.parse(map['fecha']),
      observacion: map['observacion'],
    );
  }

  ProduccionModel copyWith({
    int? id,
    int? recetaId,
    int? productoId,
    double? cantidad,
    DateTime? fecha,
    String? observacion,
  }) {
    return ProduccionModel(
      id: id ?? this.id,
      recetaId: recetaId ?? this.recetaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
      observacion: observacion ?? this.observacion,
    );
  }
}
