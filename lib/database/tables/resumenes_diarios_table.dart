import 'package:drift/drift.dart';

class ResumenesDiarios extends Table {
  // ==========================================================
  // ID
  // ==========================================================

  IntColumn get id => integer().autoIncrement()();

  // ==========================================================
  // FECHA DEL RESUMEN
  // ==========================================================

  /// Fecha de emision de las boletas incluidas en el resumen.
  DateTimeColumn get fechaReferencia => dateTime()();

  /// Correlativo del resumen para la fecha indicada.
  /// Ejemplo: RC-20260908-1
  IntColumn get correlativo => integer()();

  // ==========================================================
  // ARCHIVO XML
  // ==========================================================

  /// Nombre del archivo XML enviado a SUNAT.
  TextColumn get nombreArchivo => text()();

  /// XML del Resumen Diario generado.
  TextColumn get xml => text().nullable()();

  // ==========================================================
  // ESTADO
  // ==========================================================

  /// pendiente
  /// generado
  /// enviado
  /// aceptado
  /// rechazado
  TextColumn get estado =>
      text().withDefault(const Constant('pendiente'))();

  // ==========================================================
  // TICKET SUNAT
  // ==========================================================

  /// Ticket devuelto por SUNAT mediante sendSummary.
  TextColumn get ticketSunat => text().nullable()();

  // ==========================================================
  // RESPUESTA SUNAT
  // ==========================================================

  TextColumn get codigoRespuestaSunat => text().nullable()();

  TextColumn get mensajeRespuestaSunat => text().nullable()();

  // ==========================================================
  // CDR
  // ==========================================================

  /// CDR recibido por SUNAT al consultar el ticket.
  TextColumn get cdr => text().nullable()();

  // ==========================================================
  // FECHAS DE COMUNICACION CON SUNAT
  // ==========================================================

  DateTimeColumn get fechaEnvioSunat => dateTime().nullable()();

  DateTimeColumn get fechaRespuestaSunat => dateTime().nullable()();

  // ==========================================================
  // OBSERVACIONES
  // ==========================================================

  TextColumn get observaciones => text().nullable()();
}
