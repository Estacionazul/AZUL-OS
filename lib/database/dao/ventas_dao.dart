import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ventas_table.dart';
import '../tables/detalle_ventas_table.dart';

part 'ventas_dao.g.dart';

@DriftAccessor(
  tables: [
    Ventas,
    DetalleVentas,
  ],
)
class VentasDao extends DatabaseAccessor<AppDatabase>
    with _$VentasDaoMixin {
  VentasDao(AppDatabase db) : super(db);

  // ==========================================================
  // TRANSACCIÓN GENERAL
  //
  // Permite que una operación superior pueda ejecutar varias
  // operaciones de base de datos dentro de UNA SOLA transacción.
  // ==========================================================

  Future<T> ejecutarEnTransaccion<T>(
      Future<T> Function() accion,
      ) {
    return transaction(accion);
  }

  // ==========================================================
  // GUARDAR VENTA COMPLETA
  //
  // Método público tradicional.
  //
  // Mantiene compatibilidad con el código existente.
  // ==========================================================

  Future<int> guardarVentaCompleta({
    required VentasCompanion venta,
    required List<DetalleVentasCompanion> detalles,
  }) async {
    return transaction(() async {
      return guardarVentaCompletaSinTransaccion(
        venta: venta,
        detalles: detalles,
      );
    });
  }

  // ==========================================================
  // GUARDAR VENTA SIN ABRIR OTRA TRANSACCIÓN
  //
  // IMPORTANTE:
  //
  // Este método está preparado para utilizarse dentro de una
  // transacción superior que también actualice inventario.
  // ==========================================================

  Future<int> guardarVentaCompletaSinTransaccion({
    required VentasCompanion venta,
    required List<DetalleVentasCompanion> detalles,
  }) async {
    final ventaId = await into(ventas).insert(
      venta,
    );

    for (final detalle in detalles) {
      await into(detalleVentas).insert(
        detalle.copyWith(
          ventaId: Value(ventaId),
        ),
      );
    }

    return ventaId;
  }

  // ==========================================================
  // OBTENER TODAS LAS VENTAS
  // ==========================================================

  Future<List<Venta>> obtenerVentas() {
    return (select(ventas)
      ..orderBy([
            (t) => OrderingTerm.desc(t.fecha),
      ]))
        .get();
  }

  // ==========================================================
  // OBTENER UNA VENTA
  // ==========================================================

  Future<Venta?> obtenerVenta(int id) {
    return (select(ventas)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // ==========================================================
  // OBTENER DETALLE DE UNA VENTA
  // ==========================================================

  Future<List<DetalleVenta>> obtenerDetalleVenta(
      int ventaId,
      ) {
    return (select(detalleVentas)
      ..where((t) => t.ventaId.equals(ventaId)))
        .get();
  }

  // ==========================================================
  // ELIMINAR VENTA COMPLETA
  // ==========================================================

  Future<void> eliminarVenta(int ventaId) async {
    await transaction(() async {
      await (delete(detalleVentas)
        ..where(
              (t) => t.ventaId.equals(ventaId),
        ))
          .go();

      await (delete(ventas)
        ..where(
              (t) => t.id.equals(ventaId),
        ))
          .go();
    });
  }

  // ==========================================================
  // LIMPIAR TODAS LAS VENTAS
  // ==========================================================

  Future<void> limpiarVentas() async {
    await transaction(() async {
      await delete(detalleVentas).go();
      await delete(ventas).go();
    });
  }

  // ==========================================================
  // OBTENER EL ÚLTIMO NÚMERO DE VENTA
  // ==========================================================

  Future<String?> obtenerUltimoNumeroVenta() async {
    final ultimaVenta = await (select(ventas)
      ..where(
            (t) => t.tipoDocumento.equals('Nota de Venta'),
      )
      ..orderBy([
            (t) => OrderingTerm.desc(t.id),
      ])
      ..limit(1))
        .getSingleOrNull();

    return ultimaVenta?.numero;
  }
}