import 'package:flutter/foundation.dart';

import '../models/producto_model.dart';
import '../repositories/producto_repository.dart';

class ProductoService extends ChangeNotifier {
  final ProductoRepository _repository;

  ProductoService(this._repository);

  List<ProductoModel> _productos = [];
  List<ProductoModel> _productosFiltrados = [];

  String _textoBusqueda = '';
  int? _categoriaSeleccionadaId;

  List<ProductoModel> get productos => List.unmodifiable(_productosFiltrados);

  List<ProductoModel> get todosProductos => List.unmodifiable(_productos);

  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;

  String get textoBusqueda => _textoBusqueda;

  Future<void> cargarProductos() async {
    _productos = await _repository.obtenerTodos();

    _aplicarFiltros();

    notifyListeners();
  }

  Future<void> agregarProducto(ProductoModel producto) async {
    final codigo = producto.codigo.trim();

    if (codigo.isEmpty) {
      throw Exception('El código del producto es obligatorio.');
    }

    final existe = _productos.any(
          (item) => item.codigo.trim().toLowerCase() == codigo.toLowerCase(),
    );

    if (existe) {
      throw Exception(
        'El código "$codigo" ya existe. Usa un código diferente.',
      );
    }

    final productoGuardar = ProductoModel(
      id: null,
      codigo: codigo,
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      categoriaId: producto.categoriaId,
      costo: producto.costo,
      precioVenta: producto.precioVenta,
      stock: producto.stock,
      stockMinimo: producto.stockMinimo,
      tipoInventario: producto.tipoInventario,
      tipoAfectacionIgv: producto.tipoAfectacionIgv,
      emoji: producto.emoji,
      imagen: producto.imagen,
      activo: producto.activo,
    );

    await _repository.insertar(productoGuardar);

    await cargarProductos();
  }

  Future<void> editarProducto(ProductoModel producto) async {
    final codigo = producto.codigo.trim();

    if (codigo.isEmpty) {
      throw Exception('El código del producto es obligatorio.');
    }

    final idActual = producto.id;

    final existeOtro = _productos.any(
          (item) =>
      item.id != idActual &&
          item.codigo.trim().toLowerCase() == codigo.toLowerCase(),
    );

    if (existeOtro) {
      throw Exception(
        'El código "$codigo" ya pertenece a otro producto.',
      );
    }

    final productoActualizar = ProductoModel(
      id: producto.id,
      codigo: codigo,
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      categoriaId: producto.categoriaId,
      costo: producto.costo,
      precioVenta: producto.precioVenta,
      stock: producto.stock,
      stockMinimo: producto.stockMinimo,
      tipoInventario: producto.tipoInventario,
      tipoAfectacionIgv: producto.tipoAfectacionIgv,
      emoji: producto.emoji,
      imagen: producto.imagen,
      activo: producto.activo,
    );

    await _repository.actualizar(productoActualizar);

    await cargarProductos();
  }

  Future<void> eliminarProducto(int id) async {
    await _repository.eliminar(id);
    await cargarProductos();
  }

  ProductoModel? obtenerProducto(int id) {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // BUSCAR PRODUCTOS
  // ==========================================================

  void buscarProductos(String texto) {
    _textoBusqueda = texto.trim().toLowerCase();

    _aplicarFiltros();

    notifyListeners();
  }

  // ==========================================================
  // FILTRAR POR CATEGORÍA
  // ==========================================================

  void seleccionarCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;

    _aplicarFiltros();

    notifyListeners();
  }

  // ==========================================================
  // LIMPIAR FILTROS
  // ==========================================================

  void limpiarFiltros() {
    _textoBusqueda = '';
    _categoriaSeleccionadaId = null;

    _aplicarFiltros();

    notifyListeners();
  }

  // ==========================================================
  // APLICAR BÚSQUEDA + CATEGORÍA
  // ==========================================================

  void _aplicarFiltros() {
    Iterable<ProductoModel> resultado = _productos;

    if (_categoriaSeleccionadaId != null) {
      resultado = resultado.where(
            (producto) => producto.categoriaId == _categoriaSeleccionadaId,
      );
    }

    if (_textoBusqueda.isNotEmpty) {
      resultado = resultado.where((producto) {
        final nombre = producto.nombre.toLowerCase();
        final codigo = producto.codigo.toLowerCase();
        final codigoBarras = producto.codigoBarras.toLowerCase();

        return nombre.contains(_textoBusqueda) ||
            codigo.contains(_textoBusqueda) ||
            codigoBarras.contains(_textoBusqueda);
      });
    }

    _productosFiltrados = resultado.toList();
  }

  int get cantidadProductos => _productos.length;

  Future<bool> aumentarStock(int productoId, double cantidad) async {
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
      tipoAfectacionIgv: producto.tipoAfectacionIgv,
      emoji: producto.emoji,
      imagen: producto.imagen,
      activo: producto.activo,
    );

    await editarProducto(actualizado);

    return true;
  }
}