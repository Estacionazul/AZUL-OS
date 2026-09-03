import '../models/venta.dart';
import 'ticket_print_service.dart';
import 'ventas_service.dart';

class VentaWorkflowService {
  final VentasService ventasService;
  final TicketPrintService ticketPrintService;

  VentaWorkflowService({
    required this.ventasService,
    required this.ticketPrintService,
  });

  /// Orquesta todo el proceso de una venta.
  Future<void> finalizarVenta(Venta venta) async {
    // 1. Registrar la venta
    ventasService.registrarVenta(venta);

    // 2. Generar el ticket
    final ticket = ticketPrintService.generarTicket(venta);

    // Evita advertencias mientras aún no imprimimos.
    assert(ticket.items.isNotEmpty || ticket.items.isEmpty);

    // ==================================================
    // FUTURAS FUNCIONALIDADES
    // ==================================================
    //
    // - Imprimir ticket
    // - Descontar inventario
    // - Enviar comanda a cocina
    // - Acumular puntos
    // - Actualizar reportes
    // - Enviar notificaciones
    //
    // ==================================================
  }
}
