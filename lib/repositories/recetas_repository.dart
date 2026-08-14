import '../database/app_database.dart';
import '../database/dao/recetas_dao.dart';
import '../database/dao/receta_detalle_dao.dart';

import '../mappers/receta_mapper.dart';

import '../models/receta_model.dart';
import '../models/receta_detalle_model.dart';

class RecetasRepository {
  final RecetasDao _recetasDao;
  final RecetaDetalleDao _detalleDao;

  RecetasRepository(AppDatabase database)
      : _recetasDao = RecetasDao(database),
        _detalleDao = RecetaDetalleDao(database);

  // ==========================
  // RECETAS
  // ==========================

  Future<List<RecetaModel>> obtenerTodas() async {
    final recetas = await _recetasDao.obtenerTodas();

    return recetas
        .map(RecetaMapper.toModel)
        .toList();
  }

  Future<int> insertarReceta(
      RecetaModel receta,
      ) {
    return _recetasDao.insertar(
      RecetaMapper.toCompanion(receta),
    );
  }

  Future<bool> actualizarReceta(
      RecetaModel receta,
      ) {
    return _recetasDao.actualizar(
      Receta(
        id: receta.id!,
        productoId: receta.productoId,
        nombre: receta.nombre,
        activo: receta.activo,
        fechaCreacion:
        receta.fechaCreacion ?? DateTime.now(),
      ),
    );
  }

  Future<int> eliminarReceta(int id) {
    return _recetasDao.eliminar(id);
  }

  // ==========================
  // DETALLE
  // ==========================

  Future<List<RecetaDetalleModel>>
  obtenerDetalle() async {
    final detalle =
    await _detalleDao.obtenerTodos();

    return detalle
        .map(RecetaMapper.toDetalleModel)
        .toList();
  }

  Future<int> insertarDetalle(
      RecetaDetalleModel detalle,
      ) {
    return _detalleDao.insertar(
      RecetaMapper.toDetalleCompanion(detalle),
    );
  }

  Future<bool> actualizarDetalle(
      RecetaDetalleModel detalle,
      ) {
    return _detalleDao.actualizar(
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

  Future<int> eliminarDetalle(int id) {
    return _detalleDao.eliminar(id);
  }
}