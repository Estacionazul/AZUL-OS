import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/empresa_table.dart';

part 'empresa_dao.g.dart';

@DriftAccessor(tables: [Empresa])
class EmpresaDao extends DatabaseAccessor<AppDatabase> with _$EmpresaDaoMixin {
  EmpresaDao(super.db);

  /// Obtiene la configuración de la empresa.
  Future<EmpresaData?> obtenerEmpresa() {
    return select(empresa).getSingleOrNull();
  }

  /// Inserta o reemplaza la configuración.
  Future<void> guardarEmpresa(EmpresaCompanion datos) async {
    await into(empresa).insertOnConflictUpdate(datos);
  }

  /// Actualiza la configuración existente.
  Future<bool> actualizarEmpresa(EmpresaCompanion datos) {
    return update(empresa).replace(datos);
  }
}
