import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/resumenes_diarios_table.dart';

part 'resumenes_diarios_dao.g.dart';

@DriftAccessor(tables: [ResumenesDiarios])
class ResumenesDiariosDao extends DatabaseAccessor<AppDatabase>
    with _$ResumenesDiariosDaoMixin {
  ResumenesDiariosDao(super.db);

  /// Crea un nuevo resumen diario.
  Future<int> crear(ResumenesDiariosCompanion resumen) {
    return into(resumenesDiarios).insert(resumen);
  }

  /// Obtiene un resumen por su ID.
  Future<ResumenesDiario?> obtenerPorId(int id) {
    return (select(resumenesDiarios)
          ..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  /// Obtiene todos los resumenes de una fecha de referencia.
  Future<List<ResumenesDiario>> obtenerPorFecha(DateTime fecha) {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    return (select(resumenesDiarios)
          ..where(
            (r) =>
                r.fechaReferencia.isBiggerOrEqualValue(inicio) &
                r.fechaReferencia.isSmallerThanValue(fin),
          )
          ..orderBy([
            (r) => OrderingTerm(expression: r.correlativo),
          ]))
        .get();
  }

  /// Obtiene el ultimo correlativo registrado para una fecha.
  Future<int?> obtenerUltimoCorrelativoPorFecha(DateTime fecha) async {
    final resumenes = await obtenerPorFecha(fecha);

    if (resumenes.isEmpty) {
      return null;
    }

    return resumenes
        .map((r) => r.correlativo)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Obtiene los resumenes que aun estan pendientes de envio.
  Future<List<ResumenesDiario>> obtenerPendientes() {
    return (select(resumenesDiarios)
          ..where((r) => r.estado.equals('pendiente'))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fechaReferencia),
            (r) => OrderingTerm(expression: r.correlativo),
          ]))
        .get();
  }

  /// Actualiza el ticket asignado por SUNAT.
  Future<bool> actualizarTicket(
      int id,
      String ticket,
      ) async {
    final filasActualizadas =
    await (update(resumenesDiarios)..where((r) => r.id.equals(id))).write(
      ResumenesDiariosCompanion(
        ticketSunat: Value(ticket),
        estado: const Value('enviado'),
        fechaEnvioSunat: Value(DateTime.now()),
      ),
    );

    return filasActualizadas > 0;
  }

  /// Guarda la respuesta de SUNAT y el CDR.
  Future<bool> actualizarRespuestaSunat({
    required int id,
    required String estado,
    String? codigo,
    String? mensaje,
    String? cdr,
    DateTime? fechaRespuesta,
  }) async {
    final filasActualizadas =
    await (update(resumenesDiarios)..where((r) => r.id.equals(id))).write(
      ResumenesDiariosCompanion(
        estado: Value(estado),
        codigoRespuestaSunat: Value(codigo),
        mensajeRespuestaSunat: Value(mensaje),
        cdr: Value(cdr),
        fechaRespuestaSunat: Value(fechaRespuesta ?? DateTime.now()),
      ),
    );

    return filasActualizadas > 0;
  }

  /// Guarda el XML generado del resumen.
  Future<bool> actualizarXml({
    required int id,
    required String xml,
    required String nombreArchivo,
  }) async {
    final filasActualizadas =
    await (update(resumenesDiarios)..where((r) => r.id.equals(id))).write(
      ResumenesDiariosCompanion(
        xml: Value(xml),
        nombreArchivo: Value(nombreArchivo),
      ),
    );

    return filasActualizadas > 0;
  }

  /// Actualiza únicamente el estado del resumen diario.
  Future<bool> actualizarEstado({
    required int id,
    required String estado,
  }) async {
    final filasActualizadas =
    await (update(resumenesDiarios)..where((r) => r.id.equals(id))).write(
      ResumenesDiariosCompanion(
        estado: Value(estado),
      ),
    );

    return filasActualizadas > 0;
  }
}