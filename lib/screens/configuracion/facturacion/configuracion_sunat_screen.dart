import 'dart:io';

import 'package:flutter/material.dart';

import '../../../facturacion/config/sunat_config.dart';
import '../../../facturacion/firma/certificado_service.dart';

class ConfiguracionSunatScreen extends StatelessWidget {
  const ConfiguracionSunatScreen({super.key});

  static const azul = Color(0xff0A2E6E);
  static const fondo = Color(0xffF5F7FA);

  String _mascararUsuario(String valor) {
    if (valor.isEmpty) return 'No configurado';
    if (valor.length <= 4) return '••••';
    return valor.substring(0, 3) + '••••' + valor.substring(valor.length - 2);
  }

  String _mascararRuc(String valor) {
    if (valor.isEmpty) return 'No configurado';
    if (valor.length < 5) return '••••••••';
    return valor.substring(0, 3) + '••••••' + valor.substring(valor.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    final produccion = SunatConfig.produccion;
    final ruc = SunatConfig.ruc;
    final usuario = SunatConfig.usuarioSol;
    final certificado = File(CertificadoService.rutaCertificado);
    final certificadoExiste = certificado.existsSync();
    final configurado = SunatConfig.configurado && certificadoExiste;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN SUNAT'),
        centerTitle: true,
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de facturación electrónica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: azul),
            ),
            const SizedBox(height: 6),
            Text(
              'Consulta el ambiente y los componentes configurados para la comunicación con SUNAT.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            _estadoCard(
              titulo: 'Ambiente SUNAT',
              valor: produccion ? 'PRODUCCIÓN' : 'BETA / PRUEBAS',
              icono: produccion ? Icons.cloud_done_rounded : Icons.science_rounded,
              color: produccion ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            _estadoCard(
              titulo: 'Configuración',
              valor: configurado ? 'Configurada' : 'Incompleta',
              icono: configurado ? Icons.verified_rounded : Icons.warning_amber_rounded,
              color: configurado ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _fila('RUC emisor', _mascararRuc(ruc)),
                    const Divider(height: 24),
                    _fila('Usuario SOL', _mascararUsuario(usuario)),
                    const Divider(height: 24),
                    _fila('Contraseña SOL', SunatConfig.claveSol.isNotEmpty ? 'Configurada ••••' : 'No configurada'),
                    const Divider(height: 24),
                    _fila('Contraseña certificado', SunatConfig.passwordCertificado.isNotEmpty ? 'Configurada ••••' : 'No configurada'),
                    const Divider(height: 24),
                    _fila('Certificado digital', certificadoExiste ? 'Encontrado' : 'No encontrado'),
                    const Divider(height: 24),
                    _fila('Endpoint', produccion ? 'Producción SUNAT' : 'Beta SUNAT'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xffFFF8E1),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Por seguridad, las credenciales SOL y la contraseña del certificado no se muestran ni se editan desde esta pantalla. El ambiente de producción tampoco se cambia accidentalmente desde aquí.',
                        style: TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String titulo, String valor) {
    return Row(
      children: [
        Expanded(child: Text(titulo, style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
        const SizedBox(width: 16),
        Flexible(
          child: Text(valor, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: azul)),
        ),
      ],
    );
  }

  Widget _estadoCard({required String titulo, required String valor, required IconData icono, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(valor, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}