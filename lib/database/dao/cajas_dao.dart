import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../app_database.dart';
import '../tables/cajas_table.dart';
import '../tables/movimientos_caja_table.dart';

part 'cajas_dao.g.dart';

@DriftAccessor(tables: [Cajas, MovimientosCaja])
class CajasDao extends DatabaseAccessor<AppDatabase> with _$CajasDaoMixin {
  CajasDao(super.db);

  // ==========================================================
  // TRANSACCIÓN GENERAL
  // ==========================================================
  //
  // Permite que una operación superior controle una única
  // transacción que incluya Caja + Venta + Inventario + Kardex.
  //
  // ==========================================================

  Future<T> ejecutarEnTransaccion<T>(Future<T> Function() accion) {
    return transaction(accion);
  }

  // ==========================================================
  // CAJAS
  // ==========================================================

  /// Obtiene todas las cajas, de la más reciente a la más antigua.
  Future<List<Caja>> obtenerTodasLasCajas() {
    return (select(cajas)..orderBy([
          (t) => OrderingTerm(
            expression: t.fechaApertura,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  /// Obtiene la caja actualmente abierta.
  Future<Caja?> obtenerCajaAbierta() async {
    debugPrint('========== BUSCANDO CAJA ABIERTA ==========');

    final cajasEncontradas =
        await (select(cajas)
              ..orderBy([
                (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
              ])
              ..limit(10))
            .get();

    debugPrint('TOTAL CAJAS ENCONTRADAS: ${cajasEncontradas.length}');

    for (final caja in cajasEncontradas) {
      debugPrint(
        'CAJA -> '
        'ID: ${caja.id} | '
        'ESTADO: ${caja.estado} | '
        'MONTO INICIAL: ${caja.montoInicial} | '
        'APERTURA: ${caja.fechaApertura}',
      );
    }

    final cajaAbierta =
        await (select(cajas)
              ..where((t) => t.estado.equals('ABIERTA'))
              ..limit(1))
            .getSingleOrNull();

    debugPrint(
      'RESULTADO CAJA ABIERTA: '
      '${cajaAbierta == null ? 'NULL' : 'ID ${cajaAbierta.id}'}',
    );

    debugPrint('============================================');

    return cajaAbierta;
  }

  /// Obtiene una caja por ID.
  Future<Caja?> obtenerCajaPorId(int id) {
    return (select(cajas)..where((t) => t.id.equals(id))).getSingleOrNull();
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
  Future<List<MovimientosCajaData>> obtenerMovimientosPorCaja(int cajaId) {
    return (select(movimientosCaja)
          ..where((t) => t.cajaId.equals(cajaId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Registra un movimiento de caja.
  Future<int> registrarMovimiento(MovimientosCajaCompanion datos) {
    return into(movimientosCaja).insert(datos);
  }

  // ==========================================================
  // REGISTRAR MOVIMIENTO SIN TRANSACCIÓN
  // ==========================================================
  //
  // Se utiliza cuando una transacción superior ya está abierta.
  //
  // ==========================================================

  Future<int> registrarMovimientoSinTransaccion(
    MovimientosCajaCompanion datos,
  ) {
    return into(movimientosCaja).insert(datos);
  }

  /// Obtiene el último movimiento registrado de una caja.
  Future<MovimientosCajaData?> obtenerUltimoMovimiento(int cajaId) {
    return (select(movimientosCaja)
          ..where((t) => t.cajaId.equals(cajaId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
