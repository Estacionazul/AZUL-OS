import '../models/item_carrito.dart';
import '../models/producto.dart';

class CarritoService {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  void agregarProducto(Producto producto) {
    final index = _items.indexWhere(
          (item) => item.producto.codigo == producto.codigo,
    );

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(
        ItemCarrito(
          producto: producto,
        ),
      );
    }
  }

  void aumentarCantidad(ItemCarrito item) {
    item.cantidad++;
  }

  void disminuirCantidad(ItemCarrito item) {
    if (item.cantidad > 1) {
      item.cantidad--;
    } else {
      _items.remove(item);
    }
  }

  void eliminarProducto(ItemCarrito item) {
    _items.remove(item);
  }

  void vaciarCarrito() {
    _items.clear();
  }

  double get total {
    double suma = 0;

    for (final item in _items) {
      suma += item.subtotal;
    }

    return suma;
  }
}