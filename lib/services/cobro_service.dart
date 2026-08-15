import '../models/venta.dart';
import 'carrito_service.dart';
import 'venta_service.dart';
import 'ventas_service.dart';
import '../repositories/ventas_repository.dart';
import 'inventario_automatico_service.dart';
import 'printer_service.dart';
import 'ticket_print_service.dart';
import '../ticket/esc_pos_renderer.dart';

class CobroService {
  final CarritoService carritoService;
  final VentasService ventasService;
  final VentaService ventaService;
  final VentasRepository ventasRepository;
  final InventarioAutomaticoService inventarioAutomaticoService;

  final TicketPrintService ticketPrintService;
  final EscPosRenderer escPosRenderer;
  final PrinterService printerService;

  CobroService({
    required this.carritoService,
    required this.ventasService,
    required this.ventaService,
    required this.ventasRepository,
    required this.inventarioAutomaticoService,
    required this.ticketPrintService,
    required this.escPosRenderer,
    required this.printerService,
  });

  Future<void> cobrar({
    required String metodoPago,
  }) async {
    if (carritoService.items.isEmpty) return;

    final ahora = DateTime.now();
    final numeroVenta = await ventasRepository.obtenerSiguienteNumeroVenta();

    final total = carritoService.total;
    final subtotal = total / 1.18;
    final igv = total - subtotal;

    final ventaActual = ventaService.venta;

    final venta = Venta(
      numero: numeroVenta,
      fecha: ahora,
      items: List.from(carritoService.items),
      subtotal: subtotal,
      igv: igv,
      total: total,
      metodoPago: metodoPago,

      tipoDocumento: ventaActual.tipoDocumento,

      dni: ventaActual.dni,
      ruc: ventaActual.ruc,

      nombreCliente: ventaActual.clienteNombre,
      razonSocial: ventaActual.razonSocial,
      direccionFiscal: ventaActual.direccionFiscal,

      descuento: ventaActual.descuento,
      observaciones: ventaActual.observaciones,
    );

    // ==========================================================
// VALIDAR INVENTARIO ANTES DE REGISTRAR LA VENTA
// ==========================================================

    await inventarioAutomaticoService.validarVenta(
      venta,
    );

// ==========================================================
// GUARDAR VENTA
// ==========================================================

    await ventasRepository.guardarVenta(
      venta,
    );

    ventasService.registrarVenta(
      venta,
    );

// ==========================================================
// DESCONTAR INVENTARIO
// ==========================================================

    await inventarioAutomaticoService.descontarInventario(
      venta,
    );

//==============================
// Generar Ticket
//==============================

    final ticket = ticketPrintService.generarTicket(venta);

//==============================
// Convertir a ESC/POS
//==============================

    final bytes = await escPosRenderer.render(ticket);

//==============================
// Imprimir
//==============================

    await printerService.print(bytes);

//==============================

    ventaService.nuevaVenta();
    carritoService.vaciarCarrito();
  }
}