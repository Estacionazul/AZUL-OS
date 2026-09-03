import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/comprobantes_electronicos_table.dart';

part 'comprobantes_electronicos_dao.g.dart';

@DriftAccessor(tables: [ComprobantesElectronicos])
class ComprobantesElectronicosDao extends DatabaseAccessor<AppDatabase>
    with _$ComprobantesElectronicosDaoMixin {
  ComprobantesElectronicosDao(AppDatabase db) : super(db);

  // ==========================================================
  // CREAR COMPROBANTE
  // ==========================================================

  Future<int> crearComprobante(ComprobantesElectronicosCompanion comprobante) {
    return into(comprobantesElectronicos).insert(comprobante);
  }

  // ==========================================================
  // OBTENER POR ID
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorId(int id) {
    return (select(
      comprobantesElectronicos,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // ==========================================================
  // OBTENER POR VENTA
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorVenta(int ventaId) {
    return (select(comprobantesElectronicos)
          ..where((c) => c.ventaId.equals(ventaId))
          ..orderBy([
            (c) => OrderingTerm(
              expression: c.fechaEmision,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // ==========================================================
  // OBTENER TODOS
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerTodos() {
    return (select(comprobantesElectronicos)..orderBy([
          (c) =>
              OrderingTerm(expression: c.fechaEmision, mode: OrderingMode.desc),
        ]))
        .get();
  }

  // ==========================================================
  // OBTENER POR TIPO
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorTipo(String tipo) {
    return (select(comprobantesElectronicos)
          ..where((c) => c.tipo.equals(tipo))
          ..orderBy([
            (c) => OrderingTerm(
              expression: c.fechaEmision,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // ==========================================================
  // OBTENER POR SERIE
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorSerie(String serie) {
    return (select(comprobantesElectronicos)
          ..where((c) => c.serie.equals(serie))
          ..orderBy([
            (c) => OrderingTerm(expression: c.numero, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // ==========================================================
  // OBTENER ÚLTIMO CORRELATIVO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerUltimoPorSerie(String serie) {
    return (select(comprobantesElectronicos)
          ..where((c) => c.serie.equals(serie))
          ..orderBy([
            (c) => OrderingTerm(expression: c.numero, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ==========================================================
  // SIGUIENTE CORRELATIVO
  // ==========================================================

  Future<int> obtenerSiguienteNumero(String serie) async {
    final ultimo = await obtenerUltimoPorSerie(serie);

    if (ultimo == null) {
      return 1;
    }

    return ultimo.numero + 1;
  }

  // ==========================================================
  // ACTUALIZAR ESTADO
  // ==========================================================

  Future<bool> actualizarEstado(int id, String estado) async {
    final cantidad =
        await (update(comprobantesElectronicos)..where((c) => c.id.equals(id)))
            .write(ComprobantesElectronicosCompanion(estado: Value(estado)));

    return cantidad > 0;
  }

  // ==========================================================
  // ACTUALIZAR RESPUESTA SUNAT
  // ==========================================================

  Future<bool> actualizarRespuestaSunat({
    required int id,
    String? codigoRespuestaSunat,
    String? mensajeRespuestaSunat,
    String? cdr,
    String? xml,
    DateTime? fechaEnvioSunat,
    DateTime? fechaRespuestaSunat,
    String? estado,
  }) async {
    final cantidad =
        await (update(
          comprobantesElectronicos,
        )..where((c) => c.id.equals(id))).write(
          ComprobantesElectronicosCompanion(
            codigoRespuestaSunat: Value(codigoRespuestaSunat),
            mensajeRespuestaSunat: Value(mensajeRespuestaSunat),
            cdr: Value(cdr),
            xml: Value(xml),
            fechaEnvioSunat: Value(fechaEnvioSunat),
            fechaRespuestaSunat: Value(fechaRespuestaSunat),
            estado: estado != null ? Value(estado) : const Value.absent(),
          ),
        );

    return cantidad > 0;
  }

  // ==========================================================
  // ACTUALIZAR XML
  // ==========================================================

  Future<bool> actualizarXml(int id, String xml) async {
    final cantidad =
        await (update(comprobantesElectronicos)..where((c) => c.id.equals(id)))
            .write(ComprobantesElectronicosCompanion(xml: Value(xml)));

    return cantidad > 0;
  }

  // ==========================================================
  // ACTUALIZAR CDR
  // ==========================================================

  Future<bool> actualizarCdr(int id, String cdr) async {
    final cantidad =
        await (update(comprobantesElectronicos)..where((c) => c.id.equals(id)))
            .write(ComprobantesElectronicosCompanion(cdr: Value(cdr)));

    return cantidad > 0;
  }

  // ==========================================================
  // OBTENER COMPROBANTE RELACIONADO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerRelacionado(
    int comprobanteRelacionadoId,
  ) {
    return (select(
      comprobantesElectronicos,
    )..where((c) => c.id.equals(comprobanteRelacionadoId))).getSingleOrNull();
  }

  // ==========================================================
  // OBTENER NOTAS DE CRÉDITO DE UN COMPROBANTE
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerNotasCreditoRelacionadas(
    int comprobanteId,
  ) {
    return (select(comprobantesElectronicos)
          ..where(
            (c) =>
                c.comprobanteRelacionadoId.equals(comprobanteId) &
                c.tipo.equals('notaCredito'),
          )
          ..orderBy([
            (c) => OrderingTerm(
              expression: c.fechaEmision,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // ==========================================================
  // BUSCAR POR SERIE Y NÚMERO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorSerieNumero(
    String serie,
    int numero,
  ) {
    return (select(comprobantesElectronicos)
          ..where((c) => c.serie.equals(serie) & c.numero.equals(numero)))
        .getSingleOrNull();
  }

  // ==========================================================
  // ==========================================================
  // NO ELIMINAR COMPROBANTES ELECTRÓNICOS
  // ==========================================================
  //
  // Los comprobantes electrónicos se conservan para mantener
  // la trazabilidad frente a SUNAT.
  //
  // Las correcciones/anulaciones tributarias se manejarán
  // mediante los mecanismos correspondientes:
  // - Nota de crédito
  // - Comunicación de baja, cuando corresponda
  //
  // No se permite DELETE desde el módulo de facturación.
}
