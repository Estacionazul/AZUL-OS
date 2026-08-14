import '../database/app_database.dart';
import '../database/dao/insumos_dao.dart';
import '../mappers/insumo_mapper.dart';
import '../models/insumo_model.dart';

class InsumoRepository {
  final InsumosDao _dao;

  InsumoRepository(AppDatabase database)
      : _dao = InsumosDao(database);

  /// Obtener todos
  Future<List<InsumoModel>> obtenerTodos() async {
    final insumos = await _dao.obtenerTodos();

    return insumos
        .map(InsumoMapper.toModel)
        .toList();
  }

  /// Obtener por ID
  Future<InsumoModel?> obtenerPorId(int id) async {
    final insumo = await _dao.obtenerPorId(id);

    if (insumo == null) return null;

    return InsumoMapper.toModel(insumo);
  }

  /// Insertar
  Future<int> insertar(InsumoModel insumo) {
    return _dao.insertar(
      InsumoMapper.toCompanion(insumo),
    );
  }

  /// Actualizar
  Future<bool> actualizar(InsumoModel insumo) {
    return _dao.actualizar(
      Insumo(
        id: insumo.id!,
        codigo: insumo.codigo,
        nombre: insumo.nombre,
        descripcion: insumo.descripcion,
        categoriaId: insumo.categoriaId,
        unidadMedida: insumo.unidadMedida,
        stock: insumo.stock,
        stockMinimo: insumo.stockMinimo,
        costoCompra: insumo.costoCompra,
        emoji: insumo.emoji,
        imagen: insumo.imagen,
        activo: insumo.activo,
        fechaCreacion: DateTime.now(),
      ),
    );
  }

  /// Eliminar
  Future<int> eliminar(int id) {
    return _dao.eliminar(id);
  }
}