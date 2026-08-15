import 'package:flutter/foundation.dart';

import '../models/movimiento_inventario_model.dart';
import '../repositories/insumo_repository.dart';
import '../repositories/movimiento_inventario_repository.dart';
import '../repositories/producto_repository.dart';

class MovimientoInventarioService extends ChangeNotifier {
  final MovimientoInventarioRepository _repository;
  final ProductoRepository _productoRepository;
  final InsumoRepository _insumoRepository;

  MovimientoInventarioService({
    required MovimientoInventarioRepository repository,
    required ProductoRepository productoRepository,
    required InsumoRepository insumoRepository,
  })  : _repository = repository,
        _productoRepository = productoRepository,
        _insumoRepository = insumoRepository;

  List<MovimientoInventarioModel> _movimientos = [];

  List<MovimientoInventarioModel> get movimientos =>
      List.unmodifiable(_movimientos);

  Future<void> cargarMovimientos() async {
    _movimientos = await _repository.obtenerTodos();
    notifyListeners();
  }

  Future<void> registrarMovimiento(
      MovimientoInventarioModel movimiento,
      ) async {
    // ==========================================
    // ACTUALIZAR STOCK REAL
    // ==========================================

    if (movimiento.productoId != null) {
      final producto =
      await _productoRepository.obtenerPorId(movimiento.productoId!);

      if (producto != null) {
        final stockActual = producto.stock;

        final nuevoStock =
            stockActual + (movimiento.cantidad * movimiento.signo).round();

        await _productoRepository.actualizarStock(
          producto.id!,
          nuevoStock,
        );
      }
    }

    if (movimiento.insumoId != null) {
      final insumo =
      await _insumoRepository.obtenerPorId(movimiento.insumoId!);

      if (insumo != null) {
        final stockActual = insumo.stock;

        final nuevoStock =
            stockActual + (movimiento.cantidad * movimiento.signo);

        await _insumoRepository.actualizarStock(
          insumo.id!,
          nuevoStock,
        );
      }
    }

    // ==========================================
    // REGISTRAR MOVIMIENTO EN KARDEX
    // ==========================================

    await _repository.insertar(movimiento);

    await cargarMovimientos();
  }

  Future<void> eliminarMovimiento(int id) async {
    await _repository.eliminar(id);
    await cargarMovimientos();
  }

  double calcularStock({
    required int? insumoId,
    required int? productoId,
  }) {
    double total = 0;

    for (final movimiento in _movimientos) {
      if (insumoId != null && movimiento.insumoId == insumoId) {
        total += movimiento.cantidad * movimiento.signo;
      }

      if (productoId != null && movimiento.productoId == productoId) {
        total += movimiento.cantidad * movimiento.signo;
      }
    }

    return total;
  }
}