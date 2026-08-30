import 'dart:io';

import 'package:azul_os/facturacion/firma/firma_digital_service.dart';

Future<void> main() async {
  stdout.write('🔐 Ingresa la contraseña del certificado: ');

  final password = stdin.readLineSync();

  if (password == null || password.isEmpty) {
    print('❌ No se ingresó ninguna contraseña.');
    return;
  }

  const rutaCertificado =
      r'C:\Users\El Cucalambe\AppData\Local\AZUL_OS\certificado\certificado.p12';

  final servicio = FirmaDigitalService(
    rutaCertificado: rutaCertificado,
    passwordCertificado: password,
  );

  // XML UBL mínimo para probar la firma.
  const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<Invoice
    xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
  <ext:UBLExtensions
      xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">
    <ext:UBLExtension>
      <ext:ExtensionContent>
      </ext:ExtensionContent>
    </ext:UBLExtension>
  </ext:UBLExtensions>

  <cbc:UBLVersionID>2.1</cbc:UBLVersionID>
  <cbc:CustomizationID>2.0</cbc:CustomizationID>
  <cbc:ID>B001-00000001</cbc:ID>
  <cbc:IssueDate>2026-08-29</cbc:IssueDate>
  <cbc:InvoiceTypeCode>03</cbc:InvoiceTypeCode>
  <cbc:DocumentCurrencyCode>PEN</cbc:DocumentCurrencyCode>
</Invoice>''';

  try {
    print('');
    print('==================================================');
    print('🧪 PRUEBA DE FIRMA DIGITAL XML');
    print('==================================================');

    final xmlFirmado = await servicio.firmarXml(xml);

    print('');
    print('==================================================');
    print('🔎 VALIDANDO XML FIRMADO');
    print('==================================================');

    print(
      xmlFirmado.contains('<ds:Signature')
          ? '✅ ds:Signature encontrado.'
          : '❌ ds:Signature NO encontrado.',
    );

    print(
      xmlFirmado.contains('<ds:SignatureValue>')
          ? '✅ ds:SignatureValue encontrado.'
          : '❌ ds:SignatureValue NO encontrado.',
    );

    print(
      xmlFirmado.contains('<ds:X509Certificate>')
          ? '✅ ds:X509Certificate encontrado.'
          : '❌ ds:X509Certificate NO encontrado.',
    );

    final archivoSalida = File('xml_prueba_firmado.xml');

    await archivoSalida.writeAsString(
      xmlFirmado,
      encoding: const SystemEncoding(),
    );

    print('');
    print('📄 XML firmado guardado en:');
    print(archivoSalida.absolute.path);
    print('');
    print('🎉 PRUEBA DE FIRMA TERMINADA');
    print('==================================================');
  } catch (e, stackTrace) {
    print('');
    print('==================================================');
    print('❌ ERROR EN LA FIRMA DIGITAL');
    print('==================================================');
    print(e);
    print('');
    print(stackTrace);
    print('==================================================');
  }
}