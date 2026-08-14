class Ticket {
  final TicketEmpresa empresa;
  final TicketHeader header;
  final TicketCliente cliente;
  final List<TicketItem> items;
  final TicketTotals totals;
  final TicketFooter footer;

  const Ticket({
    required this.empresa,
    required this.header,
    required this.cliente,
    required this.items,
    required this.totals,
    required this.footer,
  });
}

class TicketEmpresa {
  final String nombre;
  final String eslogan;
  final String instagram;

  const TicketEmpresa({
    required this.nombre,
    required this.eslogan,
    required this.instagram,
  });
}

class TicketHeader {
  final String numero;
  final DateTime fecha;

  const TicketHeader({
    required this.numero,
    required this.fecha,
  });
}

class TicketItem {
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final List<String> opciones;

  const TicketItem({
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    this.opciones = const [],
  });

  double get total => cantidad * precioUnitario;
}

class TicketTotals {
  final double subtotal;
  final double igv;
  final double total;
  final String metodoPago;

  const TicketTotals({
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.metodoPago,
  });
}

class TicketFooter {
  final String mensaje;
  final String frase;

  const TicketFooter({
    required this.mensaje,
    required this.frase,
  });
}

class TicketCliente {
  final String tipoDocumento;

  final String? cliente;

  final String? dni;

  final String? ruc;

  final String? razonSocial;

  final String? direccionFiscal;

  const TicketCliente({
    required this.tipoDocumento,
    this.cliente,
    this.dni,
    this.ruc,
    this.razonSocial,
    this.direccionFiscal,
  });
}