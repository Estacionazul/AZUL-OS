import 'producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
  });

  double get subtotal => producto.precio * cantidad;
}