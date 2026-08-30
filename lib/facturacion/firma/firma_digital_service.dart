import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pkcs12_parser/pkcs12_parser.dart';
import 'package:xml_crypto/xml_crypto.dart';

class FirmaDigitalService {
  final String rutaCertificado;
  final String passwordCertificado;

  FirmaDigitalService({
    required this.rutaCertificado,
    required this.passwordCertificado,
  });

  // ==========================================================
  // FIRMAR XML
  // ==========================================================

  Future<String> firmarXml(String xml) async {
    print('==================================================');
    print('🔐 INICIANDO FIRMA DIGITAL');
    print('==================================================');

    // ----------------------------------------------------------
    // 1. VERIFICAR CERTIFICADO
    // ----------------------------------------------------------

    final archivo = File(rutaCertificado);

    if (!await archivo.exists()) {
      throw StateError(
        'No se encontró el certificado digital:\n'
            '$rutaCertificado',
      );
    }

    print('✅ Certificado encontrado.');

    // ----------------------------------------------------------
    // 2. LEER CERTIFICADO
    // ----------------------------------------------------------

    final bytes = await archivo.readAsBytes();

    print('📦 Certificado leído.');
    print('📦 Tamaño: ${bytes.length} bytes');

    // ----------------------------------------------------------
    // 3. ABRIR PKCS#12
    // ----------------------------------------------------------

    late final dynamic pfx;

    try {
      pfx = Pkcs12.load(
        bytes,
        passwordCertificado,
      );
    } catch (e) {
      print('❌ ERROR AL ABRIR EL CERTIFICADO');
      print(e);
      rethrow;
    }

    print('✅ Certificado PKCS#12 abierto correctamente.');

    // ----------------------------------------------------------
    // 4. OBTENER CLAVE PRIVADA
    // ----------------------------------------------------------

    final String privateKeyPem =
    pfx.privateKeyPem.toString();

    if (privateKeyPem.trim().isEmpty) {
      throw StateError(
        'El certificado no contiene una clave privada.',
      );
    }

    print('🔑 Clave privada encontrada.');

    // ----------------------------------------------------------
    // 5. OBTENER CERTIFICADO X.509
    // ----------------------------------------------------------

    final String certificatePem =
    pfx.certificatePem.toString();

    if (certificatePem.trim().isEmpty) {
      throw StateError(
        'El certificado no contiene un certificado X.509.',
      );
    }

    print('📜 Certificado X.509 encontrado.');

    // ----------------------------------------------------------
    // 6. CERTIFICADO → BASE64
    // ----------------------------------------------------------

    final certificateBase64 =
    _certificadoPemABase64(
      certificatePem,
    );

    // ----------------------------------------------------------
    // 7. PREPARAR KEY INFO
    // ----------------------------------------------------------

    final keyInfoProvider =
    _SunatKeyInfoProvider(
      certificateBase64: certificateBase64,
      privateKeyPem: privateKeyPem,
    );

    // ----------------------------------------------------------
    // 8. CREAR FIRMA
    // ----------------------------------------------------------

    final signature = SignedXml();

    // SUNAT utiliza RSA-SHA1 en sus ejemplos XMLDSig.
    signature.signatureAlgorithm =
    'http://www.w3.org/2000/09/xmldsig#rsa-sha1';

    // SUNAT muestra canonicalización C14N con comentarios.
    signature.canonicalizationAlgorithm =
    'http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments';

    signature.signingKey =
        Uint8List.fromList(
          utf8.encode(privateKeyPem),
        );

    signature.keyInfoProvider =
        keyInfoProvider;

    // ----------------------------------------------------------
    // 9. REFERENCIA AL INVOICE
    // ----------------------------------------------------------

    signature.addReference(
      "//*[local-name()='Invoice']",
      [
        'http://www.w3.org/2000/09/xmldsig#enveloped-signature',
      ],
      'http://www.w3.org/2000/09/xmldsig#sha1',
    );

    // ----------------------------------------------------------
    // 10. GENERAR FIRMA DENTRO DE ExtensionContent
    // ----------------------------------------------------------

    signature.computeSignature(
      xml,
      opts: {
        'prefix': 'ds',
        'existingPrefixes': {
          'ds': 'http://www.w3.org/2000/09/xmldsig#',
        },
        'location': {
          'reference':
          "//*[local-name()='ExtensionContent']",
          'action': 'append',
        },
      },
    );

    final xmlFirmado =
        signature.signedXml;

    // ----------------------------------------------------------
    // 11. VALIDACIONES
    // ----------------------------------------------------------

    if (!xmlFirmado.contains(
      '<ds:Signature',
    )) {
      throw StateError(
        'No se encontró ds:Signature en el XML firmado.',
      );
    }

    if (!xmlFirmado.contains(
      '<ds:SignatureValue>',
    )) {
      throw StateError(
        'No se encontró ds:SignatureValue.',
      );
    }

    if (!xmlFirmado.contains(
      '<ds:X509Certificate>',
    )) {
      throw StateError(
        'No se encontró ds:X509Certificate.',
      );
    }

    // ----------------------------------------------------------
    // 12. MOSTRAR RESULTADO
    // ----------------------------------------------------------

    print('==================================================');
    print('✅ FIRMA DIGITAL GENERADA');
    print('==================================================');

    print('✅ ds:Signature encontrado.');
    print('✅ ds:SignatureValue generado.');
    print('✅ ds:X509Certificate incluido.');
    print('✅ Firma insertada en ExtensionContent.');
    print('==================================================');

    return xmlFirmado;
  }

  // ==========================================================
  // PEM → BASE64
  // ==========================================================

  String _certificadoPemABase64(
      String certificadoPem,
      ) {
    final limpio = certificadoPem
        .replaceAll(
      '-----BEGIN CERTIFICATE-----',
      '',
    )
        .replaceAll(
      '-----END CERTIFICATE-----',
      '',
    )
        .replaceAll(
      RegExp(r'\s+'),
      '',
    );

    if (limpio.isEmpty) {
      throw StateError(
        'El certificado X.509 está vacío.',
      );
    }

    try {
      base64.decode(limpio);
    } catch (e) {
      throw StateError(
        'El certificado X.509 no contiene '
            'Base64 válido.',
      );
    }

    return limpio;
  }
}

// ==========================================================
// KEY INFO PROVIDER
// ==========================================================

class _SunatKeyInfoProvider implements KeyInfoProvider {
  final String certificateBase64;
  final String privateKeyPem;

  _SunatKeyInfoProvider({
    required this.certificateBase64,
    required this.privateKeyPem,
  });

  @override
  Map<String, String> get attrs => {};

  @override
  String getKeyInfo(
      Uint8List? signingKey,
      String? prefix,
      ) {
    final p = prefix != null && prefix.isNotEmpty
        ? '$prefix:'
        : '';

    return '''
<${p}X509Data>
  <${p}X509Certificate>
    $certificateBase64
  </${p}X509Certificate>
</${p}X509Data>
''';
  }

  @override
  Uint8List? getKey(
      String? keyInfo,
      ) {
    return Uint8List.fromList(
      utf8.encode(privateKeyPem),
    );
  }
}