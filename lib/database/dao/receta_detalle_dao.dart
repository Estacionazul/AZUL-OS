import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/receta_detalle_table.dart';

part 'receta_detalle_dao.g.dart';

@DriftAccessor(tables: [RecetaDetalle])
class RecetaDetalleDao extends DatabaseAccessor<AppDatabase>
    with _$RecetaDetalleDaoMixin {
  RecetaDetalleDao(AppDatabase db) : super(db);

  /// Obtiene todos los ingredientes
  Future<List<RecetaDetalleData>> obtenerTodos() {
    return select(recetaDetalle).get();
  }

  /// Obtiene únicamente los ingredientes de una receta
  Future<List<RecetaDetalleData>> obtenerPorReceta(int recetaId) {
    return (select(recetaDetalle)
          ..where((t) => t.recetaId.equals(recetaId))
          ..orderBy([(t) => OrderingTerm.asc(t.orden)]))
        .get();
  }

  /// Inserta un ingrediente
  Future<int> insertar(RecetaDetalleCompanion detalle) {
    return into(recetaDetalle).insert(detalle);
  }

  /// Actualiza un ingrediente
  Future<bool> actualizar(RecetaDetalleData detalle) {
    return update(recetaDetalle).replace(detalle);
  }

  /// Elimina un ingrediente
  Future<int> eliminar(int id) {
    return (delete(recetaDetalle)..where((t) => t.id.equals(id))).go();
  }

  /// Elimina todos los ingredientes de una receta
  Future<int> eliminarPorReceta(int recetaId) {
    return (delete(
      recetaDetalle,
    )..where((t) => t.recetaId.equals(recetaId))).go();
  }
}
