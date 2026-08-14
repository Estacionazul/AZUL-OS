import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/insumo_model.dart';

class InsumoMapper {
  /// Convierte un Insumo de Drift a InsumoModel
  static InsumoModel toModel(Insumo insumo) {
    return InsumoModel(
      id: insumo.id,
      codigo: insumo.codigo,
      nombre: insumo.nombre,
      descripcion: insumo.descripcion,
      categoriaId: insumo.categoriaId,
      unidadMedida: insumo.unidadMedida,
      stock: insumo.stock,
      stockMinimo: insumo.stockMinimo,
      costoCompra: insumo.costoCompra,
      emoji: insumo.emoji,
      imagen: insumo.imagen,
      activo: insumo.activo,
    );
  }

  /// Convierte un InsumoModel a InsumosCompanion
  static InsumosCompanion toCompanion(InsumoModel model) {
    return InsumosCompanion(
      id: model.id == null
          ? const Value.absent()
          : Value(model.id!),
      codigo: Value(model.codigo),
      nombre: Value(model.nombre),
      descripcion: Value(model.descripcion),
      categoriaId: Value(model.categoriaId),
      unidadMedida: Value(model.unidadMedida),
      stock: Value(model.stock),
      stockMinimo: Value(model.stockMinimo),
      costoCompra: Value(model.costoCompra),
      emoji: Value(model.emoji),
      imagen: Value(model.imagen),
      activo: Value(model.activo),
    );
  }
}