import '../models/ventas/venta_actual.dart';

class VentaService {
  VentaService._();

  static final VentaService instance = VentaService._();

  VentaActual venta = VentaActual();

  void nuevaVenta() {
    venta = VentaActual();
  }

  //==========================
  // TOTALES
  //==========================

  void actualizarTotales({
    required double subtotal,
    required double igv,
    required double total,
  }) {
    venta.subtotal = subtotal;
    venta.igv = igv;
    venta.total = total;
  }

  //==========================
  // CLIENTE
  //==========================

  void seleccionarCliente({
    required String id,
    required String nombre,
    required String telefono,
  }) {
    venta.clienteId = id;
    venta.clienteNombre = nombre;
    venta.clienteTelefono = telefono;
  }

  void actualizarDatosCliente({
    String? nombreCliente,
    String? dni,
    String? ruc,
    String? razonSocial,
    String? direccionFiscal,
  }) {
    venta.clienteNombre = nombreCliente;
    venta.dni = dni;
    venta.ruc = ruc;
    venta.razonSocial = razonSocial;
    venta.direccionFiscal = direccionFiscal;
  }

  //==========================
  // DOCUMENTO
  //==========================

  void cambiarDocumento(String tipo) {
    venta.tipoDocumento = tipo;
  }

  //==========================
  // DESCUENTO
  //==========================

  void aplicarDescuento(double monto) {
    venta.descuento = monto;
  }

  //==========================
  // PROMOCIÓN
  //==========================

  void aplicarPromocion(String nombre) {
    venta.promocionAplicada = nombre;
  }

  //==========================
  // OBSERVACIONES
  //==========================

  void actualizarObservaciones(String texto) {
    venta.observaciones = texto;
  }

  //==========================
  // PAGOS
  //==========================

  void registrarPago({
    double efectivo = 0,
    double yape = 0,
    double plin = 0,
    double tarjeta = 0,
  }) {
    venta.efectivo = efectivo;
    venta.yape = yape;
    venta.plin = plin;
    venta.tarjeta = tarjeta;
  }
}