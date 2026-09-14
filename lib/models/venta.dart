import 'item_carrito.dart';

class Venta {
  final String numero;

  /// Usuario que realizó la venta.
  /// Null para ventas históricas creadas antes del control por usuario.
  final int? usuarioId;

  final DateTime fecha;

  final List<ItemCarrito> items;

  final double subtotal;

  final double igv;

  final double total;

  final String metodoPago;

  //==========================
  // DOCUMENTO
  //==========================

  final String tipoDocumento;

  //==========================
  // CLIENTE
  //==========================

  final String? dni;

  final String? ruc;

  final String? nombreCliente;

  final String? razonSocial;

  final String? direccionFiscal;

  //==========================
  // OTROS
  //==========================

  final double descuento;

  final String? observaciones;

  Venta({
    required this.numero,
    this.usuarioId,
    required this.fecha,
    required this.items,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.metodoPago,

    this.tipoDocumento = "Nota de Venta",

    this.dni,
    this.ruc,
    this.nombreCliente,
    this.razonSocial,
    this.direccionFiscal,

    this.descuento = 0,

    this.observaciones,
  });
}
