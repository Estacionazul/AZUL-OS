import '../../database/app_database.dart';
import '../../database/dao/comprobantes_electronicos_dao.dart';

class ComprobantesRepository {
  final ComprobantesElectronicosDao dao;

  ComprobantesRepository(AppDatabase database)
    : dao = ComprobantesElectronicosDao(database);

  // ==========================================================
  // CREAR COMPROBANTE
  // ==========================================================

  Future<int> crearComprobante(ComprobantesElectronicosCompanion comprobante) {
    return dao.crearComprobante(comprobante);
  }

  // ==========================================================
  // OBTENER POR ID
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorId(int id) {
    return dao.obtenerPorId(id);
  }

  // ==========================================================
  // OBTENER POR VENTA
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorVenta(int ventaId) {
    return dao.obtenerPorVenta(ventaId);
  }

  // ==========================================================
  // OBTENER TODOS
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerTodos() {
    return dao.obtenerTodos();
  }

  // ==========================================================
  // OBTENER POR TIPO
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorTipo(String tipo) {
    return dao.obtenerPorTipo(tipo);
  }

  // ==========================================================
  // OBTENER POR SERIE
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerPorSerie(String serie) {
    return dao.obtenerPorSerie(serie);
  }

  // ==========================================================
  // OBTENER ÚLTIMO CORRELATIVO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerUltimoPorSerie(String serie) {
    return dao.obtenerUltimoPorSerie(serie);
  }

  // ==========================================================
  // SIGUIENTE CORRELATIVO
  // ==========================================================

  Future<int> obtenerSiguienteNumero(String serie) {
    return dao.obtenerSiguienteNumero(serie);
  }

  // ==========================================================
  // ACTUALIZAR ESTADO
  // ==========================================================

  Future<bool> actualizarEstado(int id, String estado) {
    return dao.actualizarEstado(id, estado);
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
    return dao.actualizarRespuestaSunat(
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
    return dao.actualizarXml(id, xml);
  }

  // ==========================================================
  // ACTUALIZAR CDR
  // ==========================================================

  Future<bool> actualizarCdr(int id, String cdr) {
    return dao.actualizarCdr(id, cdr);
  }

  // ==========================================================
  // OBTENER COMPROBANTE RELACIONADO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerRelacionado(
    int comprobanteRelacionadoId,
  ) {
    return dao.obtenerRelacionado(comprobanteRelacionadoId);
  }

  // ==========================================================
  // OBTENER NOTAS DE CRÉDITO RELACIONADAS
  // ==========================================================

  Future<List<ComprobantesElectronico>> obtenerNotasCreditoRelacionadas(
    int comprobanteId,
  ) {
    return dao.obtenerNotasCreditoRelacionadas(comprobanteId);
  }

  // ==========================================================
  // BUSCAR POR SERIE Y NÚMERO
  // ==========================================================

  Future<ComprobantesElectronico?> obtenerPorSerieNumero(
    String serie,
    int numero,
  ) {
    return dao.obtenerPorSerieNumero(serie, numero);
  }
}
