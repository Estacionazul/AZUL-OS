import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import 'reset_service.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _seccion(
            icono: Icons.store,
            titulo: 'Datos del negocio',
            subtitulo: 'Nombre, RUC, dirección y datos de Estación Azul',
            onTap: () {},
          ),
          _seccion(
            icono: Icons.receipt_long,
            titulo: 'Facturación electrónica',
            subtitulo: 'SUNAT, series y configuración de comprobantes',
            onTap: () {},
          ),
          _seccion(
            icono: Icons.print,
            titulo: 'Impresora',
            subtitulo: 'Configurar impresora de tickets',
            onTap: () {},
          ),
          _seccion(
            icono: Icons.payments,
            titulo: 'Precios y extras',
            subtitulo: 'Tamaños, extras y valores adicionales',
            onTap: () {},
          ),
          _seccion(
            icono: Icons.security,
            titulo: 'Usuarios y permisos',
            subtitulo: 'Usuarios, roles y permisos del sistema',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.restart_alt,
                color: Colors.red,
              ),
              title: const Text(
                'Reset de datos de prueba',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Elimina únicamente ventas, pedidos y movimientos de caja de prueba',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmarReset(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icono),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _confirmarReset(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text('Reset de datos de prueba'),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Esta operación eliminará únicamente datos operativos de prueba:\n\n'
              '• Ventas\n'
              '• Detalles de ventas\n'
              '• Pedidos\n'
              '• Detalles de pedidos\n'
              '• Movimientos de caja\n\n'
              'NO eliminará:\n'
              '• Comprobantes electrónicos\n'
              '• Correlativos SUNAT\n'
              '• Productos\n'
              '• Insumos ni stock\n'
              '• Recetas\n'
              '• Clientes\n'
              '• Empresa\n'
              '• Usuarios y permisos\n'
              '• Movimientos de inventario\n\n'
              'Esta operación no se puede deshacer.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sí, limpiar datos'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !context.mounted) {
      return;
    }

    try {
      final db = context.read<AppDatabase>();

      await ResetService(db).limpiarDatosOperativosPrueba();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Datos operativos de prueba eliminados correctamente.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo realizar el reset: $e'),
        ),
      );
    }
  }
}
