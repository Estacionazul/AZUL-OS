import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/receta_model.dart';
import '../models/receta_detalle_model.dart';

class RecetaMapper {
  // ===========================
  // RECETAS
  // ===========================

  static RecetaModel toModel(Receta receta) {
    return RecetaModel(
      id: receta.id,
      productoId: receta.productoId,
      nombre: receta.nombre,
      activo: receta.activo,
      fechaCreacion: receta.fechaCreacion,
    );
  }

  static RecetasCompanion toCompanion(RecetaModel model) {
    return RecetasCompanion.insert(
      productoId: model.productoId,
      nombre: model.nombre,
      activo: Value(model.activo),
    );
  }

  // ===========================
  // DETALLE
  // ===========================

  static RecetaDetalleModel toDetalleModel(
      RecetaDetalleData detalle,
      ) {
    return RecetaDetalleModel(
      id: detalle.id,
      recetaId: detalle.recetaId,
      insumoId: detalle.insumoId,
      cantidad: detalle.cantidad,
      unidad: detalle.unidad,
      orden: detalle.orden,
    );
  }

  static RecetaDetalleCompanion toDetalleCompanion(
      RecetaDetalleModel model,
      ) {
    return RecetaDetalleCompanion.insert(
      recetaId: model.recetaId,
      insumoId: model.insumoId,
      cantidad: Value(model.cantidad),
      unidad: Value(model.unidad),
      orden: Value(model.orden),
    );
  }
}