import '../models/producto_model.dart';
import '../repositories/recetas_repository.dart';
import '../repositories/receta_detalle_repository.dart';
import '../repositories/insumo_repository.dart';

class DisponibilidadProductoService {
  final RecetasRepository _recetasRepository;
  final RecetaDetalleRepository _detalleRepository;
  final InsumoRepository _insumoRepository;

  DisponibilidadProductoService({
    required RecetasRepository recetasRepository,
    required RecetaDetalleRepository detalleRepository,
    required InsumoRepository insumoRepository,
  }) : _recetasRepository = recetasRepository,
       _detalleRepository = detalleRepository,
       _insumoRepository = insumoRepository;

  /// Calcula cuántas unidades de un producto con receta
  /// se pueden preparar con el stock actual de sus insumos.
  ///
  /// Si el producto es de inventario normal:
  /// devuelve directamente su stock.
  Future<int> calcularDisponibilidad(ProductoModel producto) async {
    // ==========================================
    // PRODUCTO NORMAL
    // ==========================================

    if (producto.tipoInventario == 'producto') {
      return producto.stock;
    }

    // ==========================================
    // PRODUCTO CON RECETA
    // ==========================================

    final receta = await _recetasRepository.obtenerPorProducto(producto.id!);

    // Si no tiene receta, no podemos calcular
    // una disponibilidad basada en insumos.
    if (receta == null || receta.id == null) {
      return 0;
    }

    final ingredientes = await _detalleRepository.obtenerPorReceta(receta.id!);

    if (ingredientes.isEmpty) {
      return 0;
    }

    int? disponibilidadMinima;

    for (final ingrediente in ingredientes) {
      // Evitar división entre cero.
      if (ingrediente.cantidad <= 0) {
        continue;
      }

      final insumo = await _insumoRepository.obtenerPorId(ingrediente.insumoId);

      if (insumo == null) {
        return 0;
      }

      final disponibles = (insumo.stock / ingrediente.cantidad).floor();

      if (disponibilidadMinima == null || disponibles < disponibilidadMinima) {
        disponibilidadMinima = disponibles;
      }
    }

    return disponibilidadMinima ?? 0;
  }
}
