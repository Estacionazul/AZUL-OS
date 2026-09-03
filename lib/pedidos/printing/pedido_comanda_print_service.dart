import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../models/item_carrito.dart';
import '../../services/printer_service.dart';
import '../models/pedido_abierto.dart';

class PedidoComandaPrintService {
  final PrinterService printerService;

  const PedidoComandaPrintService({required this.printerService});

  Future<void> imprimir({
    required PedidoAbierto pedido,
    required List<ItemCarrito> items,
    required int numeroComanda,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm58, profile);

    final bytes = <int>[];

    bytes.addAll(generator.reset());
    bytes.addAll(generator.setGlobalCodeTable('CP850'));

    bytes.addAll(
      generator.text(
        'ESTACION AZUL',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    );

    bytes.addAll(
      generator.text(
        'COMANDA',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    );

    bytes.addAll(generator.emptyLines(1));

    bytes.addAll(
      generator.text(
        pedido.ubicacion.nombre.toUpperCase(),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    );

    bytes.addAll(
      generator.text(
        'PEDIDO ${pedido.numero}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );

    bytes.addAll(
      generator.text(
        'COMANDA #$numeroComanda',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );

    bytes.addAll(generator.hr());

    for (final item in items) {
      bytes.addAll(
        generator.text(
          '${item.cantidad} x ${item.producto.nombre}',
          styles: const PosStyles(bold: true),
        ),
      );

      final opciones = <String>[];

      if (item.tipoLeche != null && item.tipoLeche!.trim().isNotEmpty) {
        opciones.add('Leche: ${item.tipoLeche}');
      }

      if (item.endulzante != null && item.endulzante!.trim().isNotEmpty) {
        opciones.add('Endulzante: ${item.endulzante}');
      }

      if (item.infusion != null && item.infusion!.trim().isNotEmpty) {
        opciones.add('Infusion: ${item.infusion}');
      }

      if (item.extraShot) {
        opciones.add('Extra Shot');
      }

      if (item.observaciones != null && item.observaciones!.trim().isNotEmpty) {
        opciones.add('Obs: ${item.observaciones}');
      }

      for (final opcion in opciones) {
        bytes.addAll(generator.text('  $opcion'));
      }

      bytes.addAll(generator.emptyLines(1));
    }

    if (pedido.observaciones.trim().isNotEmpty) {
      bytes.addAll(generator.hr());

      bytes.addAll(
        generator.text(
          'OBSERVACION DEL PEDIDO:',
          styles: const PosStyles(bold: true),
        ),
      );

      bytes.addAll(generator.text(pedido.observaciones.trim()));
    }

    bytes.addAll(generator.hr());

    final ahora = DateTime.now();

    bytes.addAll(
      generator.text(
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );

    bytes.addAll(generator.emptyLines(2));
    bytes.addAll(generator.cut());

    await printerService.print(bytes);
  }
}
