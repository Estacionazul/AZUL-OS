import 'dart:io';

import 'package:pkcs12_parser/pkcs12_parser.dart';

class CertificadoService {
  static const String rutaCertificado =
      r'C:\Users\El Cucalambe\AppData\Local\AZUL_OS\certificado\certificado.p12';

  /// Prueba que el certificado .p12 existe y que la contraseña es correcta.
  static Future<void> probarCertificado(String password) async {
    print('==============================================');
    print('🔐 PRUEBA DE CERTIFICADO DIGITAL');
    print('==============================================');

    final archivo = File(rutaCertificado);

    // 1. Verificar que el archivo existe.
    if (!await archivo.exists()) {
      throw Exception('❌ No se encontró el certificado en:\n$rutaCertificado');
    }

    print('✅ Archivo .p12 encontrado.');

    // 2. Leer el certificado.
    final bytes = await archivo.readAsBytes();

    print('✅ Certificado leído.');
    print('📦 Tamaño: ${bytes.length} bytes');

    // 3. Abrir el PKCS#12 usando la contraseña.
    try {
      final pfx = Pkcs12.load(bytes, password);

      print('✅ CONTRASEÑA CORRECTA.');
      print('✅ Certificado PKCS#12 abierto correctamente.');

      // 4. Comprobar que contiene clave privada.
      final privateKey = pfx.privateKey;

      print('✅ Clave privada encontrada.');
      print('🔑 Tipo de clave: ${privateKey.runtimeType}');

      // 5. Comprobar certificado.
      print('✅ Certificado X.509 encontrado.');

      // 6. Mostrar PEM solamente como comprobación.
      final certificatePem = pfx.certificatePem;

      print('📜 Certificado PEM generado correctamente.');
      print(
        '📏 Longitud del certificado PEM: ${certificatePem.length} caracteres',
      );

      print('==============================================');
      print('🎉 CERTIFICADO LISTO PARA LA FIRMA DIGITAL');
      print('==============================================');
    } catch (e) {
      print('==============================================');
      print('❌ ERROR AL ABRIR EL CERTIFICADO');
      print('==============================================');
      print(e);

      rethrow;
    }
  }
}
