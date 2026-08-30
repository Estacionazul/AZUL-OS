import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/respuesta_sunat.dart';

class SunatService {
  // ==========================================================
  // ENDPOINTS SUNAT
  // ==========================================================

  static const String endpointBeta =
      'https://e-beta.sunat.gob.pe/ol-ti-itcpfegem-beta/billService';

  static const String endpointProduccion =
      'https://e-factura.sunat.gob.pe/ol-ti-itcpfegem/billService';

  // ==========================================================
  // CONFIGURACIÓN
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

  String get endpoint =>
      produccion ? endpointProduccion : endpointBeta;

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
    print('🚀 ENVÍO DE COMPROBANTE A SUNAT');
    print('==================================================');

    // --------------------------------------------------------
    // 1. VALIDAR XML
    // --------------------------------------------------------

    if (xmlFirmado.trim().isEmpty) {
      throw StateError(
        'No se puede enviar un XML vacío a SUNAT.',
      );
    }

    if (!xmlFirmado.contains('<ds:Signature')) {
      throw StateError(
        'El XML no contiene una firma digital ds:Signature.',
      );
    }

    if (!xmlFirmado.contains('<ds:SignatureValue>')) {
      throw StateError(
        'El XML no contiene ds:SignatureValue.',
      );
    }

    if (!xmlFirmado.contains('<ds:X509Certificate>')) {
      throw StateError(
        'El XML no contiene ds:X509Certificate.',
      );
    }

    // --------------------------------------------------------
    // 2. NOMBRE DEL DOCUMENTO
    // --------------------------------------------------------

    final nombreBase =
        '$ruc-$tipoComprobante-$serie-$numero';

    final nombreXml =
        '$nombreBase.xml';

    final nombreZip =
        '$nombreBase.zip';

    print('📄 XML: $nombreXml');
    print('📦 ZIP: $nombreZip');

    // --------------------------------------------------------
    // 3. XML → BYTES
    // --------------------------------------------------------

    final xmlBytes =
    utf8.encode(xmlFirmado);

    // --------------------------------------------------------
    // 4. CREAR ZIP
    // --------------------------------------------------------

    final zipBytes =
    _crearZip(
      nombreXml,
      xmlBytes,
    );

    print(
      '📦 ZIP generado: ${zipBytes.length} bytes',
    );

    // --------------------------------------------------------
    // 5. ENVIAR A SUNAT
    // --------------------------------------------------------

    final respuestaHttp =
    await _enviarSoap(
      nombreZip: nombreZip,
      zipBytes: zipBytes,
    );

    print(
      '📡 HTTP SUNAT: ${respuestaHttp.statusCode}',
    );

    // --------------------------------------------------------
    // 6. PROCESAR RESPUESTA
    // --------------------------------------------------------

    final respuesta =
    _procesarRespuesta(
      respuestaHttp,
    );

    final fechaFin = DateTime.now();

    print('');
    print('==================================================');
    print('📨 RESPUESTA SUNAT');
    print('==================================================');

    print(
      '⏱ Tiempo: '
          '${fechaFin.difference(fechaInicio).inMilliseconds} ms',
    );

    print(
      'Estado: '
          '${respuesta.aceptado ? 'ACEPTADO' : 'RECHAZADO'}',
    );

    print(
      'Código: ${respuesta.codigo ?? '-'}',
    );

    print(
      'Mensaje: ${respuesta.mensaje ?? '-'}',
    );

    print('==================================================');

    return respuesta;
  }

  // ==========================================================
  // CREAR ZIP
  // ==========================================================

  Uint8List _crearZip(
      String nombreXml,
      List<int> xmlBytes,
      ) {
    final archive = Archive();

    archive.addFile(
      ArchiveFile(
        nombreXml,
        xmlBytes.length,
        xmlBytes,
      ),
    );

    final encoder = ZipEncoder();

    final encoded = encoder.encode(archive);

    if (encoded.isEmpty) {
      throw StateError(
        'No se pudo generar el archivo ZIP.',
      );
    }

    return Uint8List.fromList(encoded);
  }

  // ==========================================================
  // SOAP
  // ==========================================================

  Future<_RespuestaHttp> _enviarSoap({
    required String nombreZip,
    required Uint8List zipBytes,
  }) async {
    final client =
    HttpClient();

    try {
      final uri =
      Uri.parse(endpoint);

      print('');
      print('🌐 Endpoint SUNAT:');
      print(endpoint);

      final request =
      await client.postUrl(uri);

      // ------------------------------------------------------
      // CONTENT-ID DEL ARCHIVO ZIP
      // ------------------------------------------------------

      final contentId =
          '<$nombreZip>';

      // ------------------------------------------------------
      // SOAP
      // ------------------------------------------------------

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
      <fileName>$nombreZip</fileName>
      <contentFile>cid:$contentId</contentFile>
    </ser:sendBill>
  </soapenv:Body>

</soapenv:Envelope>
''';

      // ------------------------------------------------------
      // MULTIPART/RELATED
      // ------------------------------------------------------

      final boundary =
          '----=_Part_${DateTime.now().microsecondsSinceEpoch}';

      final soapContentId =
          '<rootpart@azulos>';

      final buffer =
      BytesBuilder();

      // ------------------------------------------------------
      // PARTE SOAP
      // ------------------------------------------------------

      buffer.add(
        utf8.encode(
          '--$boundary\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-Type: application/xop+xml; '
              'charset=UTF-8; type="text/xml"\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-ID: $soapContentId\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          '\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          soapEnvelope,
        ),
      );

      buffer.add(
        utf8.encode(
          '\r\n',
        ),
      );

      // ------------------------------------------------------
      // PARTE ZIP
      // ------------------------------------------------------

      buffer.add(
        utf8.encode(
          '--$boundary\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-Type: application/zip\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-Transfer-Encoding: binary\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-ID: $contentId\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          'Content-Disposition: attachment; '
              'filename="$nombreZip"\r\n',
        ),
      );

      buffer.add(
        utf8.encode(
          '\r\n',
        ),
      );

      buffer.add(
        zipBytes,
      );

      buffer.add(
        utf8.encode(
          '\r\n',
        ),
      );

      // ------------------------------------------------------
      // FIN MULTIPART
      // ------------------------------------------------------

      buffer.add(
        utf8.encode(
          '--$boundary--\r\n',
        ),
      );

      final body =
      buffer.takeBytes();

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/related; '
            'type="application/xop+xml"; '
            'start="$soapContentId"; '
            'start-info="text/xml"; '
            'boundary="$boundary"',
      );

      request.headers.set(
        HttpHeaders.acceptHeader,
        'text/xml',
      );

      request.headers.set(
        'SOAPAction',
        'urn:sendBill',
      );

      request.contentLength =
          body.length;

      request.add(body);

      print('📤 Enviando ZIP a SUNAT...');

      final response =
      await request.close();

      final responseBytes =
      await response.fold<List<int>>(
        <int>[],
            (
            previous,
            element,
            ) =>
        previous..addAll(element),
      );

      print(
        '📥 Respuesta recibida: '
            '${responseBytes.length} bytes',
      );

      return _RespuestaHttp(
        statusCode: response.statusCode,
        headers: response.headers,
        body: Uint8List.fromList(
          responseBytes,
        ),
      );
    } finally {
      client.close(
        force: true,
      );
    }
  }

  // ==========================================================
  // PROCESAR RESPUESTA SUNAT
  // ==========================================================

  RespuestaSunat _procesarRespuesta(
      _RespuestaHttp respuestaHttp,
      ) {
    if (respuestaHttp.statusCode < 200 ||
        respuestaHttp.statusCode >= 300) {
      final texto =
      utf8.decode(
        respuestaHttp.body,
        allowMalformed: true,
      );

      return RespuestaSunat.rechazada(
        codigo:
        'HTTP-${respuestaHttp.statusCode}',
        mensaje:
        _extraerMensajeSoap(texto) ??
            'SUNAT respondió HTTP '
                '${respuestaHttp.statusCode}.',
        xmlRespuesta: texto,
      );
    }

    final contentType =
        respuestaHttp.headers.contentType
            ?.toString()
            .toLowerCase() ??
            '';

    // --------------------------------------------------------
    // RESPUESTA MULTIPART
    // --------------------------------------------------------

    if (contentType.contains(
      'multipart/',
    )) {
      return _procesarRespuestaMultipart(
        respuestaHttp.body,
        contentType,
      );
    }

    // --------------------------------------------------------
    // RESPUESTA XML NORMAL
    // --------------------------------------------------------

    final texto =
    utf8.decode(
      respuestaHttp.body,
      allowMalformed: true,
    );

    final contenido =
    _extraerApplicationResponse(
      texto,
    );

    if (contenido != null) {
      try {
        final cdrZip =
        base64.decode(
          contenido,
        );

        return _procesarCdrZip(
          cdrZip,
          xmlRespuesta: texto,
        );
      } catch (_) {
        // Continúa con el procesamiento como XML.
      }
    }

    return _procesarRespuestaXml(
      texto,
    );
  }

  // ==========================================================
  // RESPUESTA MULTIPART
  // ==========================================================

  RespuestaSunat _procesarRespuestaMultipart(
      Uint8List body,
      String contentType,
      ) {
    final texto =
    utf8.decode(
      body,
      allowMalformed: true,
    );

    final applicationResponse =
    _extraerApplicationResponse(
      texto,
    );

    if (applicationResponse != null) {
      try {
        final bytes =
        base64.decode(
          applicationResponse,
        );

        return _procesarCdrZip(
          bytes,
          xmlRespuesta: texto,
        );
      } catch (_) {}
    }

    return _procesarRespuestaXml(
      texto,
    );
  }

  // ==========================================================
  // PROCESAR CDR ZIP
  // ==========================================================

  RespuestaSunat _procesarCdrZip(
      List<int> zipBytes, {
        String? xmlRespuesta,
      }) {
    try {
      final archive =
      ZipDecoder().decodeBytes(
        zipBytes,
      );

      ArchiveFile? cdrFile;

      for (final file in archive.files) {
        if (!file.isFile) {
          continue;
        }

        final nombre =
        file.name.toLowerCase();

        if (nombre.endsWith('.xml')) {
          cdrFile = file;
          break;
        }
      }

      if (cdrFile == null) {
        return RespuestaSunat.rechazada(
          codigo: 'CDR_SIN_XML',
          mensaje:
          'SUNAT respondió un ZIP, '
              'pero no contiene un XML de CDR.',
          xmlRespuesta: xmlRespuesta,
        );
      }

      final cdrBytes =
          cdrFile.content;

      final cdrXml =
      utf8.decode(
        cdrBytes,
        allowMalformed: true,
      );

      return _procesarCdrXml(
        cdrXml,
        xmlRespuesta: xmlRespuesta,
      );
    } catch (e) {
      return RespuestaSunat.rechazada(
        codigo: 'CDR_ERROR',
        mensaje:
        'No se pudo interpretar el CDR: $e',
        xmlRespuesta: xmlRespuesta,
      );
    }
  }

  // ==========================================================
  // PROCESAR XML DEL CDR
  // ==========================================================

  RespuestaSunat _procesarCdrXml(
      String cdrXml, {
        String? xmlRespuesta,
      }) {
    final responseCode =
    _extraerTag(
      cdrXml,
      'ResponseCode',
    );

    final description =
    _extraerTag(
      cdrXml,
      'Description',
    );

    final codigo =
    responseCode?.trim();

    final mensaje =
    description?.trim();

    // SUNAT utiliza 0 como código de aceptación.
    final aceptado =
        codigo == '0';

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

  RespuestaSunat _procesarRespuestaXml(
      String xml,
      ) {
    final fault =
    _extraerTag(
      xml,
      'faultstring',
    );

    if (fault != null &&
        fault.trim().isNotEmpty) {
      return RespuestaSunat.rechazada(
        codigo: 'SOAP_FAULT',
        mensaje: fault.trim(),
        xmlRespuesta: xml,
      );
    }

    final codigo =
    _extraerTag(
      xml,
      'statusCode',
    );

    final mensaje =
    _extraerTag(
      xml,
      'statusMessage',
    );

    if (codigo != null) {
      final aceptado =
          codigo.trim() == '0';

      return aceptado
          ? RespuestaSunat.aceptada(
        codigo: codigo.trim(),
        mensaje:
        mensaje?.trim(),
        xmlRespuesta: xml,
      )
          : RespuestaSunat.rechazada(
        codigo: codigo.trim(),
        mensaje:
        mensaje?.trim(),
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

  String? _extraerApplicationResponse(
      String xml,
      ) {
    final value =
    _extraerTag(
      xml,
      'applicationResponse',
    );

    if (value == null) {
      return null;
    }

    final limpio =
    value
        .replaceAll(
      RegExp(r'\s+'),
      '',
    )
        .trim();

    if (limpio.isEmpty) {
      return null;
    }

    return limpio;
  }

  // ==========================================================
  // EXTRAER MENSAJE SOAP
  // ==========================================================

  String? _extraerMensajeSoap(
      String xml,
      ) {
    return _extraerTag(
      xml,
      'faultstring',
    ) ??
        _extraerTag(
          xml,
          'Description',
        ) ??
        _extraerTag(
          xml,
          'description',
        );
  }

  // ==========================================================
  // EXTRAER TAG XML SIMPLE
  // ==========================================================

  String? _extraerTag(
      String xml,
      String tag,
      ) {
    final expresion =
    RegExp(
      '<(?:[A-Za-z0-9_\\-]+:)?$tag'
      r'(?:\s[^>]*)?>'
      r'([\s\S]*?)'
      '<\\/(?:[A-Za-z0-9_\\-]+:)?$tag>',
      caseSensitive: false,
    );

    final match =
    expresion.firstMatch(xml);

    if (match == null) {
      return null;
    }

    return _decodeXml(
      match.group(1)?.trim() ?? '',
    );
  }

  // ==========================================================
  // ESCAPAR XML
  // ==========================================================

  String _escapeXml(
      String value,
      ) {
    return value
        .replaceAll(
      '&',
      '&amp;',
    )
        .replaceAll(
      '<',
      '&lt;',
    )
        .replaceAll(
      '>',
      '&gt;',
    )
        .replaceAll(
      '"',
      '&quot;',
    )
        .replaceAll(
      "'",
      '&apos;',
    );
  }

  // ==========================================================
  // DECODIFICAR XML
  // ==========================================================

  String _decodeXml(
      String value,
      ) {
    return value
        .replaceAll(
      '&lt;',
      '<',
    )
        .replaceAll(
      '&gt;',
      '>',
    )
        .replaceAll(
      '&quot;',
      '"',
    )
        .replaceAll(
      '&apos;',
      "'",
    )
        .replaceAll(
      '&amp;',
      '&',
    );
  }

  // ==========================================================
  // USUARIO SUNAT
  // ==========================================================

  String get _usuarioSunat {
    if (usuarioSol.trim().isEmpty) {
      return '$ruc' 'MODDATOS';
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
