import '../models/venta.dart';
import '../models/movimiento_inventario_model.dart';
import '../repositories/recetas_repository.dart';
import 'insumo_service.dart';
import 'movimiento_inventario_service.dart';
import 'producto_service.dart';

class InventarioAutomaticoService {
  final RecetasRepository _recetasRepository;

  final ProductoService _productoService;
  final InsumoService _insumoService;
  final MovimientoInventarioService _movimientoService;

  InventarioAutomaticoService({
    required RecetasRepository recetasRepository,
    required ProductoService productoService,
    required InsumoService insumoService,
    required MovimientoInventarioService movimientoService,
  })  : _recetasRepository = recetasRepository,
        _productoService = productoService,
        _insumoService = insumoService,
        _movimientoService = movimientoService;

  // ==========================================================
  // VALIDAR UNA VENTA
  //
  // NO modifica stock.
  //
  // Solo comprueba que todos los movimientos de la venta
  // puedan realizarse correctamente.
  // ==========================================================

  Future<void> validarVenta(Venta venta) async {
    final movimientos =
    await _construirMovimientosVenta(venta);

    await _movimientoService.validarDisponibilidad(
      movimientos,
    );
  }

  // ==========================================================
  // DESCONTAR INVENTARIO DE UNA VENTA
  //
  // Todos los movimientos de la venta se registran juntos.
  // ==========================================================

  Future<void> descontarInventario(Venta venta) async {
    final movimientos =
    await _construirMovimientosVenta(venta);

    await _movimientoService.registrarMovimientos(
      movimientos,
    );
  }

  // ==========================================================
  // CONSTRUIR MOVIMIENTOS
  // ==========================================================

  Future<List<MovimientoInventarioModel>>
  _construirMovimientosVenta(
      Venta venta,
      ) async {
    final movimientos =
    <MovimientoInventarioModel>[];

    for (final item in venta.items) {
      final producto =
      _productoService.obtenerProducto(
        item.producto.id!,
      );

      if (producto == null) {
        throw StateError(
          'No existe el producto '
              '${item.producto.nombre}.',
        );
      }

      // ======================================================
      // PRODUCTO NORMAL
      // ======================================================

      if (producto.tipoInventario == 'producto') {
        movimientos.add(
          MovimientoInventarioModel(
            fecha: venta.fecha,
            tipo: 'VENTA',
            nombreItem: producto.nombre,
            emoji: producto.emoji,
            unidad: 'unidad',
            referenciaId: null,
            insumoId: null,
            productoId: producto.id,
            cantidad: item.cantidad.toDouble(),
            signo: -1,
            observacion:
            'Consumo por venta ${venta.numero}',
          ),
        );

        continue;
      }

      // ======================================================
      // PRODUCTO CON RECETA
      // ======================================================

      if (producto.tipoInventario == 'receta') {
        final receta =
        await _recetasRepository
            .obtenerPorProducto(
          producto.id!,
        );

        if (receta == null) {
          throw StateError(
            'El producto ${producto.nombre} '
                'está configurado como receta pero '
                'no tiene una receta registrada.',
          );
        }

        if (receta.id == null) {
          throw StateError(
            'La receta de ${producto.nombre} '
                'no tiene un ID válido.',
          );
        }

        final detalle =
        await _recetasRepository.obtenerDetalle();

        final ingredientes = detalle
            .where(
              (d) => d.recetaId == receta.id,
        )
            .toList();

        if (ingredientes.isEmpty) {
          throw StateError(
            'La receta ${receta.nombre} '
                'no tiene ingredientes.',
          );
        }

        for (final ingrediente
        in ingredientes) {
          final insumo =
          await _insumoService.obtenerPorId(
            ingrediente.insumoId,
          );

          if (insumo == null) {
            throw StateError(
              'No existe el insumo ID '
                  '${ingrediente.insumoId}.',
            );
          }

          final requerido =
              ingrediente.cantidad *
                  item.cantidad;

          if (requerido <= 0) {
            throw StateError(
              'La receta ${receta.nombre} '
                  'tiene una cantidad inválida '
                  'para ${insumo.nombre}.',
            );
          }

          movimientos.add(
            MovimientoInventarioModel(
              fecha: venta.fecha,
              tipo: 'VENTA',
              nombreItem: insumo.nombre,
              emoji: insumo.emoji,
              unidad: insumo.unidadMedida,
              referenciaId: null,
              insumoId: insumo.id,
              productoId: null,
              cantidad: requerido,
              signo: -1,
              observacion:
              'Consumo por venta ${venta.numero} '
                  '— ${producto.nombre}',
            ),
          );
        }

        continue;
      }

      // ======================================================
      // TIPO DESCONOCIDO
      // ======================================================

      throw StateError(
        'Tipo de inventario desconocido '
            'para ${producto.nombre}: '
            '${producto.tipoInventario}',
      );
    }

    return movimientos;
  }
}