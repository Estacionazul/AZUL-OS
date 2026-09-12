import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/respuesta_sunat.dart';
import '../models/respuesta_resumen_diario.dart';

class SunatService {
  static const Duration _timeoutRedSunat = Duration(seconds: 45);
  // ==========================================================
  // ENDPOINTS SUNAT
  // ==========================================================

  static const String endpointBeta =
      'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService';

  static const String endpointProduccion =
      'https://e-factura.sunat.gob.pe/ol-ti-itcpfegem/billService';

  // ==========================================================
  // CONFIGURACION
  // ==========================================================

  final String ruc;
  final String usuarioSol;
  final String claveSol;
  final bool produccion;

  SunatService({
    required this.ruc,
    required this.usuarioSol,
    required this.claveSol,
    this.produccion = false,
  });

  String get endpoint => produccion ? endpointProduccion : endpointBeta;

  // ==========================================================
  // ENVIAR COMPROBANTE
  // ==========================================================

  Future<RespuestaSunat> enviarComprobante({
    required String xmlFirmado,
    required String tipoComprobante,
    required String serie,
    required int numero,
  }) async {
    final fechaInicio = DateTime.now();

    print('');
    print('==================================================');
    print(' ENVIO DE COMPROBANTE A SUNAT');
    print('==================================================');

    // --------------------------------------------------------
    // 1. VALIDAR XML
    // --------------------------------------------------------

    if (xmlFirmado.trim().isEmpty) {
      throw StateError('No se puede enviar un XML vacio a SUNAT.');
    }

    if (!xmlFirmado.contains('<ds:Signature')) {
      throw StateError('El XML no contiene una firma digital ds:Signature.');
    }

    if (!xmlFirmado.contains('<ds:SignatureValue>')) {
      throw StateError('El XML no contiene ds:SignatureValue.');
    }

    if (!xmlFirmado.contains('<ds:X509Certificate>')) {
      throw StateError('El XML no contiene ds:X509Certificate.');
    }

    // --------------------------------------------------------
    // 2. NOMBRE DEL DOCUMENTO
    // --------------------------------------------------------

    final numeroFormateado = numero.toString().padLeft(8, '0');
    final nombreBase = '$ruc-$tipoComprobante-$serie-$numeroFormateado';

    final nombreXml = '$nombreBase.xml';

    final nombreZip = '$nombreBase.zip';

    print('[XML] XML: $nombreXml');
    print('[ZIP] ZIP: $nombreZip');

    // --------------------------------------------------------
    // 3. XML -> BYTES
    // --------------------------------------------------------

    final xmlBytes = utf8.encode(xmlFirmado);

    // ==========================================================
    // --------------------------------------------------------

    final zipBytes = _crearZip(nombreXml, xmlBytes);

    print(' ZIP generado: ${zipBytes.length} bytes');

    // --------------------------------------------------------
    // 5. ENVIAR A SUNAT
    // --------------------------------------------------------

    final respuestaHttp = await _enviarSoap(
      nombreZip: nombreZip,
      zipBytes: zipBytes,
    );

    print('[HTTP] HTTP SUNAT: ${respuestaHttp.statusCode}');

    // --------------------------------------------------------
    // 6. PROCESAR RESPUESTA
    // --------------------------------------------------------

    final respuesta = _procesarRespuesta(respuestaHttp);

    final fechaFin = DateTime.now();

    print('');
    print('==================================================');
    print('[RESPUESTA] RESPUESTA SUNAT');
    print('==================================================');

    print(
      ' Tiempo: '
      '${fechaFin.difference(fechaInicio).inMilliseconds} ms',
    );

    print(
      'Estado: '
      '${respuesta.aceptado ? 'ACEPTADO' : 'RECHAZADO'}',
    );

    print('Codigo: ${respuesta.codigo ?? '-'}');

    print('Mensaje: ${respuesta.mensaje ?? '-'}');

    print('==================================================');

    return respuesta;
  }


  // ==========================================================
  // ENVIAR RESUMEN DIARIO
  // ==========================================================

  Future<RespuestaResumenDiario> enviarResumenDiario({
    required String xmlFirmado,
    required String nombreXml,
    required String nombreZip,
  }) async {
    final fechaInicio = DateTime.now();

    print('');
    print('==================================================');
    print(' ENVIO DE RESUMEN DIARIO A SUNAT');
    print('==================================================');

    if (xmlFirmado.trim().isEmpty) {
      throw StateError(
        'No se puede enviar un Resumen Diario XML vacio a SUNAT.',
      );
    }

    if (!xmlFirmado.contains('<ds:Signature')) {
      throw StateError(
        'El Resumen Diario no contiene una firma digital ds:Signature.',
      );
    }

    if (!xmlFirmado.contains('<ds:SignatureValue>')) {
      throw StateError(
        'El Resumen Diario no contiene ds:SignatureValue.',
      );
    }

    if (!xmlFirmado.contains('<ds:X509Certificate>')) {
      throw StateError(
        'El Resumen Diario no contiene ds:X509Certificate.',
      );
    }

    final xmlBytes = utf8.encode(xmlFirmado);

    final zipBytes = _crearZip(nombreXml, xmlBytes);

    print('[XML] XML: $nombreXml');
    print('[ZIP] ZIP: $nombreZip');
    print(' ZIP generado: ${zipBytes.length} bytes');

    final respuestaHttp = await _enviarSummarySoap(
      nombreZip: nombreZip,
      zipBytes: zipBytes,
    );

    print('[HTTP] HTTP SUNAT: ${respuestaHttp.statusCode}');

    final respuesta = _procesarRespuestaResumen(
      respuestaHttp,
    );

    final fechaFin = DateTime.now();

    print('');
    print('==================================================');
    print('[RESPUESTA] RESPUESTA RESUMEN DIARIO');
    print('==================================================');
    print(
      ' Tiempo: '
      '${fechaFin.difference(fechaInicio).inMilliseconds} ms',
    );
    print('Ticket: ${respuesta.ticket ?? '-'}');
    print('Codigo: ${respuesta.codigo ?? '-'}');
    print('Mensaje: ${respuesta.mensaje ?? '-'}');
    print('==================================================');

    return respuesta;
  }
  // ==========================================================
  // CREAR ZIP
  // ==========================================================

  Uint8List _crearZip(String nombreXml, List<int> xmlBytes) {
    final archive = Archive();

    archive.addFile(ArchiveFile(nombreXml, xmlBytes.length, xmlBytes));

    final encoder = ZipEncoder();

    final encoded = encoder.encode(archive);

    if (encoded.isEmpty) {
      throw StateError('No se pudo generar el archivo ZIP.');
    }

    return Uint8List.fromList(encoded);
  }

  // ==========================================================
  // SOAP SEND SUMMARY
  // ==========================================================

  Future<_RespuestaHttp> _enviarSummarySoap({
    required String nombreZip,
    required Uint8List zipBytes,
  }) async {
    final client = HttpClient();

    try {
      final uri = Uri.parse(endpoint);

      final contentFileBase64 = base64Encode(zipBytes);

      final soapEnvelope = '''
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ser="http://service.sunat.gob.pe"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">

  <soapenv:Header>
    <wsse:Security>
      <wsse:UsernameToken>
        <wsse:Username>${_escapeXml(_usuarioSunat)}</wsse:Username>
        <wsse:Password>${_escapeXml(claveSol)}</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </soapenv:Header>

  <soapenv:Body>
    <ser:sendSummary>
      <fileName>${_escapeXml(nombreZip)}</fileName>
      <contentFile>$contentFileBase64</contentFile>
    </ser:sendSummary>
  </soapenv:Body>

</soapenv:Envelope>
''';

      final body = utf8.encode(soapEnvelope);

      final request = await client.postUrl(uri);

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'text/xml; charset=UTF-8',
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'text/xml',
      );

      request.headers.set(
        'SOAPAction',
        '"urn:sendSummary"',
      );

      request.headers.set(
        HttpHeaders.connectionHeader,
        'close',
      );

      request.contentLength = body.length;

      print('[ENVIO] Enviando sendSummary a SUNAT...');
      print(' SOAPAction: "urn:sendSummary"');

      request.add(body);

      final response = await request.close().timeout(_timeoutRedSunat);

      final responseBytes = await response.fold<List<int>>(
        <int>[],
            (previous, element) => previous..addAll(element),
      );

      return _RespuestaHttp(
        statusCode: response.statusCode,
        headers: response.headers,
        body: Uint8List.fromList(responseBytes),
      );
    } finally {
      client.close(force: true);
    }
  }

  // ==========================================================
  // SOAP
  // ==========================================================

  Future<_RespuestaHttp> _enviarSoap({
    required String nombreZip,
    required Uint8List zipBytes,
  }) async {
    final client = HttpClient();

    try {
      final uri = Uri.parse(endpoint);

      print('');
      print(' Endpoint SUNAT:');
      print(endpoint);

      // ==========================================================
      // ZIP -> BASE64
      // SUNAT define contentFile como base64Binary
      // ==========================================================

      final contentFileBase64 = base64Encode(zipBytes);

      print(' ZIP original: ${zipBytes.length} bytes');
      print(
        ' ZIP Base64: ${contentFileBase64.length} caracteres',
      );

      // ==========================================================
      // SOAP 1.1
      // ==========================================================

      final soapEnvelope = '''
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ser="http://service.sunat.gob.pe"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">

  <soapenv:Header>
    <wsse:Security>
      <wsse:UsernameToken>
        <wsse:Username>${_escapeXml(_usuarioSunat)}</wsse:Username>
        <wsse:Password>${_escapeXml(claveSol)}</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </soapenv:Header>

  <soapenv:Body>
    <ser:sendBill>
      <fileName>${_escapeXml(nombreZip)}</fileName>
      <contentFile>$contentFileBase64</contentFile>
    </ser:sendBill>
  </soapenv:Body>

</soapenv:Envelope>
''';

      final body = utf8.encode(soapEnvelope);

      // ==========================================================
      // PETICION HTTP
      // ==========================================================

      final request = await client.postUrl(uri);

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'text/xml; charset=UTF-8',
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'text/xml',
      );

      request.headers.set(
        'SOAPAction',
        '"urn:sendBill"',
      );

      request.headers.set(
        HttpHeaders.connectionHeader,
        'close',
      );

      request.contentLength = body.length;

      print('[SOAP] SOAP generado: ${body.length} bytes');
      print('[USUARIO] Usuario SUNAT: $_usuarioSunat');
      print('[ENVIO] Enviando sendBill a SUNAT...');
      print(' Content-Type: text/xml; charset=UTF-8');
      print(' SOAPAction: "urn:sendBill"');

      request.add(body);

      final response = await request.close().timeout(_timeoutRedSunat);

      final responseBytes = await response.fold<List<int>>(
        <int>[],
            (previous, element) => previous..addAll(element),
      );

      print(
        ' Respuesta recibida: '
            '${responseBytes.length} bytes',
      );

      print(
        ' HTTP SUNAT: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        print('===== RESPUESTA RAW SUNAT =====');

        try {
          print(utf8.decode(responseBytes));
        } catch (_) {
          print('No se pudo interpretar la respuesta como UTF-8.');
        }

        print('===== FIN RESPUESTA RAW SUNAT =====');
      }

      return _RespuestaHttp(
        statusCode: response.statusCode,
        headers: response.headers,
        body: Uint8List.fromList(responseBytes),
      );
    } finally {
      client.close(force: true);
    }
  }

  // ==========================================================
  // CONSULTAR ESTADO DE RESUMEN DIARIO
  // ==========================================================

  Future<RespuestaResumenDiario> getStatusResumenDiario({
    required String ticket,
  }) async {
    final ticketLimpio = ticket.trim();

    if (ticketLimpio.isEmpty) {
      return RespuestaResumenDiario.error(
        codigo: 'TICKET_VACIO',
        mensaje: 'No se puede consultar un ticket SUNAT vacio.',
      );
    }

    print('');
    print('==================================================');
    print('[SUNAT] CONSULTA DE ESTADO DEL RESUMEN DIARIO');
    print('==================================================');
    print('Ticket: $ticketLimpio');

    final respuestaHttp = await _enviarGetStatusSoap(
      ticket: ticketLimpio,
    );

    print('[HTTP] HTTP SUNAT: ${respuestaHttp.statusCode}');

    final respuesta = _procesarRespuestaGetStatus(
      respuestaHttp,
      ticket: ticketLimpio,
    );

    print('[SUNAT] Estado: ${respuesta.codigo ?? '-'}');
    print('[SUNAT] Mensaje: ${respuesta.mensaje ?? '-'}');

    return respuesta;
  }

  // ==========================================================
  // SOAP GET STATUS
  // ==========================================================

  Future<_RespuestaHttp> _enviarGetStatusSoap({
    required String ticket,
  }) async {
    final client = HttpClient();

    try {
      final uri = Uri.parse(endpoint);

      final soapEnvelope = '''
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ser="http://service.sunat.gob.pe"
    xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">

  <soapenv:Header>
    <wsse:Security>
      <wsse:UsernameToken>
        <wsse:Username>${_escapeXml(_usuarioSunat)}</wsse:Username>
        <wsse:Password>${_escapeXml(claveSol)}</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </soapenv:Header>

  <soapenv:Body>
    <ser:getStatus>
      <ticket>${_escapeXml(ticket)}</ticket>
    </ser:getStatus>
  </soapenv:Body>

</soapenv:Envelope>
''';

      final body = utf8.encode(soapEnvelope);

      final request = await client.postUrl(uri);

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'text/xml; charset=UTF-8',
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'text/xml',
      );

      request.headers.set(
        'SOAPAction',
        '"urn:getStatus"',
      );

      request.headers.set(
        HttpHeaders.connectionHeader,
        'close',
      );

      request.contentLength = body.length;

      print('[ENVIO] Enviando getStatus a SUNAT...');
      print(' SOAPAction: "urn:getStatus"');

      request.add(body);

      final response = await request.close().timeout(_timeoutRedSunat);

      final responseBytes = await response.fold<List<int>>(
        <int>[],
            (previous, element) => previous..addAll(element),
      );

      return _RespuestaHttp(
        statusCode: response.statusCode,
        headers: response.headers,
        body: Uint8List.fromList(responseBytes),
      );
    } finally {
      client.close(force: true);
    }
  }

  // ==========================================================
  // PROCESAR RESPUESTA GET STATUS
  // ==========================================================

  RespuestaResumenDiario _procesarRespuestaGetStatus(
      _RespuestaHttp respuestaHttp, {
        required String ticket,
      }) {
    final texto = utf8.decode(
      respuestaHttp.body,
      allowMalformed: true,
    );

    if (respuestaHttp.statusCode < 200 ||
        respuestaHttp.statusCode >= 300) {
      return RespuestaResumenDiario.error(
        codigo: 'HTTP-${respuestaHttp.statusCode}',
        mensaje:
        _extraerMensajeSoap(texto) ??
            'SUNAT respondio HTTP ${respuestaHttp.statusCode}.',
        xmlRespuesta: texto,
      );
    }

    final fault = _extraerTag(texto, 'faultstring');

    if (fault != null && fault.trim().isNotEmpty) {
      return RespuestaResumenDiario.error(
        codigo: 'SOAP_FAULT',
        mensaje: fault.trim(),
        xmlRespuesta: texto,
      );
    }

    final codigo = _extraerTag(texto, 'statusCode')?.trim();

    final mensaje =
        _extraerTag(texto, 'statusMessage') ??
            _extraerMensajeSoap(texto);

    if (codigo == '98') {
      return RespuestaResumenDiario(
        procesado: false,
        ticket: ticket,
        codigo: '98',
        mensaje:
        mensaje?.trim() ??
            'El Resumen Diario continua en proceso.',
        xmlRespuesta: texto,
      );
    }

    final contenido = _extraerTag(texto, 'content');

    if ((codigo == '0' || codigo == '99') &&
        contenido != null &&
        contenido.trim().isNotEmpty) {
      try {
        final cdrZip = base64.decode(
          contenido.replaceAll(RegExp(r'\s+'), ''),
        );

        final respuestaCdr = _procesarCdrZip(
          cdrZip,
          xmlRespuesta: texto,
        );

        return RespuestaResumenDiario.procesado(
          codigo: respuestaCdr.codigo ?? codigo,
          mensaje:
          respuestaCdr.mensaje ??
              mensaje?.trim(),
          cdr: respuestaCdr.cdr,
          xmlRespuesta: texto,
        );
      } catch (e) {
        return RespuestaResumenDiario.error(
          codigo: 'CDR_ERROR',
          mensaje:
          'No se pudo interpretar el CDR del Resumen Diario: $e',
          xmlRespuesta: texto,
        );
      }
    }

    if (codigo == '0') {
      return RespuestaResumenDiario.procesado(
        codigo: '0',
        mensaje:
        mensaje?.trim() ??
            'SUNAT proceso correctamente el Resumen Diario.',
        xmlRespuesta: texto,
      );
    }

    if (codigo == '99') {
      return RespuestaResumenDiario.error(
        codigo: '99',
        mensaje:
        mensaje?.trim() ??
            'SUNAT proceso el Resumen Diario con errores.',
        xmlRespuesta: texto,
      );
    }

    return RespuestaResumenDiario.error(
      codigo: codigo ?? 'RESPUESTA_NO_RECONOCIDA',
      mensaje:
      mensaje?.trim() ??
          'No se pudo interpretar la respuesta de getStatus.',
      xmlRespuesta: texto,
    );
  }

  // ==========================================================
  // PROCESAR RESPUESTA DE RESUMEN DIARIO
  // ==========================================================

  RespuestaResumenDiario _procesarRespuestaResumen(
      _RespuestaHttp respuestaHttp,
      ) {
    final texto = utf8.decode(
      respuestaHttp.body,
      allowMalformed: true,
    );

    if (respuestaHttp.statusCode < 200 ||
        respuestaHttp.statusCode >= 300) {
      return RespuestaResumenDiario.error(
        codigo: 'HTTP-${respuestaHttp.statusCode}',
        mensaje:
        _extraerMensajeSoap(texto) ??
            'SUNAT respondio HTTP ${respuestaHttp.statusCode}.',
        xmlRespuesta: texto,
      );
    }

    final fault = _extraerTag(texto, 'faultstring');

    if (fault != null && fault.trim().isNotEmpty) {
      return RespuestaResumenDiario.error(
        codigo: 'SOAP_FAULT',
        mensaje: fault.trim(),
        xmlRespuesta: texto,
      );
    }

    final ticket = _extraerTag(texto, 'ticket');

    if (ticket != null && ticket.trim().isNotEmpty) {
      return RespuestaResumenDiario.ticket(
        ticket: ticket.trim(),
        xmlRespuesta: texto,
      );
    }

    final codigo = _extraerTag(texto, 'statusCode');

    final mensaje =
        _extraerTag(texto, 'statusMessage') ??
            _extraerMensajeSoap(texto);

    return RespuestaResumenDiario.error(
      codigo: codigo?.trim() ?? 'RESPUESTA_NO_RECONOCIDA',
      mensaje: mensaje?.trim() ??
          'SUNAT no devolvi un ticket para el Resumen Diario.',
      xmlRespuesta: texto,
    );
  }

  // ==========================================================
  // PROCESAR RESPUESTA SUNAT
  // ==========================================================

  RespuestaSunat _procesarRespuesta(_RespuestaHttp respuestaHttp) {
    if (respuestaHttp.statusCode < 200 || respuestaHttp.statusCode >= 300) {
      final texto = utf8.decode(respuestaHttp.body, allowMalformed: true);

      print('===== RESPUESTA RAW SUNAT =====');
      print(texto);
      print('===== FIN RESPUESTA RAW SUNAT =====');

      return RespuestaSunat.rechazada(
        codigo: 'HTTP-${respuestaHttp.statusCode}',
        mensaje:
            _extraerMensajeSoap(texto) ??
            'SUNAT respondio HTTP '
                '${respuestaHttp.statusCode}.',
        xmlRespuesta: texto,
      );
    }

    final contentType =
        respuestaHttp.headers.contentType?.toString().toLowerCase() ?? '';

    // --------------------------------------------------------
    // RESPUESTA MULTIPART
    // --------------------------------------------------------

    if (contentType.contains('multipart/')) {
      return _procesarRespuestaMultipart(respuestaHttp.body, contentType);
    }

    // --------------------------------------------------------
    // RESPUESTA XML NORMAL
    // --------------------------------------------------------

    final texto = utf8.decode(respuestaHttp.body, allowMalformed: true);

    final contenido = _extraerApplicationResponse(texto);

    if (contenido != null) {
      try {
        final cdrZip = base64.decode(contenido);

        return _procesarCdrZip(cdrZip, xmlRespuesta: texto);
      } catch (_) {
        // Continua con el procesamiento como XML.
      }
    }

    return _procesarRespuestaXml(texto);
  }

  // ==========================================================
  // RESPUESTA MULTIPART
  // ==========================================================

  RespuestaSunat _procesarRespuestaMultipart(
    Uint8List body,
    String contentType,
  ) {
    final texto = utf8.decode(body, allowMalformed: true);

    final applicationResponse = _extraerApplicationResponse(texto);

    if (applicationResponse != null) {
      try {
        final bytes = base64.decode(applicationResponse);

        return _procesarCdrZip(bytes, xmlRespuesta: texto);
      } catch (_) {}
    }

    return _procesarRespuestaXml(texto);
  }

  // ==========================================================
  // PROCESAR CDR ZIP
  // ==========================================================

  RespuestaSunat _procesarCdrZip(List<int> zipBytes, {String? xmlRespuesta}) {
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);

      ArchiveFile? cdrFile;

      for (final file in archive.files) {
        if (!file.isFile) {
          continue;
        }

        final nombre = file.name.toLowerCase();

        if (nombre.endsWith('.xml')) {
          cdrFile = file;
          break;
        }
      }

      if (cdrFile == null) {
        return RespuestaSunat.rechazada(
          codigo: 'CDR_SIN_XML',
          mensaje:
              'SUNAT respondio un ZIP, '
              'pero no contiene un XML de CDR.',
          xmlRespuesta: xmlRespuesta,
        );
      }

      final cdrBytes = cdrFile.content;

      final cdrXml = utf8.decode(cdrBytes, allowMalformed: true);

      return _procesarCdrXml(cdrXml, xmlRespuesta: xmlRespuesta);
    } catch (e) {
      return RespuestaSunat.rechazada(
        codigo: 'CDR_ERROR',
        mensaje: 'No se pudo interpretar el CDR: $e',
        xmlRespuesta: xmlRespuesta,
      );
    }
  }

  // ==========================================================
  // PROCESAR XML DEL CDR
  // ==========================================================

  RespuestaSunat _procesarCdrXml(String cdrXml, {String? xmlRespuesta}) {
    final responseCode = _extraerTag(cdrXml, 'ResponseCode');

    final description = _extraerTag(cdrXml, 'Description');

    final codigo = responseCode?.trim();

    final mensaje = description?.trim();

    // SUNAT utiliza 0 como codigo de aceptacion.
    final aceptado = codigo == '0';

    if (aceptado) {
      return RespuestaSunat.aceptada(
        codigo: codigo,
        mensaje: mensaje,
        cdr: cdrXml,
        xmlRespuesta: xmlRespuesta,
      );
    }

    return RespuestaSunat.rechazada(
      codigo: codigo,
      mensaje: mensaje,
      cdr: cdrXml,
      xmlRespuesta: xmlRespuesta,
    );
  }

  // ==========================================================
  // RESPUESTA SOAP SIN ZIP
  // ==========================================================

  RespuestaSunat _procesarRespuestaXml(String xml) {
    final fault = _extraerTag(xml, 'faultstring');

    if (fault != null && fault.trim().isNotEmpty) {
      return RespuestaSunat.rechazada(
        codigo: 'SOAP_FAULT',
        mensaje: fault.trim(),
        xmlRespuesta: xml,
      );
    }

    final codigo = _extraerTag(xml, 'statusCode');

    final mensaje = _extraerTag(xml, 'statusMessage');

    if (codigo != null) {
      final aceptado = codigo.trim() == '0';

      return aceptado
          ? RespuestaSunat.aceptada(
              codigo: codigo.trim(),
              mensaje: mensaje?.trim(),
              xmlRespuesta: xml,
            )
          : RespuestaSunat.rechazada(
              codigo: codigo.trim(),
              mensaje: mensaje?.trim(),
              xmlRespuesta: xml,
            );
    }

    return RespuestaSunat.rechazada(
      codigo: 'RESPUESTA_NO_RECONOCIDA',
      mensaje:
          _extraerMensajeSoap(xml) ??
          'No se pudo interpretar '
              'la respuesta de SUNAT.',
      xmlRespuesta: xml,
    );
  }

  // ==========================================================
  // EXTRAER applicationResponse
  // ==========================================================

  String? _extraerApplicationResponse(String xml) {
    final value = _extraerTag(xml, 'applicationResponse');

    if (value == null) {
      return null;
    }

    final limpio = value.replaceAll(RegExp(r'\s+'), '').trim();

    if (limpio.isEmpty) {
      return null;
    }

    return limpio;
  }

  // ==========================================================
  // EXTRAER MENSAJE SOAP
  // ==========================================================

  String? _extraerMensajeSoap(String xml) {
    return _extraerTag(xml, 'faultstring') ??
        _extraerTag(xml, 'Description') ??
        _extraerTag(xml, 'description');
  }

  // ==========================================================
  // EXTRAER TAG XML SIMPLE
  // ==========================================================

  String? _extraerTag(String xml, String tag) {
    final expresion = RegExp(
      '<(?:[A-Za-z0-9_\\-]+:)?$tag'
      r'(?:\s[^>]*)?>'
      r'([\s\S]*?)'
      '<\\/(?:[A-Za-z0-9_\\-]+:)?$tag>',
      caseSensitive: false,
    );

    final match = expresion.firstMatch(xml);

    if (match == null) {
      return null;
    }

    return _decodeXml(match.group(1)?.trim() ?? '');
  }

  // ==========================================================
  // ESCAPAR XML
  // ==========================================================

  String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // ==========================================================
  // DECODIFICAR XML
  // ==========================================================

  String _decodeXml(String value) {
    return value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }

  // ==========================================================
  // USUARIO SUNAT
  // ==========================================================

  String get _usuarioSunat {
    if (usuarioSol.trim().isEmpty) {
      return '$ruc'
          'MODDATOS';
    }

    return usuarioSol;
  }
}

// ==========================================================
// RESPUESTA HTTP INTERNA
// ==========================================================

class _RespuestaHttp {
  final int statusCode;
  final HttpHeaders headers;
  final Uint8List body;

  const _RespuestaHttp({
    required this.statusCode,
    required this.headers,
    required this.body,
  });
}


