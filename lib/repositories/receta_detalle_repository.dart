import 'package:drift/drift.dart' as drift;

import '../database/app_database.dart';
import '../database/dao/receta_detalle_dao.dart';
import '../models/receta_detalle_model.dart';

class RecetaDetalleRepository {
  final RecetaDetalleDao _dao;

  RecetaDetalleRepository(this._dao);

  /// Obtener todos los ingredientes
  Future<List<RecetaDetalleModel>> obtenerTodos() async {
    final lista = await _dao.obtenerTodos();

    return lista.map(_toModel).toList();
  }

  /// Obtener ingredientes de una receta
  Future<List<RecetaDetalleModel>> obtenerPorReceta(int recetaId) async {
    final lista = await _dao.obtenerPorReceta(recetaId);

    return lista.map(_toModel).toList();
  }

  /// Insertar ingrediente
  Future<void> insertar(RecetaDetalleModel detalle) async {
    await _dao.insertar(
      RecetaDetalleCompanion.insert(
        recetaId: detalle.recetaId,
        insumoId: detalle.insumoId,
        cantidad: drift.Value(detalle.cantidad),
        unidad: drift.Value(detalle.unidad),
        orden: drift.Value(detalle.orden),
      ),
    );
  }

  /// Actualizar ingrediente
  Future<void> actualizar(RecetaDetalleModel detalle) async {
    await _dao.actualizar(
      RecetaDetalleData(
        id: detalle.id!,
        recetaId: detalle.recetaId,
        insumoId: detalle.insumoId,
        cantidad: detalle.cantidad,
        unidad: detalle.unidad,
        orden: detalle.orden,
      ),
    );
  }

  /// Eliminar ingrediente
  Future<void> eliminar(int id) async {
    await _dao.eliminar(id);
  }

  /// Eliminar todos los ingredientes de una receta
  Future<void> eliminarPorReceta(int recetaId) async {
    await _dao.eliminarPorReceta(recetaId);
  }

  RecetaDetalleModel _toModel(RecetaDetalleData data) {
    return RecetaDetalleModel(
      id: data.id,
      recetaId: data.recetaId,
      insumoId: data.insumoId,
      cantidad: data.cantidad,
      unidad: data.unidad,
      orden: data.orden,
    );
  }
}
