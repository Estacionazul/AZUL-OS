import 'package:flutter/foundation.dart';

import '../models/receta_model.dart';
import '../models/movimiento_inventario_model.dart';

import 'insumo_service.dart';
import 'movimiento_inventario_service.dart';
import 'producto_service.dart';
import 'receta_detalle_service.dart';

class ProduccionService extends ChangeNotifier {
  final ProductoService productoService;
  final InsumoService insumoService;
  final RecetaDetalleService recetaDetalleService;
  final MovimientoInventarioService movimientoService;

  ProduccionService({
    required this.productoService,
    required this.insumoService,
    required this.recetaDetalleService,
    required this.movimientoService,
  });

  Future<String> producir({
    required RecetaModel receta,
    required double cantidad,
  }) async {
    // ==========================================================
    // VALIDACIONES
    // ==========================================================

    if (cantidad <= 0) {
      return 'La cantidad a producir debe ser mayor a 0.';
    }

    if (cantidad != cantidad.roundToDouble()) {
      return 'La cantidad a producir debe ser un número entero.';
    }

    if (receta.id == null) {
      return 'La receta no tiene un ID válido.';
    }

    // ==========================================================
    // CARGAR INGREDIENTES
    // ==========================================================

    await recetaDetalleService.cargarIngredientes(receta.id!);

    final ingredientes =
    List.of(recetaDetalleService.ingredientes);

    debugPrint(
      'PRODUCCIÓN: ${receta.nombre} | '
          'Cantidad: $cantidad | '
          'Ingredientes: ${ingredientes.length}',
    );

    if (ingredientes.isEmpty) {
      return 'La receta no tiene ingredientes.';
    }

    // ==========================================================
    // VALIDAR PRODUCTO TERMINADO
    // ==========================================================

    final producto =
    productoService.obtenerProducto(receta.productoId);

    if (producto == null) {
      return 'No existe el producto asociado a la receta.';
    }

    // ==========================================================
    // CONSTRUIR MOVIMIENTOS
    //
    // IMPORTANTE:
    // Aquí NO modificamos directamente ningún stock.
    //
    // Todo se registra mediante MovimientoInventarioService
    // para que producto, insumos y Kardex queden sincronizados
    // dentro de la misma operación.
    // ==========================================================

    final movimientos =
    <MovimientoInventarioModel>[];

    // ----------------------------------------------------------
    // 1. CONSUMO DE INSUMOS
    // ----------------------------------------------------------

    for (final ingrediente in ingredientes) {
      final insumo =
      await insumoService.obtenerPorId(
        ingrediente.insumoId,
      );

      if (insumo == null) {
        return 'No existe el insumo ID ${ingrediente.insumoId}.';
      }

      final requerido =
          ingrediente.cantidad * cantidad;

      if (requerido <= 0) {
        return 'Cantidad inválida para el insumo ${insumo.nombre}.';
      }

      movimientos.add(
        MovimientoInventarioModel(
          fecha: DateTime.now(),
          tipo: 'PRODUCCION',
          nombreItem: insumo.nombre,
          emoji: insumo.emoji,
          unidad: insumo.unidadMedida,
          referenciaId: receta.id,
          insumoId: insumo.id,
          productoId: null,
          cantidad: requerido,
          signo: -1,
          observacion:
          'Consumo para producir ${receta.nombre}',
        ),
      );
    }

    // ----------------------------------------------------------
    // 2. ENTRADA DEL PRODUCTO TERMINADO
    // ----------------------------------------------------------

    movimientos.add(
      MovimientoInventarioModel(
        fecha: DateTime.now(),
        tipo: 'PRODUCCION',
        nombreItem: producto.nombre,
        emoji: producto.emoji,
        unidad: 'unidad',
        referenciaId: receta.id,
        insumoId: null,
        productoId: producto.id,
        cantidad: cantidad,
        signo: 1,
        observacion:
        'Producto terminado por producción '
            '${receta.nombre}',
      ),
    );

    // ==========================================================
    // VALIDAR TODA LA OPERACIÓN ANTES DE MODIFICAR STOCK
    // ==========================================================

    try {
      await movimientoService.validarDisponibilidad(
        movimientos,
      );
    } catch (e) {
      debugPrint(
        'Error validando producción: $e',
      );

      return 'No se puede realizar la producción: $e';
    }

    // ==========================================================
    // REGISTRAR TODA LA PRODUCCIÓN
    //
    // MovimientoInventarioService se encarga de:
    //
    // - descontar insumos
    // - aumentar producto terminado
    // - registrar Kardex
    // - mantener la operación transaccional
    //
    // NO hacemos ningún cambio directo de stock aquí.
    // ==========================================================

    try {
      await movimientoService.registrarMovimientos(
        movimientos,
      );

      debugPrint(
        'Producción realizada correctamente: '
            '${receta.nombre} x $cantidad',
      );

      return 'Producción realizada correctamente.';
    } catch (e, stackTrace) {
      debugPrint(
        'Error en producción: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      return 'No se pudo realizar la producción: $e';
    }
  }
}