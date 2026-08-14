import 'package:flutter/foundation.dart';

import '../models/movimiento_inventario_model.dart';
import '../repositories/movimiento_inventario_repository.dart';

class MovimientoInventarioService extends ChangeNotifier {
  final MovimientoInventarioRepository _repository;

  MovimientoInventarioService(this._repository);

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
      if (insumoId != null &&
          movimiento.insumoId == insumoId) {
        total += movimiento.cantidad * movimiento.signo;
      }

      if (productoId != null &&
          movimiento.productoId == productoId) {
        total += movimiento.cantidad * movimiento.signo;
      }
    }

    return total;
  }
}