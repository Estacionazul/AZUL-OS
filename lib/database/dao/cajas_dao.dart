import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/cajas_table.dart';
import '../tables/movimientos_caja_table.dart';

part 'cajas_dao.g.dart';

@DriftAccessor(tables: [Cajas, MovimientosCaja])
class CajasDao extends DatabaseAccessor<AppDatabase>
    with _$CajasDaoMixin {
  CajasDao(super.db);

  // ==========================================================
  // CAJAS
  // ==========================================================

  /// Obtiene todas las cajas, de la más reciente a la más antigua.
  Future<List<Caja>> obtenerTodasLasCajas() {
    return (select(cajas)
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.fechaApertura,
          mode: OrderingMode.desc,
        ),
      ]))
        .get();
  }

  /// Obtiene la caja actualmente abierta.
  Future<Caja?> obtenerCajaAbierta() {
    return (select(cajas)
      ..where((t) => t.estado.equals('ABIERTA'))
      ..limit(1))
        .getSingleOrNull();
  }

  /// Obtiene una caja por ID.
  Future<Caja?> obtenerCajaPorId(int id) {
    return (select(cajas)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Abre una nueva caja.
  Future<int> abrirCaja(CajasCompanion datos) {
    return into(cajas).insert(datos);
  }

  /// Actualiza una caja existente.
  Future<bool> actualizarCaja(Caja datos) {
    return update(cajas).replace(datos);
  }

  // ==========================================================
  // MOVIMIENTOS
  // ==========================================================

  /// Obtiene todos los movimientos de una caja.
  Future<List<MovimientosCajaData>> obtenerMovimientosPorCaja(
      int cajaId,
      ) {
    return (select(movimientosCaja)
      ..where((t) => t.cajaId.equals(cajaId))
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.fecha,
          mode: OrderingMode.desc,
        ),
      ]))
        .get();
  }

  /// Registra un movimiento de caja.
  Future<int> registrarMovimiento(
      MovimientosCajaCompanion datos,
      ) {
    return into(movimientosCaja).insert(datos);
  }

  /// Obtiene el último movimiento registrado de una caja.
  Future<MovimientosCajaData?> obtenerUltimoMovimiento(
      int cajaId,
      ) {
    return (select(movimientosCaja)
      ..where((t) => t.cajaId.equals(cajaId))
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.fecha,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(1))
        .getSingleOrNull();
  }
}