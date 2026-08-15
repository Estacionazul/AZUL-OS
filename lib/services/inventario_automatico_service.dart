import '../database/app_database.dart' hide Venta;
import '../models/venta.dart';
import '../models/movimiento_inventario_model.dart';
import '../repositories/insumo_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/recetas_repository.dart';
import '../repositories/movimiento_inventario_repository.dart';

class InventarioAutomaticoService {
  final ProductoRepository _productoRepository;
  final RecetasRepository _recetasRepository;
  final InsumoRepository _insumoRepository;
  final MovimientoInventarioRepository _movimientoRepository;

  InventarioAutomaticoService(AppDatabase database)
      : _productoRepository = ProductoRepository(database),
        _recetasRepository = RecetasRepository(database),
        _insumoRepository = InsumoRepository(database),
        _movimientoRepository =
        MovimientoInventarioRepository(database);

  Future<void> descontarInventario(Venta venta) async {
    for (final item in venta.items) {
      final producto =
      await _productoRepository.obtenerPorId(item.producto.id!);

      if (producto == null) {
        continue;
      }

      // ==========================================
      // PRODUCTO NORMAL
      // ==========================================

      if (producto.tipoInventario == 'producto') {
        final stockAnterior = producto.stock;

        final cantidadVendida = item.cantidad;

        final nuevoStock =
            stockAnterior - cantidadVendida;

        await _productoRepository.actualizarStock(
          producto.id!,
          nuevoStock,
        );

        // Registrar salida en Kardex
        await _movimientoRepository.insertar(
          MovimientoInventarioModel(
            tipo: 'SALIDA',
            fecha: DateTime.now(),
            nombreItem: producto.nombre,
            emoji: producto.emoji,
            unidad: 'unidad',
            referenciaId: null,
            insumoId: null,
            productoId: producto.id,
            cantidad: cantidadVendida.toDouble(),
            signo: -1,
            observacion:
            'Salida por venta ${venta.numero}',
          ),
        );

        continue;
      }

      // ==========================================
      // PRODUCTO CON RECETA
      // ==========================================

      if (producto.tipoInventario == 'receta') {
        final recetas =
        await _recetasRepository.obtenerTodas();

        // Buscar receta del producto
        final recetasEncontradas = recetas
            .where((r) => r.productoId == producto.id)
            .toList();

        // Si no existe receta, no detener la venta
        if (recetasEncontradas.isEmpty) {
          print(
            '⚠️ No existe receta configurada para: '
                '${item.producto.nombre}',
          );
          continue;
        }

        final receta = recetasEncontradas.first;

        // ========================================
        // OBTENER INGREDIENTES
        // ========================================

        final detalle =
        await _recetasRepository.obtenerDetalle();

        final ingredientes = detalle
            .where((d) => d.recetaId == receta.id)
            .toList();

        for (final ingrediente in ingredientes) {
          final insumo =
          await _insumoRepository.obtenerPorId(
            ingrediente.insumoId,
          );

          if (insumo == null) {
            continue;
          }

          // ======================================
          // CALCULAR CONSUMO REAL
          // ======================================

          final cantidadConsumida =
              ingrediente.cantidad * item.cantidad;

          final stockAnterior = insumo.stock;

          final nuevoStock =
              stockAnterior - cantidadConsumida;

          // ======================================
          // ACTUALIZAR STOCK
          // ======================================

          await _insumoRepository.actualizarStock(
            insumo.id!,
            nuevoStock,
          );

          // ======================================
          // REGISTRAR KARDEX
          // ======================================

          await _movimientoRepository.insertar(
            MovimientoInventarioModel(
              tipo: 'SALIDA',
              fecha: DateTime.now(),
              nombreItem: insumo.nombre,
              emoji: insumo.emoji,
              unidad: ingrediente.unidad,
              referenciaId: null,
              insumoId: insumo.id,
              productoId: producto.id,
              cantidad: cantidadConsumida,
              signo: -1,
              observacion:
              'Consumo por venta ${venta.numero} - '
                  '${producto.nombre}',
            ),
          );
        }
      }
    }
  }
}