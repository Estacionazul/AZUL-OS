import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/movimiento_inventario_model.dart';

class MovimientoInventarioMapper {
  static MovimientosInventarioCompanion toCompanion(
      MovimientoInventarioModel model,
      ) {
    return MovimientosInventarioCompanion(
      fecha: Value(model.fecha),
      tipo: Value(model.tipo),

      nombreItem: Value(model.nombreItem),
      emoji: Value(model.emoji),
      unidad: Value(model.unidad),

      referenciaId: Value(model.referenciaId),
      insumoId: Value(model.insumoId),
      productoId: Value(model.productoId),
      cantidad: Value(model.cantidad),
      signo: Value(model.signo),
      observacion: Value(model.observacion),
    );
  }

  static MovimientoInventarioModel toModel(
      MovimientosInventarioData data,
      ) {
    return MovimientoInventarioModel(
      id: data.id,
      fecha: data.fecha,
      tipo: data.tipo,

      nombreItem: data.nombreItem,
      emoji: data.emoji,
      unidad: data.unidad,

      referenciaId: data.referenciaId,
      insumoId: data.insumoId,
      productoId: data.productoId,
      cantidad: data.cantidad,
      signo: data.signo,
      observacion: data.observacion,
    );
  }
}