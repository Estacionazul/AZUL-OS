import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/dao/cajas_dao.dart';

class CajasRepository {
  final CajasDao _dao;

  CajasRepository(AppDatabase database)
      : _dao = CajasDao(database);

  // ==========================================================
  // CAJAS
  // ==========================================================

  /// Obtiene todas las cajas registradas.
  Future<List<Caja>> obtenerTodas() {
    return _dao.obtenerTodasLasCajas();
  }

  /// Obtiene la caja actualmente abierta.
  Future<Caja?> obtenerAbierta() {
    return _dao.obtenerCajaAbierta();
  }

  /// Obtiene una caja por su ID.
  Future<Caja?> obtenerPorId(int id) {
    return _dao.obtenerCajaPorId(id);
  }

  /// Abre una nueva caja.
  Future<int> abrir({
    required double montoInicial,
  }) {
    return _dao.abrirCaja(
      CajasCompanion(
        montoInicial: Value(montoInicial),
        estado: const Value('ABIERTA'),
      ),
    );
  }

  /// Actualiza una caja existente.
  Future<bool> actualizar(Caja caja) {
    return _dao.actualizarCaja(caja);
  }

  // ==========================================================
  // MOVIMIENTOS DE CAJA
  // ==========================================================

  /// Obtiene los movimientos de una caja.
  Future<List<MovimientosCajaData>> obtenerMovimientos(
      int cajaId,
      ) {
    return _dao.obtenerMovimientosPorCaja(cajaId);
  }

  /// Registra un movimiento de caja.
  Future<int> registrarMovimiento(
      MovimientosCajaCompanion datos,
      ) {
    return _dao.registrarMovimiento(datos);
  }

  /// Obtiene el último movimiento de una caja.
  Future<MovimientosCajaData?> obtenerUltimoMovimiento(
      int cajaId,
      ) {
    return _dao.obtenerUltimoMovimiento(cajaId);
  }
}