import 'package:drift/drift.dart';

import '../models/venta.dart';
import '../database/app_database.dart' show MovimientosCajaCompanion;
import '../repositories/ventas_repository.dart';
import '../repositories/cajas_repository.dart';
import '../repositories/empresa_repository.dart';

import 'carrito_service.dart';
import 'venta_service.dart';
import 'ventas_service.dart';
import 'inventario_automatico_service.dart';
import 'printer_service.dart';
import 'ticket_print_service.dart';

import '../ticket/esc_pos_renderer.dart';
import 'package:flutter/foundation.dart';

class CobroService {
  final CarritoService carritoService;
  final VentasService ventasService;
  final VentaService ventaService;
  final VentasRepository ventasRepository;
  final InventarioAutomaticoService inventarioAutomaticoService;
  final EmpresaRepository empresaRepository;
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
    required this.empresaRepository,
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

    final ventaActual = ventaService.venta;

    // ==========================================================
    // OBTENER NÚMERO SEGÚN EL TIPO DE DOCUMENTO
    // ==========================================================

    late final String numeroVenta;

    switch (ventaActual.tipoDocumento) {
      case 'Boleta':
        numeroVenta =
        await empresaRepository.obtenerSiguienteNumeroBoleta();
        break;

      case 'Factura':
        numeroVenta =
        await empresaRepository.obtenerSiguienteNumeroFactura();
        break;

      case 'Nota de Venta':
      default:
        numeroVenta =
        await ventasRepository.obtenerSiguienteNumeroVenta();
        break;
    }

    final total = carritoService.total;
    final subtotal = total / 1.18;
    final igv = total - subtotal;

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

      nombreCliente: ventaActual.tipoDocumento == 'Factura'
          ? (ventaActual.razonSocial?.trim().isNotEmpty == true
          ? ventaActual.razonSocial!.trim()
          : ventaActual.clienteNombre)
          : ventaActual.clienteNombre,

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

    final idGuardado = await ventasRepository.guardarVenta(
      venta,
    );

    debugPrint("========== VENTA ANTES DE GUARDAR ==========");
    debugPrint("NUMERO: ${venta.numero}");
    debugPrint("TIPO: ${venta.tipoDocumento}");
    debugPrint("DNI: ${venta.dni}");
    debugPrint("RUC: ${venta.ruc}");
    debugPrint("NOMBRE: ${venta.nombreCliente}");
    debugPrint("RAZON SOCIAL: ${venta.razonSocial}");
    debugPrint("DIRECCION: ${venta.direccionFiscal}");

    final ventaVerificada =
    await ventasRepository.obtenerVenta(idGuardado);

    debugPrint("========== VENTA DESPUES DE GUARDAR ==========");
    debugPrint("ID: $idGuardado");
    debugPrint("NUMERO: ${ventaVerificada?.numero}");
    debugPrint("TIPO: ${ventaVerificada?.tipoDocumento}");
    debugPrint("DNI: ${ventaVerificada?.dni}");
    debugPrint("RUC: ${ventaVerificada?.ruc}");
    debugPrint("NOMBRE: ${ventaVerificada?.nombreCliente}");
    debugPrint("RAZON SOCIAL: ${ventaVerificada?.razonSocial}");
    debugPrint("DIRECCION: ${ventaVerificada?.direccionFiscal}");

    // ==========================================================
    // INCREMENTAR CORRELATIVO
    // ==========================================================
    //
    // Solo se incrementa DESPUÉS de guardar correctamente
    // la venta.
    //
    // Nota de Venta:
    //   utiliza su propio correlativo V000001, V000002...
    //
    // Boleta:
    //   B001-00000001, B001-00000002...
    //
    // Factura:
    //   F001-00000001, F001-00000002...
    //
    // ==========================================================

    switch (venta.tipoDocumento) {
      case 'Boleta':
        await empresaRepository.incrementarCorrelativoBoleta();
        break;

      case 'Factura':
        await empresaRepository.incrementarCorrelativoFactura();
        break;

      case 'Nota de Venta':
      default:
        break;
    }

    ventasService.registrarVenta(
      venta,
    );

    // ==========================================================
    // REGISTRAR VENTA EN CAJA
    // ==========================================================
    //
    // Todas las ventas quedan registradas en movimientos de caja.
    //
    // Efectivo      -> suma al efectivo esperado
    // Yape          -> no suma al efectivo
    // Plin          -> no suma al efectivo
    // Tarjeta       -> no suma al efectivo
    // Transferencia -> no suma al efectivo
    //
    // La pantalla Caja calcula el efectivo esperado
    // considerando únicamente las ventas en EFECTIVO.
    // ==========================================================

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
          observacion: Value(
            'Venta ${venta.metodoPago} registrada desde POS',
          ),
        ),
      );
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