import '../database/app_database.dart';
import '../database/dao/movimientos_inventario_dao.dart';
import '../models/movimiento_inventario_model.dart';
import 'package:drift/drift.dart';

class MovimientoInventarioRepository {
  final MovimientosInventarioDao _dao;

  MovimientoInventarioRepository(
      AppDatabase database,
      ) : _dao = MovimientosInventarioDao(database);

  Future<List<MovimientoInventarioModel>> obtenerTodos() async {
    final lista = await _dao.obtenerTodos();

    return lista.map((e) {
      return MovimientoInventarioModel(
        id: e.id,
        fecha: e.fecha,
        tipo: e.tipo,
        nombreItem: e.nombreItem,
        emoji: e.emoji,
        unidad: e.unidad,
        referenciaId: e.referenciaId,
        insumoId: e.insumoId,
        productoId: e.productoId,
        cantidad: e.cantidad,
        signo: e.signo,
        observacion: e.observacion,
      );
    }).toList();
  }

  Future<int> insertar(
      MovimientoInventarioModel movimiento,
      ) {
    return _dao.insertar(
      MovimientosInventarioCompanion.insert(
        tipo: movimiento.tipo,
        nombreItem: Value(movimiento.nombreItem),
        emoji: Value(movimiento.emoji),
        unidad: Value(movimiento.unidad),
        cantidad: movimiento.cantidad,
        signo: movimiento.signo,
        fecha: Value(movimiento.fecha),
        referenciaId: Value(movimiento.referenciaId),
        insumoId: Value(movimiento.insumoId),
        productoId: Value(movimiento.productoId),
        observacion: Value(movimiento.observacion),
      ),
    );
  }

  Future<int> eliminar(int id) {
    return _dao.eliminar(id);
  }
}