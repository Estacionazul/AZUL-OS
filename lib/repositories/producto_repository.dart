import '../database/app_database.dart';
import '../database/dao/productos_dao.dart';
import '../mappers/producto_mapper.dart';
import '../models/producto_model.dart';

class ProductoRepository {
  final ProductosDao _dao;

  ProductoRepository(AppDatabase database)
      : _dao = ProductosDao(database);

  /// Obtener todos los productos
  Future<List<ProductoModel>> obtenerTodos() async {
    final productos = await _dao.obtenerTodos();

    return productos
        .map(ProductoMapper.toModel)
        .toList();
  }

  /// Obtener un producto por ID
  Future<ProductoModel?> obtenerPorId(int id) async {
    final producto = await _dao.obtenerPorId(id);

    if (producto == null) return null;

    return ProductoMapper.toModel(producto);
  }

  /// Insertar producto
  Future<int> insertar(ProductoModel producto) {
    return _dao.insertar(
      ProductoMapper.toCompanion(producto),
    );
  }

  /// Actualizar producto
  Future<bool> actualizar(ProductoModel producto) {
    return _dao.actualizar(
        Producto(
          id: producto.id!,
          codigo: producto.codigo,
          codigoBarras: producto.codigoBarras.isEmpty
              ? null
              : producto.codigoBarras,
          nombre: producto.nombre,
          descripcion: producto.descripcion,
          categoriaId: producto.categoriaId,
          costo: producto.costo,
          precioVenta: producto.precioVenta,
          stock: producto.stock,
          stockMinimo: producto.stockMinimo,
          tipoInventario: producto.tipoInventario,
          emoji: producto.emoji,
          imagen: producto.imagen,
          activo: producto.activo,
          fechaCreacion: DateTime.now(),
        )
    );
  }

  /// Actualizar solamente el stock
  Future<bool> actualizarStock(int id, int stock) {
    return _dao.actualizarStock(id, stock);
  }

  /// Eliminar
  Future<int> eliminar(int id) {
    return _dao.eliminar(id);
  }
}