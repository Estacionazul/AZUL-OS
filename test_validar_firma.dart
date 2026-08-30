import 'dart:io';

import 'package:pkcs12_parser/pkcs12_parser.dart';
import 'package:xml/xml.dart';
import 'package:xml_crypto/xml_crypto.dart';

Future<void> main() async {
  print('==============================================');
  print('🔐 VALIDACIÓN CRIPTOGRÁFICA XMLDSig');
  print('==============================================');

  // ==========================================================
  // RUTAS
  // ==========================================================

  const xmlPath =
      'xml_prueba_firmado.xml';

  const certificadoP12Path =
      r'C:\Users\El Cucalambe\AppData\Local\AZUL_OS\certificado\certificado.p12';

  const certificadoPemPath =
      'certificado_publico_validacion.pem';

  // ==========================================================
  // 1. VERIFICAR XML
  // ==========================================================

  final xmlFile = File(xmlPath);

  if (!xmlFile.existsSync()) {
    throw StateError(
      'No se encontró el XML:\n$xmlPath',
    );
  }

  print('✅ XML encontrado.');

  final xmlContenido =
  xmlFile.readAsStringSync();

  // ==========================================================
  // 2. VERIFICAR CERTIFICADO P12
  // ==========================================================

  final certificadoP12 =
  File(certificadoP12Path);

  if (!certificadoP12.existsSync()) {
    throw StateError(
      'No se encontró el certificado P12:\n'
          '$certificadoP12Path',
    );
  }

  print('✅ Certificado P12 encontrado.');

  // ==========================================================
  // 3. PEDIR CONTRASEÑA
  // ==========================================================

  stdout.write(
    '🔑 Ingresa la contraseña del certificado: ',
  );

  final password =
  stdin.readLineSync();

  if (password == null ||
      password.isEmpty) {
    throw StateError(
      'No se ingresó la contraseña del certificado.',
    );
  }

  // ==========================================================
  // 4. ABRIR P12
  // ==========================================================

  print('');
  print('📦 Abriendo certificado PKCS#12...');

  final bytes =
  certificadoP12.readAsBytesSync();

  late final dynamic pfx;

  try {
    pfx = Pkcs12.load(
      bytes,
      password,
    );
  } catch (e) {
    print('');
    print('❌ No se pudo abrir el certificado.');
    print(e);
    rethrow;
  }

  print('✅ Certificado PKCS#12 abierto correctamente.');

  // ==========================================================
  // 5. OBTENER CERTIFICADO X.509 EN PEM
  // ==========================================================

  final certificadoPem =
  pfx.certificatePem.toString();

  if (certificadoPem.trim().isEmpty) {
    throw StateError(
      'El certificado X.509 obtenido del P12 está vacío.',
    );
  }

  if (!certificadoPem.contains(
    '-----BEGIN CERTIFICATE-----',
  )) {
    throw StateError(
      'El certificado obtenido no está en formato PEM válido.',
    );
  }

  print('📜 Certificado X.509 obtenido correctamente.');

  // ==========================================================
  // 6. GUARDAR PEM TEMPORAL
  // ==========================================================

  final pemFile =
  File(certificadoPemPath);

  pemFile.writeAsStringSync(
    certificadoPem,
  );

  print(
    '✅ Certificado PEM temporal creado:',
  );

  print(
    '   ${pemFile.absolute.path}',
  );

  // ==========================================================
  // 7. PARSEAR XML
  // ==========================================================

  final document =
  XmlDocument.parse(xmlContenido);

  print('✅ XML parseado correctamente.');

  // ==========================================================
  // 8. BUSCAR ds:Signature
  // ==========================================================

  final firmas =
  document.findAllElements(
    'Signature',
    namespace:
    'http://www.w3.org/2000/09/xmldsig#',
  );

  if (firmas.isEmpty) {
    throw StateError(
      'No se encontró ds:Signature.',
    );
  }

  if (firmas.length != 1) {
    throw StateError(
      'Se esperaba exactamente una firma. '
          'Encontradas: ${firmas.length}',
    );
  }

  final signatureElement =
      firmas.first;

  print('✅ ds:Signature encontrado.');

  // ==========================================================
  // 9. BUSCAR SignedInfo
  // ==========================================================

  final signedInfo =
  signatureElement.findElements(
    'SignedInfo',
    namespace:
    'http://www.w3.org/2000/09/xmldsig#',
  );

  if (signedInfo.isEmpty) {
    throw StateError(
      'No se encontró ds:SignedInfo.',
    );
  }

  print('✅ ds:SignedInfo encontrado.');

  // ==========================================================
  // 10. BUSCAR SignatureValue
  // ==========================================================

  final signatureValue =
  signatureElement.findElements(
    'SignatureValue',
    namespace:
    'http://www.w3.org/2000/09/xmldsig#',
  );

  if (signatureValue.isEmpty) {
    throw StateError(
      'No se encontró ds:SignatureValue.',
    );
  }

  print('✅ ds:SignatureValue encontrado.');

  // ==========================================================
  // 11. BUSCAR KeyInfo
  // ==========================================================

  final keyInfo =
  signatureElement.findElements(
    'KeyInfo',
    namespace:
    'http://www.w3.org/2000/09/xmldsig#',
  );

  if (keyInfo.isEmpty) {
    throw StateError(
      'No se encontró ds:KeyInfo.',
    );
  }

  print('✅ ds:KeyInfo encontrado.');

  // ==========================================================
  // 12. BUSCAR X509Certificate
  // ==========================================================

  final x509 =
  signatureElement.findAllElements(
    'X509Certificate',
    namespace:
    'http://www.w3.org/2000/09/xmldsig#',
  );

  if (x509.isEmpty) {
    throw StateError(
      'No se encontró ds:X509Certificate.',
    );
  }

  print(
    '✅ ds:X509Certificate encontrado.',
  );

  // ==========================================================
  // 13. CREAR VERIFICADOR
  // ==========================================================

  final sig =
  SignedXml()
    ..keyInfoProvider =
    FileKeyInfo(
      pemFile.absolute.path,
    );

  // ==========================================================
  // 14. CARGAR FIRMA
  // ==========================================================

  sig.loadSignature(
    signatureElement,
  );

  print('✅ Firma cargada en xml_crypto.');

  // ==========================================================
  // 15. VALIDAR FIRMA
  // ==========================================================

  print('');
  print('==============================================');
  print('🔎 VALIDANDO FIRMA CRIPTOGRÁFICA');
  print('==============================================');

  print('🔎 Verificando DigestValue...');
  print('🔎 Verificando SignatureValue...');

  final resultado =
  sig.checkSignature(
    xmlContenido,
  );

  // ==========================================================
  // 16. RESULTADO
  // ==========================================================

  print('');

  if (resultado) {
    print('==============================================');
    print('🎉 FIRMA CRIPTOGRÁFICAMENTE VÁLIDA');
    print('==============================================');

    print('✅ XML válido.');
    print('✅ ds:Signature encontrado.');
    print('✅ ds:SignedInfo encontrado.');
    print('✅ ds:SignatureValue encontrado.');
    print('✅ ds:KeyInfo encontrado.');
    print('✅ ds:X509Certificate encontrado.');
    print('✅ DigestValue correcto.');
    print('✅ SignatureValue correcto.');
    print('✅ Certificado público válido para la firma.');

    print('==============================================');
  } else {
    print('==============================================');
    print('❌ FIRMA CRIPTOGRÁFICAMENTE INVÁLIDA');
    print('==============================================');

    print('');
    print('Errores de validación:');

    for (final error in sig.validationErrors) {
      print('❌ $error');
    }

    print('==============================================');
  }

  // ==========================================================
  // 17. NO BORRAR EL PEM TODAVÍA
  // ==========================================================
  //
  // Lo dejamos guardado para poder inspeccionarlo
  // si la validación falla.
  //
  // ==========================================================

  print('');
  print(
    '📄 PEM utilizado para la validación:',
  );
  print(
    pemFile.absolute.path,
  );

  print('');
  print('==============================================');
  print('🏁 VALIDACIÓN TERMINADA');
  print('==============================================');
}