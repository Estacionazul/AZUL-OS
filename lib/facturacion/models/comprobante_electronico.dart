enum TipoComprobanteElectronico { notaVenta, boleta, factura, notaCredito }

enum EstadoComprobanteElectronico {
  pendiente,
  generado,
  enviado,
  aceptado,
  rechazado,
  dadoDeBaja,
  anulado,
}

class ComprobanteElectronico {
  final int? id;

  /// Venta interna de AZUL OS relacionada.
  final int? ventaId;

  /// Tipo de comprobante.
  final TipoComprobanteElectronico tipo;

  /// Serie SUNAT.
  ///
  /// Ejemplos:
  /// B001
  /// F001
  /// B001/F001 para la nota de crédito según corresponda.
  final String serie;

  /// Número correlativo.
  final int numero;

  /// Fecha de emisión.
  final DateTime fechaEmision;

  /// Documento del cliente.
  final String? dni;

  /// RUC del cliente.
  final String? ruc;

  /// Nombre o razón social del cliente.
  final String? nombreCliente;

  /// Dirección fiscal del cliente.
  final String? direccionFiscal;

  /// Subtotal antes de IGV.
  final double subtotal;

  /// IGV.
  final double igv;

  /// Total del comprobante.
  final double total;

  /// Forma de pago utilizada en la venta.
  final String metodoPago;

  /// Estado actual frente a SUNAT.
  final EstadoComprobanteElectronico estado;

  /// Código/mensaje de respuesta de SUNAT.
  final String? codigoRespuestaSunat;

  /// Descripción de respuesta de SUNAT.
  final String? mensajeRespuestaSunat;

  /// CDR recibido desde SUNAT.
  final String? cdr;

  /// XML generado.
  final String? xml;

  /// Fecha en que se envió a SUNAT.
  final DateTime? fechaEnvioSunat;

  /// Fecha en que SUNAT respondió.
  final DateTime? fechaRespuestaSunat;

  /// Comprobante electrónico relacionado.
  ///
  /// Se utilizará principalmente para notas de crédito.
  final int? comprobanteRelacionadoId;

  /// Código de motivo SUNAT para la nota de crédito.
  final String? codigoMotivoNotaCredito;

  /// Descripción del motivo de la nota de crédito.
  final String? motivoNotaCredito;

  final String? observaciones;

  const ComprobanteElectronico({
    this.id,
    this.ventaId,
    required this.tipo,
    required this.serie,
    required this.numero,
    required this.fechaEmision,
    this.dni,
    this.ruc,
    this.nombreCliente,
    this.direccionFiscal,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.metodoPago,
    this.estado = EstadoComprobanteElectronico.pendiente,
    this.codigoRespuestaSunat,
    this.mensajeRespuestaSunat,
    this.cdr,
    this.xml,
    this.fechaEnvioSunat,
    this.fechaRespuestaSunat,
    this.comprobanteRelacionadoId,
    this.codigoMotivoNotaCredito,
    this.motivoNotaCredito,
    this.observaciones,
  });

  /// Número completo del comprobante.
  ///
  /// Ejemplo:
  /// B001-00000001
  /// F001-00000001
  String get numeroCompleto {
    return '$serie-${numero.toString().padLeft(8, '0')}';
  }

  /// Indica si este comprobante debe enviarse a SUNAT.
  bool get requiereSunat {
    switch (tipo) {
      case TipoComprobanteElectronico.notaVenta:
        return false;

      case TipoComprobanteElectronico.boleta:
      case TipoComprobanteElectronico.factura:
      case TipoComprobanteElectronico.notaCredito:
        return true;
    }
  }

  /// Indica si es un documento interno de AZUL OS.
  bool get esInterno {
    return tipo == TipoComprobanteElectronico.notaVenta;
  }

  /// Indica si SUNAT aceptó el comprobante.
  bool get aceptadoPorSunat {
    return estado == EstadoComprobanteElectronico.aceptado;
  }

  /// Crea una copia modificando solamente los valores indicados.
  ComprobanteElectronico copyWith({
    int? id,
    int? ventaId,
    TipoComprobanteElectronico? tipo,
    String? serie,
    int? numero,
    DateTime? fechaEmision,
    String? dni,
    String? ruc,
    String? nombreCliente,
    String? direccionFiscal,
    double? subtotal,
    double? igv,
    double? total,
    String? metodoPago,
    EstadoComprobanteElectronico? estado,
    String? codigoRespuestaSunat,
    String? mensajeRespuestaSunat,
    String? cdr,
    String? xml,
    DateTime? fechaEnvioSunat,
    DateTime? fechaRespuestaSunat,
    int? comprobanteRelacionadoId,
    String? codigoMotivoNotaCredito,
    String? motivoNotaCredito,
    String? observaciones,
  }) {
    return ComprobanteElectronico(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      tipo: tipo ?? this.tipo,
      serie: serie ?? this.serie,
      numero: numero ?? this.numero,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      dni: dni ?? this.dni,
      ruc: ruc ?? this.ruc,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      direccionFiscal: direccionFiscal ?? this.direccionFiscal,
      subtotal: subtotal ?? this.subtotal,
      igv: igv ?? this.igv,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      estado: estado ?? this.estado,
      codigoRespuestaSunat: codigoRespuestaSunat ?? this.codigoRespuestaSunat,
      mensajeRespuestaSunat:
          mensajeRespuestaSunat ?? this.mensajeRespuestaSunat,
      cdr: cdr ?? this.cdr,
      xml: xml ?? this.xml,
      fechaEnvioSunat: fechaEnvioSunat ?? this.fechaEnvioSunat,
      fechaRespuestaSunat: fechaRespuestaSunat ?? this.fechaRespuestaSunat,
      comprobanteRelacionadoId:
          comprobanteRelacionadoId ?? this.comprobanteRelacionadoId,
      codigoMotivoNotaCredito:
          codigoMotivoNotaCredito ?? this.codigoMotivoNotaCredito,
      motivoNotaCredito: motivoNotaCredito ?? this.motivoNotaCredito,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
