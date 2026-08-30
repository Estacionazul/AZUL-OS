import 'package:drift/drift.dart';

class ComprobantesElectronicos extends Table {
  // ==========================================================
  // ID
  // ==========================================================

  IntColumn get id => integer().autoIncrement()();

  // ==========================================================
  // RELACIONES INTERNAS
  // ==========================================================

  /// Venta interna de AZUL OS relacionada.
  IntColumn get ventaId => integer().nullable()();

  /// Comprobante electrónico relacionado.
  /// Principalmente utilizado para notas de crédito.
  IntColumn get comprobanteRelacionadoId =>
      integer().nullable()();

  // ==========================================================
  // TIPO Y NUMERACIÓN
  // ==========================================================

  /// notaVenta
  /// boleta
  /// factura
  /// notaCredito
  TextColumn get tipo =>
      text()();

  /// Serie SUNAT.
  ///
  /// Ejemplos:
  /// B001
  /// F001
  TextColumn get serie =>
      text().withLength(min: 1, max: 4)();

  /// Correlativo del comprobante.
  IntColumn get numero =>
      integer()();

  // ==========================================================
  // FECHA
  // ==========================================================

  DateTimeColumn get fechaEmision =>
      dateTime()();

  // ==========================================================
  // CLIENTE
  // ==========================================================

  TextColumn get dni =>
      text().nullable()();

  TextColumn get ruc =>
      text().nullable()();

  TextColumn get nombreCliente =>
      text().nullable()();

  TextColumn get direccionFiscal =>
      text().nullable()();

  // ==========================================================
  // IMPORTES
  // ==========================================================

  RealColumn get subtotal =>
      real()();

  RealColumn get igv =>
      real()();

  RealColumn get total =>
      real()();

  // ==========================================================
  // FORMA DE PAGO
  // ==========================================================

  TextColumn get metodoPago =>
      text()();

  // ==========================================================
  // ESTADO
  // ==========================================================

  /// pendiente
  /// generado
  /// enviado
  /// aceptado
  /// rechazado
  /// dadoDeBaja
  /// anulado
  TextColumn get estado =>
      text().withDefault(
        const Constant('pendiente'),
      )();

  // ==========================================================
  // RESPUESTA SUNAT
  // ==========================================================

  TextColumn get codigoRespuestaSunat =>
      text().nullable()();

  TextColumn get mensajeRespuestaSunat =>
      text().nullable()();

  // ==========================================================
  // CDR
  // ==========================================================

  TextColumn get cdr =>
      text().nullable()();

  // ==========================================================
  // XML
  // ==========================================================

  TextColumn get xml =>
      text().nullable()();

  // ==========================================================
  // FECHAS DE COMUNICACIÓN CON SUNAT
  // ==========================================================

  DateTimeColumn get fechaEnvioSunat =>
      dateTime().nullable()();

  DateTimeColumn get fechaRespuestaSunat =>
      dateTime().nullable()();

  // ==========================================================
  // NOTA DE CRÉDITO
  // ==========================================================

  /// Código de motivo SUNAT.
  TextColumn get codigoMotivoNotaCredito =>
      text().nullable()();

  /// Descripción del motivo.
  TextColumn get motivoNotaCredito =>
      text().nullable()();

  // ==========================================================
  // OBSERVACIONES
  // ==========================================================

  TextColumn get observaciones =>
      text().nullable()();
}
