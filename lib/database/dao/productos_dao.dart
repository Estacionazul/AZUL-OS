import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/productos_table.dart';

part 'productos_dao.g.dart';

@DriftAccessor(
  tables: [
    Productos,
  ],
)
class ProductosDao extends DatabaseAccessor<AppDatabase>
    with _$ProductosDaoMixin {
  ProductosDao(AppDatabase db) : super(db);

  /// Obtener todos
  Future<List<Producto>> obtenerTodos() {
    return select(productos).get();
  }

  /// Obtener por ID
  Future<Producto?> obtenerPorId(int id) {
    return (select(productos)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insertar
  Future<int> insertar(ProductosCompanion producto) {
    return into(productos).insert(producto);
  }

  /// Actualizar
  Future<bool> actualizar(Producto producto) {
    return update(productos).replace(producto);
  }

/// Actualizar solamente el stock
Future<bool> actualizarStock(int id, int stock) {
return (update(productos)
..where((t) => t.id.equals(id)))
.write(
ProductosCompanion(
stock: Value(stock),
),
)
.then((cantidad) => cantidad > 0);
}

/// Eliminar
Future<int> eliminar(int id) {
return (delete(productos)
..where((t) => t.id.equals(id)))
.go();
}
}