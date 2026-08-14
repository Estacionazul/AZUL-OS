import '../database/app_database.dart';
import '../database/dao/empresa_dao.dart';
import '../mappers/empresa_mapper.dart';
import '../models/empresa_model.dart';

class EmpresaRepository {
  final EmpresaDao _dao;

  EmpresaRepository(AppDatabase database)
      : _dao = EmpresaDao(database);

  /// Obtiene la configuración del negocio.
  Future<EmpresaModel?> obtener() async {
    final empresa = await _dao.obtenerEmpresa();

    if (empresa == null) {
      return null;
    }

    return EmpresaMapper.toModel(empresa);
  }

  /// Guarda una nueva configuración.
  Future<void> guardar(EmpresaModel empresa) {
    return _dao.guardarEmpresa(
      EmpresaMapper.toCompanion(empresa),
    );
  }

  /// Actualiza la configuración.
  Future<bool> actualizar(EmpresaModel empresa) {
    return _dao.actualizarEmpresa(
      EmpresaMapper.toCompanion(empresa),
    );
  }
}