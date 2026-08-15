import 'package:flutter/foundation.dart';

import '../models/produccion_model.dart';
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
    if (cantidad <= 0) {
      return "La cantidad debe ser mayor a 0.";
    }

    if (receta.id == null) {
      return "La receta no tiene un ID válido.";
    }

    // ========================================================
    // 1. CARGAR INGREDIENTES
    // ========================================================

    await recetaDetalleService.cargarIngredientes(
      receta.id!,
    );

    final ingredientes =
        recetaDetalleService.ingredientes;

    if (ingredientes.isEmpty) {
      return "La receta no tiene ingredientes.";
    }

    // ========================================================
    // 2. VALIDAR STOCK
    // ========================================================

    for (final ingrediente in ingredientes) {
      final insumo =
      await insumoService.obtenerPorId(
        ingrediente.insumoId,
      );

      if (insumo == null) {
        return "No existe el insumo "
            "ID ${ingrediente.insumoId}.";
      }

      final requerido =
          ingrediente.cantidad * cantidad;

      if (insumo.stock < requerido) {
        return "Stock insuficiente de "
            "${insumo.nombre}. "
            "Disponible: "
            "${insumo.stock.toStringAsFixed(2)} "
            "${insumo.unidadMedida}.";
      }
    }

    // ========================================================
    // 3. CONSTRUIR MOVIMIENTOS
    // ========================================================

    final movimientos =
    <MovimientoInventarioModel>[];

    for (final ingrediente in ingredientes) {
      final insumo =
      await insumoService.obtenerPorId(
        ingrediente.insumoId,
      );

      if (insumo == null) {
        return "No existe el insumo.";
      }

      final requerido =
          ingrediente.cantidad * cantidad;

      // ------------------------------------------------------
      // CONSUMO DEL INSUMO
      // ------------------------------------------------------

      movimientos.add(
        MovimientoInventarioModel(
          fecha: DateTime.now(),
          tipo: "PRODUCCION",
          nombreItem: insumo.nombre,
          emoji: insumo.emoji,
          unidad: insumo.unidadMedida,
          referenciaId: receta.id,
          insumoId: insumo.id,
          productoId: null,
          cantidad: requerido,
          signo: -1,
          observacion:
          "Consumo para producir "
              "${receta.nombre}",
        ),
      );
    }

    // ========================================================
    // 4. AUMENTAR PRODUCTO TERMINADO
    // ========================================================

    final producto =
    productoService.obtenerProducto(
      receta.productoId,
    );

    if (producto == null) {
      return "No existe el producto terminado.";
    }

    if (cantidad != cantidad.roundToDouble()) {
      return "La producción del producto "
          "terminado debe ser en unidades enteras.";
    }

    movimientos.add(
      MovimientoInventarioModel(
        fecha: DateTime.now(),
        tipo: "PRODUCCION",
        nombreItem: producto.nombre,
        emoji: producto.emoji,
        unidad: "unidad",
        referenciaId: receta.id,
        insumoId: null,
        productoId: producto.id,
        cantidad: cantidad,
        signo: 1,
        observacion:
        "Producto terminado de "
            "${receta.nombre}",
      ),
    );

    // ========================================================
    // 5. VALIDAR TODO
    // ========================================================

    try {
      await movimientoService.validarDisponibilidad(
        movimientos,
      );

      // ======================================================
      // 6. EJECUTAR TODO EN UNA SOLA TRANSACCIÓN
      // ======================================================

      await movimientoService.registrarMovimientos(
        movimientos,
      );

      return "Producción realizada correctamente.";
    } catch (e) {
      return e.toString().replaceFirst(
        'Bad state: ',
        '',
      );
    }
  }
}