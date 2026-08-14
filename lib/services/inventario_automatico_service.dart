import '../database/app_database.dart' hide Venta;
import '../models/venta.dart';
import '../repositories/insumo_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/recetas_repository.dart';

class InventarioAutomaticoService {
  final ProductoRepository _productoRepository;
  final RecetasRepository _recetasRepository;
  final InsumoRepository _insumoRepository;

  InventarioAutomaticoService(AppDatabase database)
      : _productoRepository = ProductoRepository(database),
        _recetasRepository = RecetasRepository(database),
        _insumoRepository = InsumoRepository(database);

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
        // Próximo paso:
        // Descontar stock del producto.
        continue;
      }

      // ==========================================
      // PRODUCTO CON RECETA
      // ==========================================

      if (producto.tipoInventario == 'receta') {
        final recetas = await _recetasRepository.obtenerTodas();

        // Buscar la receta del producto sin lanzar
        // una excepción si todavía no existe.
        final recetasEncontradas = recetas
            .where((r) => r.productoId == producto.id)
            .toList();

        // Si todavía no existe una receta configurada,
        // no detener la venta.
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
          final insumo = await _insumoRepository.obtenerPorId(
            ingrediente.insumoId,
          );

          if (insumo == null) {
            continue;
          }

          // Próximo paso:
          // Descontar cantidad del insumo.
        }
      }
    }
  }
}