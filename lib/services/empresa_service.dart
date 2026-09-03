import '../database/app_database.dart';
import '../models/empresa_model.dart';
import '../repositories/empresa_repository.dart';

class EmpresaService {
  final EmpresaRepository _repository;

  EmpresaService(AppDatabase database)
    : _repository = EmpresaRepository(database);

  /// Obtiene la empresa.
  /// Si no existe, crea automáticamente la configuración inicial.
  Future<EmpresaModel> obtenerEmpresa() async {
    final empresa = await _repository.obtener();
    if (empresa != null) {
      print("===== EMPRESA EN BD =====");
      print(empresa.nombre);
      print(empresa.ruc);
      print(empresa.direccion);
      print(empresa.telefono);
      print(empresa.instagram);
    }

    if (empresa != null) {
      return empresa;
    }

    final empresaInicial = const EmpresaModel(
      id: 1,

      nombre: 'CAFETERÍA ESTACIÓN AZUL',

      ruc: '10446152080',

      direccion: 'Av. Nicolás Ayllón 582, Ate',

      telefono: '',

      instagram: '@cafeteriaestacionazul',

      logo: '',

      tipoContribuyente: 'RUC10',

      serieBoleta: 'B001',
      serieFactura: 'F001',

      correlativoBoleta: 1,
      correlativoFactura: 1,

      igv: 18,

      moneda: 'PEN',

      impresora: '',
    );

    await _repository.guardar(empresaInicial);

    return empresaInicial;
  }

  Future<void> guardar(EmpresaModel empresa) {
    return _repository.guardar(empresa);
  }

  Future<void> actualizar(EmpresaModel empresa) async {
    await _repository.actualizar(empresa);
  }
}
