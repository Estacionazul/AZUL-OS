import '../models/item_carrito.dart';
import '../models/ticket.dart';
import '../models/venta.dart';

class TicketPrintService {
  const TicketPrintService();

  // Información temporal del negocio.
  // Más adelante estos datos vendrán de la configuración del sistema.
  static const String _nombreNegocio = 'ESTACIÓN AZUL';
  static const String _eslogan = 'Café • Snacks • Servicios';
  static const String _instagram = '@cafeteria_estacionazul';

  static const String _mensaje =
      'Gracias por su visita. Esperamos verlo pronto!';

  static const String _frase =
      'Cada taza cuenta una historia, gracias por ser parte de la nuestra.';

  Ticket generarTicket(Venta venta) {
    return Ticket(
      empresa: _crearEmpresa(),
      header: _crearHeader(venta),
      cliente: _crearCliente(venta),
      items: _crearItems(venta.items),
      totals: _crearTotales(venta),
      footer: _crearFooter(),
    );
  }

  TicketEmpresa _crearEmpresa() {
    return const TicketEmpresa(
      nombre: _nombreNegocio,
      eslogan: _eslogan,
      instagram: _instagram,
    );
  }

  TicketHeader _crearHeader(Venta venta) {
    return TicketHeader(
      numero: venta.numero,
      fecha: venta.fecha,
    );
  }

  TicketCliente _crearCliente(Venta venta) {
    return TicketCliente(
      tipoDocumento: venta.tipoDocumento,
      cliente: venta.nombreCliente,
      dni: venta.dni,
      ruc: venta.ruc,
      razonSocial: venta.razonSocial,
      direccionFiscal: venta.direccionFiscal,
    );
  }

  List<TicketItem> _crearItems(List<ItemCarrito> items) {
    return items.map(_crearItem).toList();
  }

  TicketItem _crearItem(ItemCarrito item) {
    final opciones = <String>[];

    if (item.tamano != null && item.tamano!.isNotEmpty) {
      opciones.add('Tamaño: ${item.tamano}');
    }

    if (item.tipoLeche != null && item.tipoLeche!.isNotEmpty) {
      opciones.add('Leche: ${item.tipoLeche}');
    }

    if (item.endulzante != null && item.endulzante!.isNotEmpty) {
      opciones.add('Endulzante: ${item.endulzante}');
    }

    if (item.infusion != null && item.infusion!.isNotEmpty) {
      opciones.add('Infusión: ${item.infusion}');
    }

    if (item.extraShot) {
      opciones.add('Extra Shot');
    }

    if (item.observaciones != null &&
        item.observaciones!.trim().isNotEmpty) {
      opciones.add('Observación: ${item.observaciones}');
    }

    return TicketItem(
      nombre: item.producto.nombre,
      cantidad: item.cantidad,
      precioUnitario: item.precioUnitario,
      opciones: opciones,
    );
  }

  TicketTotals _crearTotales(Venta venta) {
    return TicketTotals(
      subtotal: venta.subtotal,
      igv: venta.igv,
      total: venta.total,
      metodoPago: venta.metodoPago,
    );
  }

  TicketFooter _crearFooter() {
    return const TicketFooter(
      mensaje: _mensaje,
      frase: _frase,
    );
  }
}