import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/insumos_table.dart';

part 'insumos_dao.g.dart';

@DriftAccessor(tables: [Insumos])
class InsumosDao extends DatabaseAccessor<AppDatabase> with _$InsumosDaoMixin {
  InsumosDao(AppDatabase db) : super(db);

  Future<List<Insumo>> obtenerTodos() {
    return select(insumos).get();
  }

  /// NUEVO
  Future<Insumo?> obtenerPorId(int id) {
    return (select(insumos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar(InsumosCompanion insumo) {
    return into(insumos).insert(insumo);
  }

  Future<bool> actualizar(Insumo insumo) {
    return update(insumos).replace(insumo);
  }

  /// Actualizar solamente el stock
  Future<bool> actualizarStock(int id, double stock) {
    return (update(insumos)..where((t) => t.id.equals(id)))
        .write(InsumosCompanion(stock: Value(stock)))
        .then((cantidad) => cantidad > 0);
  }

  Future<int> eliminar(int id) {
    return (delete(insumos)..where((t) => t.id.equals(id))).go();
  }
}
