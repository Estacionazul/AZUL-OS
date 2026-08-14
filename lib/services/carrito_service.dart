import '../models/item_carrito.dart';
import '../models/producto_model.dart';

import 'package:flutter/foundation.dart';

class CarritoService extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  void agregarProducto(
      ProductoModel producto, {
        String? tamano,
        String? tipoLeche,
        String? endulzante,
        String? infusion,
        String? observaciones,
        bool extraShot = false,
      }) {
    final index = _items.indexWhere(
          (item) =>
      item.producto.codigo == producto.codigo &&
          item.tamano == tamano &&
          item.tipoLeche == tipoLeche &&
          item.endulzante == endulzante &&
          item.infusion == infusion &&
          item.observaciones == observaciones &&
          item.extraShot == extraShot,
    );

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(
        ItemCarrito(
          producto: producto,
          tamano: tamano,
          tipoLeche: tipoLeche,
          endulzante: endulzante,
          infusion: infusion,
          observaciones: observaciones,
          extraShot: extraShot,
        ),
      );
    }
    debugPrint("Items en carrito: ${_items.length}");

    for (final item in _items) {
      debugPrint("${item.producto.nombre} - Cantidad: ${item.cantidad}");
    }
    notifyListeners();
  }

  void aumentarCantidad(ItemCarrito item) {
    item.cantidad++;
    notifyListeners();
  }

  void disminuirCantidad(ItemCarrito item) {
    if (item.cantidad > 1) {
      item.cantidad--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
  }

  void eliminarProducto(ItemCarrito item) {
    _items.remove(item);
    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }

  double get total {
    double suma = 0;

    for (final item in _items) {
      suma += item.subtotal;
    }

    return suma;
  }
}