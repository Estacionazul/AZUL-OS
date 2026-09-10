import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/resumenes_diarios_detalles_table.dart';

part 'resumenes_diarios_detalles_dao.g.dart';

@DriftAccessor(tables: [ResumenesDiariosDetalles])
class ResumenesDiariosDetallesDao extends DatabaseAccessor<AppDatabase>
    with _$ResumenesDiariosDetallesDaoMixin {
  ResumenesDiariosDetallesDao(super.db);

  /// Registra un comprobante dentro de un Resumen Diario.
  Future<int> crear(
      ResumenesDiariosDetallesCompanion detalle,
      ) {
    return into(resumenesDiariosDetalles).insert(detalle);
  }

  /// Obtiene todas las boletas incluidas en un Resumen Diario.
  Future<List<ResumenesDiariosDetalle>> obtenerPorResumenDiario(
      int resumenDiarioId,
      ) {
    return (select(resumenesDiariosDetalles)
      ..where(
            (d) => d.resumenDiarioId.equals(resumenDiarioId),
      )
      ..orderBy([
            (d) => OrderingTerm(
          expression: d.lineId,
          mode: OrderingMode.asc,
        ),
      ]))
        .get();
  }

  /// Comprueba si un comprobante ya fue incluido
  /// en un Resumen Diario específico.
  Future<ResumenesDiariosDetalle?> obtenerPorResumenYComprobante({
    required int resumenDiarioId,
    required int comprobanteElectronicoId,
  }) {
    return (select(resumenesDiariosDetalles)
      ..where(
            (d) =>
        d.resumenDiarioId.equals(resumenDiarioId) &
        d.comprobanteElectronicoId.equals(comprobanteElectronicoId),
      ))
        .getSingleOrNull();
  }

  /// Obtiene la relación de un comprobante con todos
  /// los Resúmenes Diarios donde fue incluido.
  Future<List<ResumenesDiariosDetalle>> obtenerPorComprobante(
      int comprobanteElectronicoId,
      ) {
    return (select(resumenesDiariosDetalles)
      ..where(
            (d) => d.comprobanteElectronicoId.equals(
          comprobanteElectronicoId,
        ),
      )
      ..orderBy([
            (d) => OrderingTerm(
          expression: d.resumenDiarioId,
          mode: OrderingMode.desc,
        ),
      ]))
        .get();
  }

  /// Obtiene una línea específica de un Resumen Diario.
  Future<ResumenesDiariosDetalle?> obtenerPorResumenYLinea({
    required int resumenDiarioId,
    required int lineId,
  }) {
    return (select(resumenesDiariosDetalles)
      ..where(
            (d) =>
        d.resumenDiarioId.equals(resumenDiarioId) &
        d.lineId.equals(lineId),
      ))
        .getSingleOrNull();
  }

  /// Obtiene todos los detalles registrados.
  Future<List<ResumenesDiariosDetalle>> obtenerTodos() {
    return (select(resumenesDiariosDetalles)
      ..orderBy([
            (d) => OrderingTerm(
          expression: d.resumenDiarioId,
          mode: OrderingMode.desc,
        ),
            (d) => OrderingTerm(
          expression: d.lineId,
          mode: OrderingMode.asc,
        ),
      ]))
        .get();
  }
}