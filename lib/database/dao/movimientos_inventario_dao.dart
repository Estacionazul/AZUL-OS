import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/movimientos_inventario_table.dart';

part 'movimientos_inventario_dao.g.dart';

@DriftAccessor(tables: [MovimientosInventario])
class MovimientosInventarioDao extends DatabaseAccessor<AppDatabase>
    with _$MovimientosInventarioDaoMixin {
  MovimientosInventarioDao(AppDatabase db) : super(db);

  Future<List<MovimientosInventarioData>> obtenerTodos() {
    return select(movimientosInventario).get();
  }

  Future<MovimientosInventarioData?> obtenerPorId(int id) {
    return (select(
      movimientosInventario,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar(MovimientosInventarioCompanion movimiento) {
    return into(movimientosInventario).insert(movimiento);
  }

  Future<bool> actualizar(MovimientosInventarioData movimiento) {
    return update(movimientosInventario).replace(movimiento);
  }

  Future<int> eliminar(int id) {
    return (delete(movimientosInventario)..where((t) => t.id.equals(id))).go();
  }
}
