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

    // 1. Cargar ingredientes de la receta
    await recetaDetalleService.cargarIngredientes(receta.id!);

    final ingredientes = recetaDetalleService.ingredientes;
    debugPrint("TOTAL INGREDIENTES: ${ingredientes.length}");

    for (final i in ingredientes) {
      debugPrint(
        "Insumo: ${i.insumoId} - Cantidad: ${i.cantidad}",
      );
    }

    if (ingredientes.isEmpty) {
      return "La receta no tiene ingredientes.";
    }

    // 2. Verificar stock de todos los ingredientes
    for (final ingrediente in ingredientes) {

      final insumo = await insumoService.obtenerPorId(
        ingrediente.insumoId,
      );

      if (insumo == null) {
        return "No existe el insumo ID ${ingrediente.insumoId}.";
      }

      final requerido =
          ingrediente.cantidad * cantidad;

      if (insumo.stock < requerido) {
        return "Stock insuficiente de ${insumo.nombre}.";
      }
    }

    // 3. Descontar todos los ingredientes
    for (final ingrediente in ingredientes) {

      final insumo = await insumoService.obtenerPorId(
        ingrediente.insumoId,
      );

      if (insumo == null) continue;

      final requerido =
          ingrediente.cantidad * cantidad;

      await insumoService.disminuirStock(
        insumo,
        requerido,
      );

          await movimientoService.registrarMovimiento(
            MovimientoInventarioModel(
              fecha: DateTime.now(),
              tipo: "PRODUCCION",

              nombreItem: insumo.nombre,
              emoji: insumo.emoji,
              unidad: insumo.unidadMedida,

              referenciaId: receta.id,
              insumoId: insumo.id,
              productoId: receta.productoId,

              cantidad: requerido,
              signo: -1,

              observacion:
              "Consumo para producir ${receta.nombre}",
            ),
          );
    }

    // 4. Aumentar stock del producto terminado
    final producto =
    productoService.obtenerProducto(
      receta.productoId,
    );

    if (producto == null) {
      return "No existe el producto.";
    }

    await productoService.aumentarStock(
      receta.productoId,
      cantidad,
    );

    return "Producción realizada correctamente.";
  }
}