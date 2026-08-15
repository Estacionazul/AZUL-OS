import 'package:flutter/foundation.dart';

import '../models/movimiento_inventario_model.dart';
import '../repositories/insumo_repository.dart';
import '../repositories/movimiento_inventario_repository.dart';
import '../repositories/producto_repository.dart';
import 'insumo_service.dart';
import 'producto_service.dart';

class MovimientoInventarioService extends ChangeNotifier {
  final MovimientoInventarioRepository _repository;

  final ProductoRepository _productoRepository;
  final InsumoRepository _insumoRepository;

  final ProductoService _productoService;
  final InsumoService _insumoService;

  MovimientoInventarioService({
    required MovimientoInventarioRepository repository,
    required ProductoRepository productoRepository,
    required InsumoRepository insumoRepository,
    required ProductoService productoService,
    required InsumoService insumoService,
  })  : _repository = repository,
        _productoRepository = productoRepository,
        _insumoRepository = insumoRepository,
        _productoService = productoService,
        _insumoService = insumoService;

  List<MovimientoInventarioModel> _movimientos = [];

  List<MovimientoInventarioModel> get movimientos =>
      List.unmodifiable(_movimientos);

  // ==========================================================
  // CARGAR KARDEX
  // ==========================================================

  Future<void> cargarMovimientos() async {
    _movimientos = await _repository.obtenerTodos();

    notifyListeners();
  }

  // ==========================================================
  // VALIDAR MOVIMIENTOS
  // ==========================================================

  Future<void> validarDisponibilidad(
      List<MovimientoInventarioModel> movimientos,
      ) async {
    await _calcularNuevosStocks(movimientos);
  }

  // ==========================================================
  // REGISTRAR UN SOLO MOVIMIENTO
  // ==========================================================

  Future<void> registrarMovimiento(
      MovimientoInventarioModel movimiento,
      ) async {
    await registrarMovimientos([
      movimiento,
    ]);
  }

  // ==========================================================
  // REGISTRAR VARIOS MOVIMIENTOS
  //
  // IMPORTANTE:
  // Todos se procesan como una sola operación.
  // ==========================================================

  Future<void> registrarMovimientos(
      List<MovimientoInventarioModel> movimientos,
      ) async {
    if (movimientos.isEmpty) {
      return;
    }

    final stocks = await _calcularNuevosStocks(
      movimientos,
    );

    await _repository.registrarMovimientos(
      movimientos: movimientos,
      nuevosStocksProducto: stocks.productos,
      nuevosStocksInsumo: stocks.insumos,
    );

    // ========================================================
    // REFRESCAR ESTADO DE LA APLICACIÓN
    // ========================================================

    await _productoService.cargarProductos();
    await _insumoService.obtenerTodos();
    await cargarMovimientos();
  }

  // ==========================================================
  // CALCULAR STOCKS
  // ==========================================================

  Future<_StocksCalculados> _calcularNuevosStocks(
      List<MovimientoInventarioModel> movimientos,
      ) async {
    final nuevosProductos = <int, int>{};
    final nuevosInsumos = <int, double>{};

    for (final movimiento in movimientos) {
      // ======================================================
      // VALIDACIONES GENERALES
      // ======================================================

      if (movimiento.cantidad <= 0) {
        throw StateError(
          'La cantidad del movimiento debe ser mayor a 0.',
        );
      }

      if (movimiento.signo != 1 &&
          movimiento.signo != -1) {
        throw StateError(
          'El signo del movimiento debe ser 1 o -1.',
        );
      }

      final tieneProducto =
          movimiento.productoId != null;

      final tieneInsumo =
          movimiento.insumoId != null;

      if (tieneProducto == tieneInsumo) {
        throw StateError(
          'Un movimiento debe pertenecer a un producto '
              'O a un insumo, pero no a ambos.',
        );
      }

      // ======================================================
      // PRODUCTO
      // ======================================================

      if (tieneProducto) {
        final productoId = movimiento.productoId!;

        if (movimiento.cantidad !=
            movimiento.cantidad.roundToDouble()) {
          throw StateError(
            'Los productos se manejan en unidades enteras.',
          );
        }

        final producto =
        await _productoRepository.obtenerPorId(
          productoId,
        );

        if (producto == null) {
          throw StateError(
            'No existe el producto ID $productoId.',
          );
        }

        final stockActual =
            nuevosProductos[productoId] ??
                producto.stock;

        final delta =
            movimiento.cantidad.round() *
                movimiento.signo;

        final nuevoStock =
            stockActual + delta;

        if (nuevoStock < 0) {
          throw StateError(
            'Stock insuficiente de ${producto.nombre}. '
                'Stock actual: ${producto.stock}. '
                'Cantidad solicitada: ${movimiento.cantidad}.',
          );
        }

        nuevosProductos[productoId] =
            nuevoStock;
      }

      // ======================================================
      // INSUMO
      // ======================================================

      if (tieneInsumo) {
        final insumoId = movimiento.insumoId!;

        final insumo =
        await _insumoRepository.obtenerPorId(
          insumoId,
        );

        if (insumo == null) {
          throw StateError(
            'No existe el insumo ID $insumoId.',
          );
        }

        final stockActual =
            nuevosInsumos[insumoId] ??
                insumo.stock;

        final delta =
            movimiento.cantidad *
                movimiento.signo;

        final nuevoStock =
            stockActual + delta;

        if (nuevoStock < -0.000001) {
          throw StateError(
            'Stock insuficiente de ${insumo.nombre}. '
                'Stock actual: ${insumo.stock.toStringAsFixed(3)} '
                '${insumo.unidadMedida}.',
          );
        }

        nuevosInsumos[insumoId] =
        nuevoStock < 0 ? 0 : nuevoStock;
      }
    }

    return _StocksCalculados(
      productos: nuevosProductos,
      insumos: nuevosInsumos,
    );
  }

  // ==========================================================
  // ELIMINAR
  //
  // POR AHORA NO PERMITIMOS ELIMINAR MOVIMIENTOS.
  //
  // El Kardex es auditoría.
  // Después implementaremos reversión formal.
  // ==========================================================

  Future<void> eliminarMovimiento(int id) async {
    throw StateError(
      'Los movimientos de inventario no se eliminan. '
          'Para corregir un movimiento se debe registrar '
          'una reversión o ajuste.',
    );
  }

  // ==========================================================
  // STOCK HISTÓRICO DEL KARDEX
  // ==========================================================

  double calcularStock({
    required int? insumoId,
    required int? productoId,
  }) {
    double total = 0;

    for (final movimiento in _movimientos) {
      if (insumoId != null &&
          movimiento.insumoId == insumoId) {
        total +=
            movimiento.cantidad *
                movimiento.signo;
      }

      if (productoId != null &&
          movimiento.productoId == productoId) {
        total +=
            movimiento.cantidad *
                movimiento.signo;
      }
    }

    return total;
  }
}

// ============================================================
// RESULTADO INTERNO
// ============================================================

class _StocksCalculados {
  final Map<int, int> productos;
  final Map<int, double> insumos;

  const _StocksCalculados({
    required this.productos,
    required this.insumos,
  });
}