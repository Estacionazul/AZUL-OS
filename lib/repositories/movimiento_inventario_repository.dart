import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/dao/movimientos_inventario_dao.dart';
import '../database/dao/productos_dao.dart';
import '../database/dao/insumos_dao.dart';
import '../models/movimiento_inventario_model.dart';

class MovimientoInventarioRepository {
  final AppDatabase _database;

  final MovimientosInventarioDao _dao;
  final ProductosDao _productosDao;
  final InsumosDao _insumosDao;

  MovimientoInventarioRepository(AppDatabase database)
    : _database = database,
      _dao = MovimientosInventarioDao(database),
      _productosDao = ProductosDao(database),
      _insumosDao = InsumosDao(database);

  // ==========================================================
  // OBTENER MOVIMIENTOS
  // ==========================================================

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

  // ==========================================================
  // OBTENER POR ID
  // ==========================================================

  Future<MovimientoInventarioModel?> obtenerPorId(int id) async {
    final movimiento = await _dao.obtenerPorId(id);

    if (movimiento == null) {
      return null;
    }

    return MovimientoInventarioModel(
      id: movimiento.id,
      fecha: movimiento.fecha,
      tipo: movimiento.tipo,
      nombreItem: movimiento.nombreItem,
      emoji: movimiento.emoji,
      unidad: movimiento.unidad,
      referenciaId: movimiento.referenciaId,
      insumoId: movimiento.insumoId,
      productoId: movimiento.productoId,
      cantidad: movimiento.cantidad,
      signo: movimiento.signo,
      observacion: movimiento.observacion,
    );
  }

  // ==========================================================
  // REGISTRAR MOVIMIENTOS
  //
  // Método público normal.
  //
  // Cuando se utiliza directamente, crea su propia transacción.
  // ==========================================================

  Future<List<int>> registrarMovimientos({
    required List<MovimientoInventarioModel> movimientos,
    required Map<int, int> nuevosStocksProducto,
    required Map<int, double> nuevosStocksInsumo,
  }) async {
    if (movimientos.isEmpty) {
      return [];
    }

    return _database.transaction(() async {
      return registrarMovimientosSinTransaccion(
        movimientos: movimientos,
        nuevosStocksProducto: nuevosStocksProducto,
        nuevosStocksInsumo: nuevosStocksInsumo,
      );
    });
  }

  // ==========================================================
  // REGISTRAR MOVIMIENTOS SIN TRANSACCIÓN
  //
  // IMPORTANTE:
  //
  // Este método NO abre una transacción.
  //
  // Se utiliza cuando una operación superior ya controla una
  // transacción que incluye:
  //
  // VENTA
  // +
  // STOCK
  // +
  // KARDEX
  //
  // Si la operación superior falla, todo se revierte.
  // ==========================================================

  Future<List<int>> registrarMovimientosSinTransaccion({
    required List<MovimientoInventarioModel> movimientos,
    required Map<int, int> nuevosStocksProducto,
    required Map<int, double> nuevosStocksInsumo,
  }) async {
    if (movimientos.isEmpty) {
      return [];
    }

    final ids = <int>[];

    for (final movimiento in movimientos) {
      // ======================================================
      // PRODUCTO
      // ======================================================

      if (movimiento.productoId != null) {
        final nuevoStock = nuevosStocksProducto[movimiento.productoId!];

        if (nuevoStock == null) {
          throw StateError(
            'No se calculó el nuevo stock del producto '
            '${movimiento.productoId}.',
          );
        }

        final actualizado = await _productosDao.actualizarStock(
          movimiento.productoId!,
          nuevoStock,
        );

        if (!actualizado) {
          throw StateError('No se pudo actualizar el stock del producto.');
        }
      }

      // ======================================================
      // INSUMO
      // ======================================================

      if (movimiento.insumoId != null) {
        final nuevoStock = nuevosStocksInsumo[movimiento.insumoId!];

        if (nuevoStock == null) {
          throw StateError(
            'No se calculó el nuevo stock del insumo '
            '${movimiento.insumoId}.',
          );
        }

        final actualizado = await _insumosDao.actualizarStock(
          movimiento.insumoId!,
          nuevoStock,
        );

        if (!actualizado) {
          throw StateError('No se pudo actualizar el stock del insumo.');
        }
      }

      // ======================================================
      // KARDEX
      // ======================================================

      final id = await _dao.insertar(
        MovimientosInventarioCompanion.insert(
          fecha: Value(movimiento.fecha),
          tipo: movimiento.tipo,
          nombreItem: Value(movimiento.nombreItem),
          emoji: Value(movimiento.emoji),
          unidad: Value(movimiento.unidad),
          referenciaId: Value(movimiento.referenciaId),
          insumoId: Value(movimiento.insumoId),
          productoId: Value(movimiento.productoId),
          cantidad: movimiento.cantidad,
          signo: movimiento.signo,
          observacion: Value(movimiento.observacion),
        ),
      );

      ids.add(id);
    }

    return ids;
  }

  // ==========================================================
  // ELIMINAR
  // ==========================================================

  Future<int> eliminar(int id) {
    return _dao.eliminar(id);
  }
}
