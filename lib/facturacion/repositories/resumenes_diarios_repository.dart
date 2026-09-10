import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../database/dao/resumenes_diarios_dao.dart';
import '../../database/dao/resumenes_diarios_detalles_dao.dart';

class ResumenesDiariosRepository {
  final AppDatabase _database;
  final ResumenesDiariosDao _dao;
  final ResumenesDiariosDetallesDao _detallesDao;

  ResumenesDiariosRepository(AppDatabase database)
      : _database = database,
        _dao = ResumenesDiariosDao(database),
        _detallesDao = ResumenesDiariosDetallesDao(database);

  Future<int> crear(ResumenesDiariosCompanion resumen) {
    return _dao.crear(resumen);
  }

  Future<int> crearConDetalles({
    required ResumenesDiariosCompanion resumen,
    required List<ResumenesDiariosDetallesCompanion> detalles,
  }) {
    return _database.transaction(() async {
      final resumenId = await _dao.crear(resumen);

      for (final detalle in detalles) {
        await _detallesDao.crear(
          detalle.copyWith(
            resumenDiarioId: Value(resumenId),
          ),
        );
      }

      return resumenId;
    });
  }

  Future<ResumenesDiario?> obtenerPorId(int id) {
    return _dao.obtenerPorId(id);
  }

  Future<List<ResumenesDiario>> obtenerPorFecha(DateTime fecha) {
    return _dao.obtenerPorFecha(fecha);
  }

  Future<int?> obtenerUltimoCorrelativoPorFecha(DateTime fecha) {
    return _dao.obtenerUltimoCorrelativoPorFecha(fecha);
  }

  Future<List<ResumenesDiario>> obtenerPendientes() {
    return _dao.obtenerPendientes();
  }

  Future<bool> actualizarTicket(
      int id,
      String ticket,
      ) {
    return _dao.actualizarTicket(id, ticket);
  }

  Future<bool> actualizarRespuestaSunat({
    required int id,
    required String estado,
    String? codigo,
    String? mensaje,
    String? cdr,
    DateTime? fechaRespuesta,
  }) {
    return _dao.actualizarRespuestaSunat(
      id: id,
      estado: estado,
      codigo: codigo,
      mensaje: mensaje,
      cdr: cdr,
      fechaRespuesta: fechaRespuesta,
    );
  }

  Future<bool> actualizarXml({
    required int id,
    required String xml,
    required String nombreArchivo,
  }) {
    return _dao.actualizarXml(
      id: id,
      xml: xml,
      nombreArchivo: nombreArchivo,
    );
  }

  Future<bool> actualizarEstado({
    required int id,
    required String estado,
  }) {
    return _dao.actualizarEstado(
      id: id,
      estado: estado,
    );
  }

  Future<int> crearDetalle(
      ResumenesDiariosDetallesCompanion detalle,
      ) {
    return _detallesDao.crear(detalle);
  }

  Future<List<ResumenesDiariosDetalle>> obtenerDetallesPorResumenDiario(
      int resumenDiarioId,
      ) {
    return _detallesDao.obtenerPorResumenDiario(resumenDiarioId);
  }

  Future<ResumenesDiariosDetalle?> obtenerDetallePorResumenYComprobante({
    required int resumenDiarioId,
    required int comprobanteElectronicoId,
  }) {
    return _detallesDao.obtenerPorResumenYComprobante(
      resumenDiarioId: resumenDiarioId,
      comprobanteElectronicoId: comprobanteElectronicoId,
    );
  }

  Future<List<ResumenesDiariosDetalle>> obtenerDetallesPorComprobante(
      int comprobanteElectronicoId,
      ) {
    return _detallesDao.obtenerPorComprobante(comprobanteElectronicoId);
  }

  Future<ResumenesDiariosDetalle?> obtenerDetallePorResumenYLinea({
    required int resumenDiarioId,
    required int lineId,
  }) {
    return _detallesDao.obtenerPorResumenYLinea(
      resumenDiarioId: resumenDiarioId,
      lineId: lineId,
    );
  }
}