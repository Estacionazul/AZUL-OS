import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/venta.dart';
import '../../services/printer_service.dart';
import '../../services/ticket_print_service.dart';
import '../../ticket/esc_pos_renderer.dart';

class VentasTable extends StatelessWidget {
  final List<Venta> ventas;

  const VentasTable({
    super.key,
    required this.ventas,
  });

  Future<void> _reimprimirTicket(
      BuildContext context,
      Venta venta,
      ) async {
    try {
      debugPrint('==============================================');
      debugPrint('🖨️ REIMPRIMIENDO TICKET');
      debugPrint('==============================================');
      debugPrint('Venta: ${venta.numero}');
      debugPrint('Total: S/ ${venta.total.toStringAsFixed(2)}');

      final ticketPrintService =
      context.read<TicketPrintService>();

      final escPosRenderer =
      context.read<EscPosRenderer>();

      final printerService =
      context.read<PrinterService>();

      //==============================================
      // GENERAR TICKET DESDE LA VENTA GUARDADA
      //==============================================

      final ticket =
      ticketPrintService.generarTicket(venta);

      //==============================================
      // CONVERTIR A ESC/POS
      //==============================================

      final bytes =
      await escPosRenderer.render(ticket);

      //==============================================
      // ENVIAR A IMPRESORA
      //==============================================

      await printerService.print(bytes);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ticket de la venta ${venta.numero} '
                'impreso correctamente.',
          ),
        ),
      );

      debugPrint('✅ TICKET REIMPRESO CORRECTAMENTE');
      debugPrint('==============================================');
    } catch (e, stackTrace) {
      debugPrint('==============================================');
      debugPrint('❌ ERROR AL REIMPRIMIR TICKET');
      debugPrint('==============================================');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo imprimir el ticket: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("N°")),
          DataColumn(label: Text("Cliente")),
          DataColumn(label: Text("Documento")),
          DataColumn(label: Text("Pago")),
          DataColumn(label: Text("Total")),
          DataColumn(label: Text("Fecha")),
        ],
        rows: ventas.map((venta) {
          return DataRow(
            cells: [
              DataCell(
                Text(venta.numero),
              ),

              DataCell(
                Text(
                  venta.nombreCliente?.isNotEmpty == true
                      ? venta.nombreCliente!
                      : "Cliente General",
                ),
              ),

              DataCell(
                Text(venta.tipoDocumento),
              ),

              DataCell(
                Text(venta.metodoPago),
              ),

              DataCell(
                Text(
                  "S/ ${venta.total.toStringAsFixed(2)}",
                ),
              ),

              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${venta.fecha.day.toString().padLeft(2, '0')}/"
                          "${venta.fecha.month.toString().padLeft(2, '0')}/"
                          "${venta.fecha.year}",
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "Reimprimir ticket",
                      icon: const Icon(
                        Icons.print_outlined,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        _reimprimirTicket(
                          context,
                          venta,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}