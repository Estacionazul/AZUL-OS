import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../models/comprobante_electronico.dart';
import '../repositories/comprobantes_electronicos_repository.dart';
import '../xml/comprobante_xml_service.dart';

class FacturacionService {
  final ComprobantesElectronicosRepository
  comprobantesElectronicosRepository;

  FacturacionService({
    required this.comprobantesElectronicosRepository,
  });

  // ==========================================================
  // CREAR COMPROBANTE ELECTRÓNICO
  // ==========================================================

  Future<int> crearComprobante({
    required int ventaId,
    required TipoComprobanteElectronico tipo,
    required String serie,
    required DateTime fechaEmision,
    String? dni,
    String? ruc,
    String? nombreCliente,
    String? direccionFiscal,
    required double subtotal,
    required double igv,
    required double total,
    required String metodoPago,
  }) async {
    // ----------------------------------------------------------
    // OBTENER SIGUIENTE CORRELATIVO
    // ----------------------------------------------------------

    final numero =
    await comprobantesElectronicosRepository
        .obtenerSiguienteNumero(serie);

    // ----------------------------------------------------------
    // CREAR REGISTRO EN BASE DE DATOS
    // ----------------------------------------------------------

    final comprobante =
    ComprobantesElectronicosCompanion.insert(
      ventaId: Value(ventaId),
      tipo: tipo.name,
      serie: serie,
      numero: numero,
      fechaEmision: fechaEmision,
      dni: Value(dni),
      ruc: Value(ruc),
      nombreCliente: Value(nombreCliente),
      direccionFiscal: Value(direccionFiscal),
      subtotal: subtotal,
      igv: igv,
      total: total,
      metodoPago: metodoPago,
      estado: const Value('pendiente'),
    );

    return comprobantesElectronicosRepository
        .crearComprobante(comprobante);
  }

  // ==========================================================
  // OBTENER COMPROBANTE POR ID
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorId(
      int id,
      ) {
    return comprobantesElectronicosRepository
        .obtenerPorId(id);
  }

  // ==========================================================
  // ACTUALIZAR ESTADO
  // ==========================================================

  Future<bool> actualizarEstado({
    required int id,
    required String estado,
  }) {
    return comprobantesElectronicosRepository
        .actualizarEstado(
      id,
      estado,
    );
  }

  // ==========================================================
  // GUARDAR RESPUESTA DE SUNAT
  // ==========================================================

  Future<bool> guardarRespuestaSunat({
    required int id,
    String? codigoRespuestaSunat,
    String? mensajeRespuestaSunat,
    String? cdr,
    String? xml,
    DateTime? fechaEnvioSunat,
    DateTime? fechaRespuestaSunat,
    String? estado,
  }) {
    return comprobantesElectronicosRepository
        .actualizarRespuestaSunat(
      id: id,
      codigoRespuestaSunat: codigoRespuestaSunat,
      mensajeRespuestaSunat: mensajeRespuestaSunat,
      cdr: cdr,
      xml: xml,
      fechaEnvioSunat: fechaEnvioSunat,
      fechaRespuestaSunat: fechaRespuestaSunat,
      estado: estado,
    );
  }

  // ==========================================================
  // CONVERTIR REGISTRO DE BASE DE DATOS A MODELO
  // ==========================================================

  ComprobanteElectronico _convertirAModelo(
      ComprobantesElectronico comprobante,
      ) {
    final tipo = TipoComprobanteElectronico.values.firstWhere(
          (e) => e.name == comprobante.tipo,
      orElse: () => TipoComprobanteElectronico.notaVenta,
    );

    final estado =
    EstadoComprobanteElectronico.values.firstWhere(
          (e) => e.name == comprobante.estado,
      orElse: () =>
      EstadoComprobanteElectronico.pendiente,
    );

    return ComprobanteElectronico(
      id: comprobante.id,
      ventaId: comprobante.ventaId,
      tipo: tipo,
      serie: comprobante.serie,
      numero: comprobante.numero,
      fechaEmision: comprobante.fechaEmision,
      dni: comprobante.dni,
      ruc: comprobante.ruc,
      nombreCliente: comprobante.nombreCliente,
      direccionFiscal: comprobante.direccionFiscal,
      subtotal: comprobante.subtotal,
      igv: comprobante.igv,
      total: comprobante.total,
      metodoPago: comprobante.metodoPago,
      estado: estado,
      codigoRespuestaSunat:
      comprobante.codigoRespuestaSunat,
      mensajeRespuestaSunat:
      comprobante.mensajeRespuestaSunat,
      cdr: comprobante.cdr,
      xml: comprobante.xml,
      fechaEnvioSunat:
      comprobante.fechaEnvioSunat,
      fechaRespuestaSunat:
      comprobante.fechaRespuestaSunat,
      comprobanteRelacionadoId:
      comprobante.comprobanteRelacionadoId,
      codigoMotivoNotaCredito:
      comprobante.codigoMotivoNotaCredito,
      motivoNotaCredito:
      comprobante.motivoNotaCredito,
      observaciones:
      comprobante.observaciones,
    );
  }

  // ==========================================================
  // GENERAR Y GUARDAR XML DEL COMPROBANTE
  // ==========================================================

  Future<String> generarXmlComprobante({
    required int comprobanteId,
    required String rucEmisor,
    required String razonSocialEmisor,
    String? nombreComercial,
    String? direccionEmisor,
    String moneda = 'PEN',
    List<dynamic> detalles = const [],
  }) async {
    // ----------------------------------------------------------
    // OBTENER COMPROBANTE DE LA BASE DE DATOS
    // ----------------------------------------------------------

    final comprobanteDb =
    await comprobantesElectronicosRepository
        .obtenerPorId(comprobanteId);

    if (comprobanteDb == null) {
      throw StateError(
        'No se encontró el comprobante electrónico '
            'con ID $comprobanteId.',
      );
    }

    // ----------------------------------------------------------
    // CONVERTIR A MODELO DE NEGOCIO
    // ----------------------------------------------------------

    final comprobante =
    _convertirAModelo(comprobanteDb);

    // ----------------------------------------------------------
    // GENERAR XML
    // ----------------------------------------------------------

    final xml = ComprobanteXmlService.generar(
      comprobante: comprobante,
      rucEmisor: rucEmisor,
      razonSocialEmisor: razonSocialEmisor,
      nombreComercial: nombreComercial,
      direccionEmisor: direccionEmisor,
      moneda: moneda,
      detalles: detalles,
    );

    // ----------------------------------------------------------
    // GUARDAR XML EN LA BASE DE DATOS
    // ----------------------------------------------------------

    final actualizado =
    await comprobantesElectronicosRepository.actualizarXml(
      comprobanteId,
      xml,
    );

    if (!actualizado) {
      throw StateError(
        'No se pudo guardar el XML del comprobante '
            'con ID $comprobanteId.',
      );
    }

    return xml;
  }
}