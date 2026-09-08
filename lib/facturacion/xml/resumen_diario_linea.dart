class ResumenDiarioLinea {
  final int lineId;
  final String tipoComprobante;
  final String serieNumero;
  final String numeroDocumentoAdquiriente;
  final String tipoDocumentoAdquiriente;

  /// 1 = gravada
  /// 2 = exonerada
  /// 3 = inafecta
  /// 4 = gratuita
  final String tipoAfectacion;

  final double total;
  final double valorVentaGravada;
  final double valorVentaExonerada;
  final double valorVentaInafecta;
  final double valorVentaGratuita;
  final double igv;

  /// 1 = activo
  /// 2 = anulado
  final String estado;

  final String moneda;

  const ResumenDiarioLinea({
    required this.lineId,
    required this.tipoComprobante,
    required this.serieNumero,
    required this.numeroDocumentoAdquiriente,
    required this.tipoDocumentoAdquiriente,
    required this.tipoAfectacion,
    required this.total,
    required this.valorVentaGravada,
    required this.valorVentaExonerada,
    required this.valorVentaInafecta,
    required this.valorVentaGratuita,
    required this.igv,
    required this.estado,
    this.moneda = 'PEN',
  });
}
