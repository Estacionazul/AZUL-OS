import 'dart:io';

class SunatConfig {
  static String get ruc =>
      Platform.environment['AZUL_OS_RUC']?.trim() ?? '';

  static String get usuarioSol {
  if (!produccion) {
    return '10446152080MODDATOS';
  }

  return Platform.environment['AZUL_OS_SOL_USER']?.trim() ?? '';
}

  static String get claveSol {
  if (!produccion) {
    return 'MODDATOS';
  }

  return Platform.environment['AZUL_OS_SOL_PASSWORD'] ?? '';
}

  static String get passwordCertificado =>
      Platform.environment['AZUL_OS_CERT_PASSWORD'] ?? '';

  static bool get produccion {
    final valor =
        Platform.environment['AZUL_OS_SUNAT_PRODUCCION']?.trim().toLowerCase();

    return valor == '1' ||
        valor == 'true' ||
        valor == 'si' ||
        valor == 'sí';
  }

  static bool get configurado =>
      ruc.isNotEmpty &&
      usuarioSol.isNotEmpty &&
      claveSol.isNotEmpty &&
      passwordCertificado.isNotEmpty;

  static void validar() {
    final faltantes = <String>[];

    if (ruc.isEmpty) faltantes.add('AZUL_OS_RUC');
    if (usuarioSol.isEmpty) faltantes.add('AZUL_OS_SOL_USER');
    if (claveSol.isEmpty) faltantes.add('AZUL_OS_SOL_PASSWORD');
    if (passwordCertificado.isEmpty) {
      faltantes.add('AZUL_OS_CERT_PASSWORD');
    }

    if (faltantes.isNotEmpty) {
      throw StateError(
        'Configuración SUNAT incompleta. Faltan: ${faltantes.join(', ')}',
      );
    }
  }
}

