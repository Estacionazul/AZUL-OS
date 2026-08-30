import '../../models/item_carrito.dart';
import 'estado_pedido.dart';
import 'ubicacion_pedido.dart';

class PedidoAbierto {
  final String id;
  final String numero;
  final UbicacionPedido ubicacion;
  final DateTime fechaApertura;

  final List<ItemCarrito> items;

  EstadoPedido estado;

  int numeroComanda;

  String observaciones;

  PedidoAbierto({
    required this.id,
    required this.numero,
    required this.ubicacion,
    required this.fechaApertura,
    List<ItemCarrito>? items,
    this.estado = EstadoPedido.abierto,
    this.numeroComanda = 0,
    this.observaciones = '',
  }) : items = items ?? [];

  double get total {
    return items.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  bool get estaVacio => items.isEmpty;

  int get cantidadItems {
    return items.fold<int>(
      0,
      (total, item) => total + item.cantidad,
    );
  }

  void agregarItems(List<ItemCarrito> nuevosItems) {
    items.addAll(nuevosItems);
  }

  void limpiarItems() {
    items.clear();
  }
}
