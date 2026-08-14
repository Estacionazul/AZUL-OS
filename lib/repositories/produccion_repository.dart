import '../database/app_database.dart';
import '../database/dao/movimientos_inventario_dao.dart';
import '../mappers/movimiento_inventario_mapper.dart';
import '../models/movimiento_inventario_model.dart';

class ProduccionRepository {
  final MovimientosInventarioDao _dao;

  ProduccionRepository(AppDatabase database)
      : _dao = MovimientosInventarioDao(database);

  Future<int> registrarMovimiento(
      MovimientoInventarioModel movimiento,
      ) {
    return _dao.insertar(
      MovimientoInventarioMapper.toCompanion(
        movimiento,
      ),
    );
  }
}