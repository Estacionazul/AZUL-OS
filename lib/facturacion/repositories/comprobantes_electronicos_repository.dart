import '../../database/app_database.dart';
import '../../database/dao/comprobantes_electronicos_dao.dart';

class ComprobantesElectronicosRepository {
  final ComprobantesElectronicosDao _dao;

  ComprobantesElectronicosRepository(AppDatabase database)
    : _dao = ComprobantesElectronicosDao(database);

  // ==========================================================
  // CREAR COMPROBANTE
  // ==========================================================

  Future<int> crearComprobante(ComprobantesElectronicosCompanion comprobante) {
    return _dao.crearComprobante(comprobante);
  }

  // ==========================================================
  // OBTENER POR ID
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorId(int id) {
    return _dao.obtenerPorId(id);
  }

  // ==========================================================
  // OBTENER POR VENTA
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorVenta(int ventaId) {
    return _dao.obtenerPorVenta(ventaId);
  }

  // ==========================================================
  // OBTENER TODOS
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerTodos() {
    return _dao.obtenerTodos();
  }

  // ==========================================================
  // OBTENER POR TIPO
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorTipo(String tipo) {
    return _dao.obtenerPorTipo(tipo);
  }

  // ==========================================================
  // OBTENER POR SERIE
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorSerie(String serie) {
    return _dao.obtenerPorSerie(serie);
  }

  // ==========================================================
  // OBTENER ÚLTIMO CORRELATIVO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerUltimoPorSerie(String serie) {
    return _dao.obtenerUltimoPorSerie(serie);
  }

  // ==========================================================
  // OBTENER SIGUIENTE CORRELATIVO
  // ==========================================================

  Future<int> obtenerSiguienteNumero(String serie) {
    return _dao.obtenerSiguienteNumero(serie);
  }

  // ==========================================================
  // ACTUALIZAR ESTADO
  // ==========================================================

  Future<bool> actualizarEstado(int id, String estado) {
    return _dao.actualizarEstado(id, estado);
  }

  // ==========================================================
  // ACTUALIZAR RESPUESTA SUNAT
  // ==========================================================

  Future<bool> actualizarRespuestaSunat({
    required int id,
    String? codigoRespuestaSunat,
    String? mensajeRespuestaSunat,
    String? cdr,
    String? xml,
    DateTime? fechaEnvioSunat,
    DateTime? fechaRespuestaSunat,
    String? estado,
  }) {
    return _dao.actualizarRespuestaSunat(
      id: id,
      codigoRespuestaSunat: codigoRespuestaSunat,
      mensajeRespuestaSunat: mensajeRespuestaSunat,
      cdr: cdr,
      xml: xml,
      fechaEnvioSunat: fechaEnvioSunat,
      fechaRespuestaSunat: fechaRespuestaSunat,
      estado: estado,
    );
  }

  // ==========================================================
  // ACTUALIZAR XML
  // ==========================================================

  Future<bool> actualizarXml(int id, String xml) {
    return _dao.actualizarXml(id, xml);
  }

  // ==========================================================
  // ACTUALIZAR CDR
  // ==========================================================

  Future<bool> actualizarCdr(int id, String cdr) {
    return _dao.actualizarCdr(id, cdr);
  }

  // ==========================================================
  // OBTENER COMPROBANTE RELACIONADO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerRelacionado(
    int comprobanteRelacionadoId,
  ) {
    return _dao.obtenerRelacionado(comprobanteRelacionadoId);
  }

  // ==========================================================
  // OBTENER NOTAS DE CRÉDITO RELACIONADAS
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerNotasCreditoRelacionadas(
    int comprobanteId,
  ) {
    return _dao.obtenerNotasCreditoRelacionadas(comprobanteId);
  }

  // ==========================================================
  // BUSCAR POR SERIE Y NÚMERO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorSerieNumero(
    String serie,
    int numero,
  ) {
    return _dao.obtenerPorSerieNumero(serie, numero);
  }
}
