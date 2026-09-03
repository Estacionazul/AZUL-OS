import 'package:flutter/foundation.dart';

import '../models/item_carrito.dart';
import '../models/producto_model.dart';

class CarritoService extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  // ==========================================================
  // AGREGAR PRODUCTO
  // ==========================================================

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

    debugPrint('Items en carrito: ${_items.length}');

    for (final item in _items) {
      debugPrint('${item.producto.nombre} - Cantidad: ${item.cantidad}');
    }

    notifyListeners();
  }

  // ==========================================================
  // CARGAR PRODUCTOS DESDE UN PEDIDO
  // ==========================================================

  /// Reemplaza el contenido actual del carrito con una copia
  /// de los productos recibidos.
  ///
  /// Se utiliza principalmente para llevar un PedidoAbierto
  /// al flujo normal de cobro.
  void cargarItems(List<ItemCarrito> items) {
    _items
      ..clear()
      ..addAll(
        items.map(
          (item) => ItemCarrito(
            producto: item.producto,
            cantidad: item.cantidad,
            tamano: item.tamano,
            tipoLeche: item.tipoLeche,
            endulzante: item.endulzante,
            infusion: item.infusion,
            observaciones: item.observaciones,
            extraShot: item.extraShot,
          ),
        ),
      );

    debugPrint('========== CARRITO CARGADO DESDE PEDIDO ==========');

    for (final item in _items) {
      debugPrint('${item.producto.nombre} - Cantidad: ${item.cantidad}');
    }

    notifyListeners();
  }

  // ==========================================================
  // AUMENTAR CANTIDAD
  // ==========================================================

  void aumentarCantidad(ItemCarrito item) {
    item.cantidad++;
    notifyListeners();
  }

  // ==========================================================
  // DISMINUIR CANTIDAD
  // ==========================================================

  void disminuirCantidad(ItemCarrito item) {
    if (item.cantidad > 1) {
      item.cantidad--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
  }

  // ==========================================================
  // ELIMINAR PRODUCTO
  // ==========================================================

  void eliminarProducto(ItemCarrito item) {
    _items.remove(item);
    notifyListeners();
  }

  // ==========================================================
  // VACIAR CARRITO
  // ==========================================================

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // ==========================================================
  // TOTAL
  // ==========================================================

  double get total {
    double suma = 0;

    for (final item in _items) {
      suma += item.subtotal;
    }

    return suma;
  }
}
