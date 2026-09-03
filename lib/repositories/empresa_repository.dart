import '../database/app_database.dart';
import '../database/dao/empresa_dao.dart';
import '../mappers/empresa_mapper.dart';
import '../models/empresa_model.dart';

class EmpresaRepository {
  final EmpresaDao _dao;

  EmpresaRepository(AppDatabase database) : _dao = EmpresaDao(database);

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
    return _dao.guardarEmpresa(EmpresaMapper.toCompanion(empresa));
  }

  /// Actualiza la configuración.
  Future<bool> actualizar(EmpresaModel empresa) {
    return _dao.actualizarEmpresa(EmpresaMapper.toCompanion(empresa));
  }

  // ==========================================================
  // SIGUIENTE NÚMERO DE BOLETA
  // ==========================================================

  Future<String> obtenerSiguienteNumeroBoleta() async {
    final empresa = await obtener();

    if (empresa == null) {
      throw StateError('No existe la configuración de la empresa.');
    }

    final numero = empresa.correlativoBoleta;

    return '${empresa.serieBoleta}-${numero.toString().padLeft(8, '0')}';
  }

  // ==========================================================
  // SIGUIENTE NÚMERO DE FACTURA
  // ==========================================================

  Future<String> obtenerSiguienteNumeroFactura() async {
    final empresa = await obtener();

    if (empresa == null) {
      throw StateError('No existe la configuración de la empresa.');
    }

    final numero = empresa.correlativoFactura;

    return '${empresa.serieFactura}-${numero.toString().padLeft(8, '0')}';
  }

  // ==========================================================
  // INCREMENTAR CORRELATIVO DE BOLETA
  // ==========================================================

  Future<void> incrementarCorrelativoBoleta() async {
    final empresa = await obtener();

    if (empresa == null) {
      throw StateError('No existe la configuración de la empresa.');
    }

    final actualizada = EmpresaModel(
      id: empresa.id,
      nombre: empresa.nombre,
      ruc: empresa.ruc,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      instagram: empresa.instagram,
      logo: empresa.logo,
      serieBoleta: empresa.serieBoleta,
      serieFactura: empresa.serieFactura,
      correlativoBoleta: empresa.correlativoBoleta + 1,
      correlativoFactura: empresa.correlativoFactura,
      igv: empresa.igv,
      moneda: empresa.moneda,
      tipoContribuyente: empresa.tipoContribuyente,
      impresora: empresa.impresora,
    );

    final actualizado = await actualizar(actualizada);

    if (!actualizado) {
      throw StateError('No se pudo actualizar el correlativo de Boleta.');
    }
  }

  // ==========================================================
  // INCREMENTAR CORRELATIVO DE FACTURA
  // ==========================================================

  Future<void> incrementarCorrelativoFactura() async {
    final empresa = await obtener();

    if (empresa == null) {
      throw StateError('No existe la configuración de la empresa.');
    }

    final actualizada = EmpresaModel(
      id: empresa.id,
      nombre: empresa.nombre,
      ruc: empresa.ruc,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      instagram: empresa.instagram,
      logo: empresa.logo,
      serieBoleta: empresa.serieBoleta,
      serieFactura: empresa.serieFactura,
      correlativoBoleta: empresa.correlativoBoleta,
      correlativoFactura: empresa.correlativoFactura + 1,
      igv: empresa.igv,
      moneda: empresa.moneda,
      tipoContribuyente: empresa.tipoContribuyente,
      impresora: empresa.impresora,
    );

    final actualizado = await actualizar(actualizada);

    if (!actualizado) {
      throw StateError('No se pudo actualizar el correlativo de Factura.');
    }
  }
}
