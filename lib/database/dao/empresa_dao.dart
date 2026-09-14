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

  Future<String> reservarNumeroBoleta() async {
    return transaction(() async {
      final empresaActual = await obtenerEmpresa();

      if (empresaActual == null) {
        throw StateError(
          'No existe la configuración de la empresa.',
        );
      }

      final numeroReservado = empresaActual.correlativoBoleta;

      final actualizado = await (update(empresa)
        ..where((e) => e.id.equals(empresaActual.id)))
          .write(
        EmpresaCompanion(
          correlativoBoleta: Value(numeroReservado + 1),
        ),
      );

      if (actualizado != 1) {
        throw StateError(
          'No se pudo reservar el correlativo de boleta.',
        );
      }

      return '${empresaActual.serieBoleta}-'
          '${numeroReservado.toString().padLeft(8, '0')}';
    });
  }

  Future<String> reservarNumeroFactura() async {
    return transaction(() async {
      final empresaActual = await obtenerEmpresa();

      if (empresaActual == null) {
        throw StateError(
          'No existe la configuración de la empresa.',
        );
      }

      final numeroReservado = empresaActual.correlativoFactura;

      final actualizado = await (update(empresa)
        ..where((e) => e.id.equals(empresaActual.id)))
          .write(
        EmpresaCompanion(
          correlativoFactura: Value(numeroReservado + 1),
        ),
      );

      if (actualizado != 1) {
        throw StateError(
          'No se pudo reservar el correlativo de factura.',
        );
      }

      return '${empresaActual.serieFactura}-'
          '${numeroReservado.toString().padLeft(8, '0')}';
    });
  }
}
