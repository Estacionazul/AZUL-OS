import 'package:flutter/material.dart';

class FacturacionScreen extends StatelessWidget {
  const FacturacionScreen({super.key});

  static const Color azul = Color(0xff0A2E6E);
  static const Color fondo = Color(0xffF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('FACTURACIÓN ELECTRÓNICA'),
        centerTitle: true,
        backgroundColor: azul,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _encabezado(),

            const SizedBox(height: 20),

            _ModuloCard(
              icono: Icons.receipt_long_rounded,
              titulo: 'Comprobantes electrónicos',
              subtitulo: 'Consulta y administra boletas y facturas emitidas.',
              color: azul,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _ModuloCard(
              icono: Icons.description_rounded,
              titulo: 'Resúmenes diarios SUNAT',
              subtitulo:
                  'Crea, genera, envía y consulta el estado de los resúmenes.',
              color: azul,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _ModuloCard(
              icono: Icons.sync_rounded,
              titulo: 'Estado de envíos',
              subtitulo:
                  'Revisa comprobantes pendientes, enviados, aceptados o rechazados.',
              color: azul,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _ModuloCard(
              icono: Icons.settings_rounded,
              titulo: 'Configuración SUNAT',
              subtitulo:
                  'Ambiente, datos del emisor y parámetros de facturación electrónica.',
              color: azul,
              onTap: () {},
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xffE8F0F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: azul,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Facturación electrónica activa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Desde aquí se administrará el ciclo de comprobantes y comunicaciones con SUNAT.',
                            style: TextStyle(
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
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

  Widget _encabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestión tributaria',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: azul,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Administra los comprobantes electrónicos y los procesos de SUNAT de Estación Azul.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _ModuloCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icono,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
