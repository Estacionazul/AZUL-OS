import 'package:drift/drift.dart';

import '../models/venta.dart';
import '../database/app_database.dart' show MovimientosCajaCompanion;
import '../repositories/ventas_repository.dart';
import '../repositories/cajas_repository.dart';

import 'carrito_service.dart';
import 'venta_service.dart';
import 'ventas_service.dart';
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
  final CajasRepository cajasRepository;

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
    required this.cajasRepository,
  });

  Future<void> cobrar({
    required String metodoPago,
  }) async {
    if (carritoService.items.isEmpty) return;

    final ahora = DateTime.now();
    final numeroVenta =
    await ventasRepository.obtenerSiguienteNumeroVenta();

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
    // REGISTRAR EN CAJA SOLO SI ES EFECTIVO
    // ==========================================================
    //
    // La Caja representa el dinero físico disponible.
    //
    // Efectivo      -> aumenta Caja
    // Yape          -> NO aumenta Caja
    // Plin          -> NO aumenta Caja
    // Tarjeta       -> NO aumenta Caja
    // Transferencia -> NO aumenta Caja
    //
    // La venta sí queda registrada en Ventas.
    // ==========================================================

    final esEfectivo =
        venta.metodoPago.trim().toLowerCase() == 'efectivo';

    if (esEfectivo) {
      final cajaAbierta =
      await cajasRepository.obtenerAbierta();

      if (cajaAbierta != null) {
        await cajasRepository.registrarMovimiento(
          MovimientosCajaCompanion(
            cajaId: Value(cajaAbierta.id),
            tipo: const Value('VENTA'),
            concepto: Value('Venta ${venta.numero}'),
            monto: Value(venta.total),
            metodoPago: Value(venta.metodoPago),
            referencia: Value(venta.numero),
            observacion: const Value(
              'Venta en efectivo registrada desde POS',
            ),
          ),
        );
      }
    }

    // ==========================================================
    // DESCONTAR INVENTARIO
    // ==========================================================

    await inventarioAutomaticoService.descontarInventario(
      venta,
    );

    // ==========================================================
    // GENERAR TICKET
    // ==========================================================

    final ticket = ticketPrintService.generarTicket(
      venta,
    );

    // ==========================================================
    // CONVERTIR A ESC/POS
    // ==========================================================

    final bytes = await escPosRenderer.render(
      ticket,
    );

    // ==========================================================
    // IMPRIMIR
    // ==========================================================

    await printerService.print(
      bytes,
    );

    // ==========================================================
    // LIMPIAR VENTA
    // ==========================================================

    ventaService.nuevaVenta();
    carritoService.vaciarCarrito();
  }
}