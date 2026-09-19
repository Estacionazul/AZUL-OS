import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/productos_table.dart';

part 'productos_dao.g.dart';

@DriftAccessor(tables: [Productos])
class ProductosDao extends DatabaseAccessor<AppDatabase>
    with _$ProductosDaoMixin {
  ProductosDao(AppDatabase db) : super(db);

  /// Obtener todos los productos activos.
  Future<List<Producto>> obtenerTodos() {
    return (select(productos)
      ..where((t) => t.activo.equals(true))
      ..orderBy([
            (t) => OrderingTerm(expression: t.nombre),
      ]))
        .get();
  }

  /// Obtener un producto por ID, activo o inactivo.
  Future<Producto?> obtenerPorId(int id) {
    return (select(productos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Buscar producto por código incluyendo productos inactivos.
  Future<Producto?> obtenerPorCodigo(String codigo) {
    final codigoNormalizado = codigo.trim();

    return (select(productos)
      ..where((t) => t.codigo.equals(codigoNormalizado)))
        .getSingleOrNull();
  }

  /// Insertar producto.
  Future<int> insertar(ProductosCompanion producto) {
    return into(productos).insert(producto);
  }

  /// Actualizar producto.
  Future<bool> actualizar(Producto producto) {
    return update(productos).replace(producto);
  }

  /// Actualizar solamente el stock.
  Future<bool> actualizarStock(int id, int stock) {
    return (update(productos)..where((t) => t.id.equals(id)))
        .write(ProductosCompanion(stock: Value(stock)))
        .then((cantidad) => cantidad > 0);
  }

  /// Desactivar producto sin borrar su histórico.
  Future<int> eliminar(int id) {
    return (update(productos)..where((t) => t.id.equals(id))).write(
      const ProductosCompanion(
        activo: Value(false),
      ),
    );
  }
}