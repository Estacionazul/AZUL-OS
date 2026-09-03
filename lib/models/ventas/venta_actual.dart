class VentaActual {
  //==========================
  // CLIENTE
  //==========================

  String? clienteId;
  String? clienteNombre;
  String? clienteTelefono;

  // NUEVO
  String? dni;
  String? ruc;
  String? razonSocial;
  String? direccionFiscal;

  //==========================
  // DOCUMENTO
  //==========================

  String tipoDocumento = "Nota de Venta";

  //==========================
  // PAGOS
  //==========================

  double efectivo = 0;
  double yape = 0;
  double plin = 0;
  double tarjeta = 0;

  //==========================
  // DESCUENTOS
  //==========================

  double descuento = 0;

  //==========================
  // PROMOCIONES
  //==========================

  String? promocionAplicada;

  //==========================
  // OBSERVACIONES
  //==========================

  String observaciones = "";

  //==========================
  // TOTALES
  //==========================

  double subtotal = 0;
  double igv = 0;
  double total = 0;

  //==========================
  // CAJA
  //==========================

  DateTime fecha = DateTime.now();

  bool ventaFinalizada = false;
}
