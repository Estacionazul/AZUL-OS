import 'package:flutter/foundation.dart';

import '../models/producto_model.dart';
import '../repositories/producto_repository.dart';

class ProductoService extends ChangeNotifier {
  final ProductoRepository _repository;

  ProductoService(this._repository);

  List<ProductoModel> _productos = [];
  List<ProductoModel> _productosFiltrados = [];

  List<ProductoModel> get productos =>
      List.unmodifiable(_productosFiltrados);

  List<ProductoModel> get todosProductos =>
      List.unmodifiable(_productos);

  Future<void> cargarProductos() async {
    _productos = await _repository.obtenerTodos();
    _productosFiltrados = List.from(_productos);

    notifyListeners();
  }

  Future<void> agregarProducto(
      ProductoModel producto,
      ) async {
    await _repository.insertar(producto);
    await cargarProductos();
  }

  Future<void> editarProducto(
      ProductoModel producto,
      ) async {
    await _repository.actualizar(producto);
    await cargarProductos();
  }

  Future<void> eliminarProducto(
      int id,
      ) async {
    await _repository.eliminar(id);
    await cargarProductos();
  }

  ProductoModel? obtenerProducto(int id) {
    try {
      return _productos.firstWhere(
            (p) => p.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  /// BUSCAR PRODUCTOS
  void buscarProductos(String texto) {
    // Si el buscador está vacío
    if (texto.trim().isEmpty) {
      _productosFiltrados = List.from(_productos);
    } else {
      final busqueda = texto.toLowerCase();

      _productosFiltrados = _productos.where((producto) {
        return producto.nombre.toLowerCase().contains(busqueda) ||
            producto.codigo.toLowerCase().contains(busqueda);
      }).toList();
    }

    notifyListeners();
  }

  int get cantidadProductos => _productos.length;

  Future<bool> aumentarStock(
      int productoId,
      double cantidad,
      ) async {

    final producto = obtenerProducto(productoId);

    if (producto == null) {
      return false;
    }

    final actualizado = ProductoModel(
      id: producto.id,
      codigo: producto.codigo,
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      categoriaId: producto.categoriaId,
      costo: producto.costo,
      precioVenta: producto.precioVenta,
      stock: producto.stock + cantidad.toInt(),
      stockMinimo: producto.stockMinimo,
      tipoInventario: producto.tipoInventario,
      emoji: producto.emoji,
      imagen: producto.imagen,
      activo: producto.activo,
    );

    await editarProducto(actualizado);

    return true;
  }
}