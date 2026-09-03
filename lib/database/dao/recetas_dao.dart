import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recetas_table.dart';

part 'recetas_dao.g.dart';

@DriftAccessor(tables: [Recetas])
class RecetasDao extends DatabaseAccessor<AppDatabase> with _$RecetasDaoMixin {
  RecetasDao(AppDatabase db) : super(db);

  Future<List<Receta>> obtenerTodas() {
    return select(recetas).get();
  }

  Future<Receta?> obtenerPorProducto(int productoId) {
    return (select(
      recetas,
    )..where((t) => t.productoId.equals(productoId))).getSingleOrNull();
  }

  Future<int> insertar(RecetasCompanion receta) {
    return into(recetas).insert(receta);
  }

  Future<bool> actualizar(Receta receta) {
    return update(recetas).replace(receta);
  }

  Future<int> eliminar(int id) {
    return (delete(recetas)..where((t) => t.id.equals(id))).go();
  }
}
