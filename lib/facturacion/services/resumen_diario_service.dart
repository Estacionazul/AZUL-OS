import '../../database/app_database.dart';
import '../repositories/comprobantes_electronicos_repository.dart';
import '../repositories/resumenes_diarios_repository.dart';
import '../xml/resumen_diario_linea.dart';
import '../xml/resumen_diario_xml_service.dart';
import '../firma/firma_digital_service.dart';
import '../sunat/sunat_service.dart';
import '../models/respuesta_resumen_diario.dart';

class ResumenDiarioService {
  final ComprobantesElectronicosRepository
  comprobantesElectronicosRepository;
  final ResumenesDiariosRepository resumenesDiariosRepository;
  final FirmaDigitalService firmaDigitalService;
  final SunatService sunatService;

  ResumenDiarioService({
    required this.comprobantesElectronicosRepository,
    required this.resumenesDiariosRepository,
    required this.firmaDigitalService,
    required this.sunatService,
  });

  Future<int> crearResumenPendiente({
    required DateTime fechaReferencia,
    required String rucEmisor,
  }) async {
    // ==========================================================
    // OBTENER BOLETAS PENDIENTES DEL DÍA
    // ==========================================================

    final boletas =
    await comprobantesElectronicosRepository.obtenerBoletasPorFecha(
      fechaReferencia,
    );

    final boletasPendientes = <ComprobantesElectronico>[];

    for (final comprobante in boletas) {
      if (comprobante.estado.trim().toLowerCase() != 'pendiente') {
        continue;
      }

      final detalles =
      await resumenesDiariosRepository.obtenerDetallesPorComprobante(
        comprobante.id,
      );

      var tieneResumenEnProceso = false;

      for (final detalle in detalles) {
        final resumenExistente =
        await resumenesDiariosRepository.obtenerPorId(
          detalle.resumenDiarioId,
        );

        if (resumenExistente == null) {
          continue;
        }

        final estadoResumen =
        resumenExistente.estado.trim().toLowerCase();

        if (estadoResumen == 'pendiente' ||
            estadoResumen == 'generado' ||
            estadoResumen == 'enviado') {
          tieneResumenEnProceso = true;
          break;
        }
      }

      if (!tieneResumenEnProceso) {
        boletasPendientes.add(comprobante);
      }
    }

    if (boletasPendientes.isEmpty) {
      throw StateError(
        'No existen boletas pendientes disponibles para incluir '
            'en el Resumen Diario de ${_formatearFecha(fechaReferencia)}.',
      );
    }

    // ==========================================================
    // OBTENER CORRELATIVO DEL RESUMEN
    // ==========================================================

    final ultimoCorrelativo =
    await resumenesDiariosRepository.obtenerUltimoCorrelativoPorFecha(
      fechaReferencia,
    );

    final correlativo = (ultimoCorrelativo ?? 0) + 1;

    // ==========================================================
    // GENERAR NOMBRE DEL ARCHIVO
    // ==========================================================

    final nombreArchivo = generarNombreArchivo(
      rucEmisor: rucEmisor,
      fechaReferencia: fechaReferencia,
      correlativo: correlativo,
    );

    // ==========================================================
    // CREAR CABECERA DEL RESUMEN
    // ==========================================================

    // ==========================================================
    // CREAR RESUMEN Y DETALLES EN UNA ÚNICA TRANSACCIÓN
    // ==========================================================

    final detalles = <ResumenesDiariosDetallesCompanion>[];

    for (var i = 0; i < boletasPendientes.length; i++) {
      final comprobante = boletasPendientes[i];

      detalles.add(
        ResumenesDiariosDetallesCompanion.insert(
          resumenDiarioId: 0,
          comprobanteElectronicoId: comprobante.id,
          lineId: i + 1,
        ),
      );
    }

    final resumenId =
    await resumenesDiariosRepository.crearConDetalles(
      resumen: ResumenesDiariosCompanion.insert(
        fechaReferencia: fechaReferencia,
        correlativo: correlativo,
        nombreArchivo: nombreArchivo,
      ),
      detalles: detalles,
    );

    return resumenId;
  }

  String generarIdResumen({
    required DateTime fechaReferencia,
    required int correlativo,
  }) {
    final fecha = _formatearFecha(fechaReferencia);

    return 'RC-$fecha-$correlativo';
  }

  String generarNombreArchivo({
    required String rucEmisor,
    required DateTime fechaReferencia,
    required int correlativo,
  }) {
    final idResumen = generarIdResumen(
      fechaReferencia: fechaReferencia,
      correlativo: correlativo,
    );

    return '$rucEmisor-$idResumen.XML';
  }

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio$mes$dia';
  }

  Future<String> generarXmlPendiente({
    required int resumenId,
    required String rucEmisor,
    required String razonSocialEmisor,
  }) async {
    final resumen =
    await resumenesDiariosRepository.obtenerPorId(resumenId);

    if (resumen == null) {
      throw StateError(
        'No existe el resumen diario con ID $resumenId.',
      );
    }

    // ==========================================================
    // OBTENER LAS BOLETAS ASOCIADAS A ESTE RESUMEN
    // ==========================================================

    final detalles =
    await resumenesDiariosRepository.obtenerDetallesPorResumenDiario(
      resumen.id,
    );

    if (detalles.isEmpty) {
      throw StateError(
        'El Resumen Diario ${resumen.id} no tiene comprobantes asociados.',
      );
    }

    final lineas = <ResumenDiarioLinea>[];

    for (final detalle in detalles) {
      final comprobante =
      await comprobantesElectronicosRepository.obtenerPorId(
        detalle.comprobanteElectronicoId,
      );

      if (comprobante == null) {
        throw StateError(
          'No existe el comprobante electrónico '
              '${detalle.comprobanteElectronicoId} asociado '
              'al Resumen Diario ${resumen.id}.',
        );
      }

      lineas.add(
        _convertirABoletaResumen(
          comprobante,
          lineId: detalle.lineId,
        ),
      );
    }

    final idResumen = generarIdResumen(
      fechaReferencia: resumen.fechaReferencia,
      correlativo: resumen.correlativo,
    );

    final xml = ResumenDiarioXmlService.generarResumen(
      idResumen: idResumen,
      fechaEmision: resumen.fechaReferencia,
      rucEmisor: rucEmisor,
      razonSocialEmisor: razonSocialEmisor,
      lineas: lineas,
    );

// ==========================================================
// FIRMAR XML DEL RESUMEN DIARIO
// ==========================================================

    final xmlFirmado = await firmaDigitalService.firmarXml(xml);

    if (!xmlFirmado.contains('<ds:Signature')) {
      throw StateError(
        'El Resumen Diario fue generado, '
            'pero no contiene una firma digital válida.',
      );
    }

    await resumenesDiariosRepository.actualizarXml(
      id: resumen.id,
      xml: xmlFirmado,
      nombreArchivo: resumen.nombreArchivo,
    );

    final estadoActualizado =
    await resumenesDiariosRepository.actualizarEstado(
      id: resumen.id,
      estado: 'generado',
    );

    if (!estadoActualizado) {
      throw StateError(
        'El XML firmado se guardó, pero no se pudo actualizar '
            'el estado del resumen ${resumen.id}.',
      );
    }

    return xmlFirmado;
  }

  // ==========================================================
  // OBTENER BOLETAS DEL DÍA Y CONVERTIRLAS A LÍNEAS
  // ==========================================================

  Future<List<ResumenDiarioLinea>> obtenerLineasPorFecha(
      DateTime fecha,
      ) async {
    final boletas =
    await comprobantesElectronicosRepository.obtenerBoletasPorFecha(
      fecha,
    );

    final lineas = <ResumenDiarioLinea>[];

    for (var i = 0; i < boletas.length; i++) {
      final comprobante = boletas[i];

      lineas.add(
        _convertirABoletaResumen(
          comprobante,
          lineId: i + 1,
        ),
      );
    }

    return lineas;
  }

  // ==========================================================
  // CONVERTIR BOLETA A LÍNEA DEL RESUMEN DIARIO
  // ==========================================================

  ResumenDiarioLinea _convertirABoletaResumen(
      ComprobantesElectronico comprobante, {
        required int lineId,
      }) {
    final dni = comprobante.dni?.trim();
    final ruc = comprobante.ruc?.trim();

    final numeroDocumentoAdquiriente =
    dni?.isNotEmpty == true
        ? dni!
        : ruc?.isNotEmpty == true
        ? ruc!
        : '-';

    final tipoDocumentoAdquiriente =
    dni?.isNotEmpty == true
        ? '1'
        : ruc?.isNotEmpty == true
        ? '6'
        : '-';

    return ResumenDiarioLinea(
      lineId: lineId,
      tipoComprobante: '03',
      serieNumero:
      '${comprobante.serie}-${comprobante.numero.toString().padLeft(8, '0')}',
      numeroDocumentoAdquiriente: numeroDocumentoAdquiriente,
      tipoDocumentoAdquiriente: tipoDocumentoAdquiriente,
      tipoAfectacion: '1',
      total: comprobante.total,
      valorVentaGravada: comprobante.subtotal,
      valorVentaExonerada: 0,
      valorVentaInafecta: 0,
      valorVentaGratuita: 0,
      igv: comprobante.igv,
      estado: _estadoResumen(comprobante),
      moneda: 'PEN',
    );
  }

  // ==========================================================
  // ESTADO PARA EL RESUMEN DIARIO
  // ==========================================================

  String _estadoResumen(ComprobantesElectronico comprobante) {
    final estado = comprobante.estado.toLowerCase();

    if (estado == 'anulado' || estado == 'dadodebaja') {
      return 'anulado';
    }

    return 'activo';
  }

  // ==========================================================
  // ENVIAR RESUMEN DIARIO A SUNAT
  // ==========================================================

  Future<RespuestaResumenDiario> enviarResumenPendiente({
    required int resumenId,
  }) async {
    final resumen =
    await resumenesDiariosRepository.obtenerPorId(resumenId);

    if (resumen == null) {
      throw StateError(
        'No existe el resumen diario con ID $resumenId.',
      );
    }

    final xmlFirmado = resumen.xml?.trim();

    if (xmlFirmado == null || xmlFirmado.isEmpty) {
      throw StateError(
        'El resumen ${resumen.id} no tiene XML generado.',
      );
    }

    if (!xmlFirmado.contains('<ds:Signature')) {
      throw StateError(
        'El XML del resumen ${resumen.id} no contiene una firma digital.',
      );
    }

    final nombreXml = resumen.nombreArchivo.trim();

    if (nombreXml.isEmpty) {
      throw StateError(
        'El resumen ${resumen.id} no tiene nombre de archivo.',
      );
    }

    final nombreZip = nombreXml.replaceFirst(
      RegExp(r'\.XML$', caseSensitive: false),
      '.ZIP',
    );

    final respuesta = await sunatService.enviarResumenDiario(
      xmlFirmado: xmlFirmado,
      nombreXml: nombreXml,
      nombreZip: nombreZip,
    );

    final ticket = respuesta.ticket?.trim();

    if (ticket != null && ticket.isNotEmpty) {
      final ticketGuardado =
      await resumenesDiariosRepository.actualizarTicket(
        resumen.id,
        ticket,
      );

      if (!ticketGuardado) {
        throw StateError(
          'SUNAT devolvió el ticket, pero no se pudo guardar '
              'el ticket del resumen ${resumen.id}.',
        );
      }
    }

    return respuesta;
  }

  // ==========================================================
  // CONSULTAR ESTADO DEL RESUMEN DIARIO EN SUNAT
  // ==========================================================

  Future<RespuestaResumenDiario> consultarEstadoResumen({
    required int resumenId,
  }) async {
    final resumen =
    await resumenesDiariosRepository.obtenerPorId(resumenId);

    if (resumen == null) {
      throw StateError(
        'No existe el resumen diario con ID $resumenId.',
      );
    }

    final ticket = resumen.ticketSunat?.trim();

    if (ticket == null || ticket.isEmpty) {
      throw StateError(
        'El resumen ${resumen.id} no tiene un ticket SUNAT.',
      );
    }

    final respuesta = await sunatService.getStatusResumenDiario(
      ticket: ticket,
    );

    if (!respuesta.procesado) {
      return respuesta;
    }

    final codigo = respuesta.codigo?.trim();

    if (codigo == null || codigo.isEmpty) {
      return respuesta;
    }

    final estado = codigo == '0' ? 'aceptado' : 'rechazado';

    final respuestaGuardada =
    await resumenesDiariosRepository.actualizarRespuestaSunat(
      id: resumen.id,
      estado: estado,
      codigo: respuesta.codigo,
      mensaje: respuesta.mensaje,
      cdr: respuesta.cdr,
    );

    if (!respuestaGuardada) {
      throw StateError(
        'SUNAT respondió el resumen ${resumen.id}, pero no se pudo '
            'guardar la respuesta en la base de datos.',
      );
    }

    // ==========================================================
    // ACTUALIZAR LOS COMPROBANTES INCLUIDOS EN EL RESUMEN
    // ==========================================================

    final detalles =
    await resumenesDiariosRepository.obtenerDetallesPorResumenDiario(
      resumen.id,
    );

    for (final detalle in detalles) {
      final comprobanteActualizado =
    await comprobantesElectronicosRepository.actualizarRespuestaSunat(
  id: detalle.comprobanteElectronicoId,
  codigoRespuestaSunat: respuesta.codigo,
  mensajeRespuestaSunat: respuesta.mensaje,
  cdr: respuesta.cdr,
  fechaRespuestaSunat: DateTime.now(),
);

      if (!comprobanteActualizado) {
        throw StateError(
          'El Resumen Diario ${resumen.id} fue procesado por SUNAT, '
              'pero no se pudo actualizar el comprobante '
              '${detalle.comprobanteElectronicoId}.',
        );
      }
    }

    return respuesta;
  }
}