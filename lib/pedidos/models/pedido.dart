import 'estado_pedido.dart';
import 'ubicacion_pedido.dart';

class Pedido {
  final String id;
  final UbicacionPedido ubicacion;
  final DateTime fechaCreacion;

  EstadoPedido estado;

  int numeroComanda;

  Pedido({
    required this.id,
    required this.ubicacion,
    required this.fechaCreacion,
    this.estado = EstadoPedido.abierto,
    this.numeroComanda = 0,
  });

  bool get estaAbierto =>
      estado != EstadoPedido.cerrado;

  bool get puedeAgregarProductos =>
      estado == EstadoPedido.abierto ||
      estado == EstadoPedido.enviado;

  bool get esperandoCuenta =>
      estado == EstadoPedido.esperandoCuenta;
}
