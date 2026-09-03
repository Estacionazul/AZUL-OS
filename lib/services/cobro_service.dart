import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

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
import '../facturacion/services/facturacion_service.dart';
import '../facturacion/firma/firma_digital_service.dart';
import '../facturacion/sunat/sunat_service.dart';
import '../facturacion/models/comprobante_electronico.dart';

class CobroService {
  final CarritoService carritoService;
  final VentasService ventasService;
  final VentaService ventaService;
  final VentasRepository ventasRepository;
  final InventarioAutomaticoService inventarioAutomaticoService;
  final EmpresaRepository empresaRepository;
  final CajasRepository cajasRepository;
  final FacturacionService facturacionService;
  final FirmaDigitalService firmaDigitalService;
  final SunatService sunatService;

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
    required this.facturacionService,
    required this.firmaDigitalService,
    required this.sunatService,
  });

  Future<void> cobrar({required String metodoPago}) async {
    if (carritoService.items.isEmpty) return;

    final ahora = DateTime.now();

    final ventaActual = ventaService.venta;

    // ==========================================================
    // OBTENER NÃšMERO SEGÃšN EL TIPO DE DOCUMENTO
    // ==========================================================

    late final String numeroVenta;

    switch (ventaActual.tipoDocumento) {
      case 'Boleta':
        numeroVenta = await empresaRepository.obtenerSiguienteNumeroBoleta();
        break;

      case 'Factura':
        numeroVenta = await empresaRepository.obtenerSiguienteNumeroFactura();
        break;

      case 'Nota de Venta':
      default:
        numeroVenta = await ventasRepository.obtenerSiguienteNumeroVenta();
        break;
    }

    // ==========================================================
    // VERIFICAR CAJA ABIERTA ANTES DE REGISTRAR LA VENTA
    // ==========================================================

    final cajaAbierta = await cajasRepository.obtenerAbierta();

    if (cajaAbierta == null) {
      throw StateError(
        'No hay una caja abierta. '
        'Debe abrir la caja antes de registrar una venta.',
      );
    }

    // ==========================================================
    // CALCULAR TOTALES
    // ==========================================================

    final total = carritoService.total;
    final subtotal = total / 1.18;
    final igv = total - subtotal;

    // ==========================================================
    // CREAR VENTA
    // ==========================================================

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

    await inventarioAutomaticoService.validarVenta(venta);

    // ==========================================================
    // GUARDAR VENTA
    // ==========================================================

    final idGuardado = await ventasRepository.guardarVenta(venta);

    // ==========================================================
    // CREAR COMPROBANTE ELECTRONICO
    // ==========================================================
    //
    // Boleta y Factura requieren registro electronico.
    // Se utiliza EXACTAMENTE el mismo numero de la venta.
    //
    // Ejemplo:
    //   Venta:       B001-00000001
    //   Comprobante: B001-00000001
    //
    // Nota de Venta no genera comprobante electronico SUNAT.
    // ==========================================================

    if (venta.tipoDocumento == 'Boleta' ||
        venta.tipoDocumento == 'Factura') {
      final partesNumero = venta.numero.split('-');

      final serie = partesNumero.first;
      final numero = int.parse(partesNumero.last);

      final tipoComprobante =
      venta.tipoDocumento == 'Boleta'
          ? TipoComprobanteElectronico.boleta
          : TipoComprobanteElectronico.factura;

      final comprobanteId =
      await facturacionService.crearComprobante(
        ventaId: idGuardado,
        tipo: tipoComprobante,
        serie: serie,
        numero: numero,
        fechaEmision: ahora,
        dni: venta.dni,
        ruc: venta.ruc,
        nombreCliente: venta.nombreCliente,
        direccionFiscal: venta.direccionFiscal,
        subtotal: venta.subtotal,
        igv: venta.igv,
        total: venta.total,
        metodoPago: metodoPago,
      );

      debugPrint('========== COMPROBANTE ELECTRÃ“NICO CREADO ==========');
      debugPrint('ID: $comprobanteId');
      debugPrint('TIPO: ${venta.tipoDocumento}');
      debugPrint('SERIE: $serie');
      debugPrint('NÃšMERO: $numero');
      debugPrint('COMPLETO: ${venta.numero}');

      // ==========================================================
      // GENERAR Y GUARDAR XML DEL COMPROBANTE
      // ==========================================================

      final empresa = await empresaRepository.obtener();

      if (empresa == null) {
        throw StateError(
          'No existe la configuraciÃ³n de la empresa. '
              'No se puede generar el XML del comprobante.',
        );
      }

      final xml = await facturacionService.generarXmlComprobante(
        comprobanteId: comprobanteId,
        rucEmisor: empresa.ruc,
        razonSocialEmisor: empresa.nombre,
        direccionEmisor: empresa.direccion,
        moneda: empresa.moneda,
        detalles: venta.items,
      );

      final xmlFirmado = await firmaDigitalService.firmarXml(xml);

      final tipoSunat = venta.tipoDocumento == 'Boleta' ? '03' : '01';

      if (partesNumero.length != 2) {
        throw StateError(
          'Numero de comprobante invalido: ${venta.numero}',
        );
      }

      final numeroSunat = int.parse(partesNumero[1]);

      // RESERVAR CORRELATIVO ANTES DEL ENVIO A SUNAT
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

      final respuestaSunat = await sunatService.enviarComprobante(
        xmlFirmado: xmlFirmado,
        tipoComprobante: tipoSunat,
        serie: partesNumero[0],
        numero: numeroSunat,
      );

      debugPrint('========== RESPUESTA SUNAT ==========');
      debugPrint('Respuesta SUNAT: $respuestaSunat');
      await facturacionService.guardarRespuestaSunat(
        id: comprobanteId,
        codigoRespuestaSunat: respuestaSunat.codigo,
        mensajeRespuestaSunat: respuestaSunat.mensaje,
        cdr: respuestaSunat.cdr,
        xml: respuestaSunat.xmlRespuesta,
        fechaEnvioSunat: DateTime.now(),
        fechaRespuestaSunat: DateTime.now(),
        estado: respuestaSunat.aceptado ? 'aceptado' : 'rechazado',
      );

      // ==========================================================
      // VALIDAR RESPUESTA SUNAT
      // ==========================================================

      if (!respuestaSunat.aceptado) {
        debugPrint('=====================================');
        debugPrint('❌ COMPROBANTE RECHAZADO POR SUNAT');
        debugPrint('Código: ${respuestaSunat.codigo}');
        debugPrint('Mensaje: ${respuestaSunat.mensaje}');
        debugPrint('=====================================');

        await ventasRepository.eliminarVenta(idGuardado);

        throw StateError(
          'SUNAT rechazó el comprobante ${venta.numero}. '
              'Código: ${respuestaSunat.codigo}. '
              'Mensaje: ${respuestaSunat.mensaje}',
        );
      }

      debugPrint('=====================================');
      debugPrint('========== XML GENERADO Y GUARDADO ==========');
      debugPrint('COMPROBANTE: ${venta.numero}');
      debugPrint('LONGITUD XML: ${xml.length}');
    }

    // ==========================================================
    // REGISTRAR VENTA EN CAJA
    // ==========================================================

    await cajasRepository.registrarMovimiento(
      MovimientosCajaCompanion(
        cajaId: Value(cajaAbierta.id),
        tipo: const Value('VENTA'),
        concepto: Value('Venta ${venta.numero}'),
        monto: Value(venta.total),
        metodoPago: Value(metodoPago.toUpperCase()),
        referencia: Value(venta.numero),
        observacion: Value(venta.tipoDocumento),
      ),
    );

    debugPrint('========== MOVIMIENTO CAJA REGISTRADO ==========');
    debugPrint('CAJA ID: ${cajaAbierta.id}');
    debugPrint('TIPO: VENTA');
    debugPrint('MONTO: ${venta.total}');
    debugPrint('METODO: ${metodoPago.toUpperCase()}');
    debugPrint('REFERENCIA: ${venta.numero}');

    // ==========================================================
    // VERIFICAR DATOS GUARDADOS
    // ==========================================================

    debugPrint('========== VENTA ANTES DE GUARDAR ==========');
    debugPrint('NUMERO: ${venta.numero}');
    debugPrint('TIPO: ${venta.tipoDocumento}');
    debugPrint('DNI: ${venta.dni}');
    debugPrint('RUC: ${venta.ruc}');
    debugPrint('NOMBRE: ${venta.nombreCliente}');
    debugPrint('RAZON SOCIAL: ${venta.razonSocial}');
    debugPrint('DIRECCION: ${venta.direccionFiscal}');

    final ventaVerificada = await ventasRepository.obtenerVenta(idGuardado);

    debugPrint('========== VENTA DESPUES DE GUARDAR ==========');
    debugPrint('ID: $idGuardado');
    debugPrint('NUMERO: ${ventaVerificada?.numero}');
    debugPrint('TIPO: ${ventaVerificada?.tipoDocumento}');
    debugPrint('DNI: ${ventaVerificada?.dni}');
    debugPrint('RUC: ${ventaVerificada?.ruc}');
    debugPrint('NOMBRE: ${ventaVerificada?.nombreCliente}');
    debugPrint('RAZON SOCIAL: ${ventaVerificada?.razonSocial}');
    debugPrint('DIRECCION: ${ventaVerificada?.direccionFiscal}');

    // ==========================================================
    // REGISTRAR VENTA EN EL SERVICIO
    // ==========================================================

    ventasService.registrarVenta(venta);

    // ==========================================================
    // DESCONTAR INVENTARIO
    // ==========================================================

    await inventarioAutomaticoService.descontarInventario(venta);

    // ==========================================================
    // GENERAR TICKET
    // ==========================================================

    final ticket = ticketPrintService.generarTicket(venta);

    // ==========================================================
    // CONVERTIR A ESC/POS
    // ==========================================================

    final bytes = await escPosRenderer.render(ticket);

    // ==========================================================
    // IMPRIMIR
    // ==========================================================

    await printerService.print(bytes);

    // ==========================================================
    // LIMPIAR VENTA
    // ==========================================================

    ventaService.nuevaVenta();
    carritoService.vaciarCarrito();
  }
}




