class RespuestaResumenDiario {
  final bool procesado;
  final String? ticket;
  final String? codigo;
  final String? mensaje;
  final String? cdr;
  final String? xmlRespuesta;

  const RespuestaResumenDiario({
    required this.procesado,
    this.ticket,
    this.codigo,
    this.mensaje,
    this.cdr,
    this.xmlRespuesta,
  });

  factory RespuestaResumenDiario.ticket({
    required String ticket,
    String? xmlRespuesta,
  }) {
    return RespuestaResumenDiario(
      procesado: false,
      ticket: ticket,
      xmlRespuesta: xmlRespuesta,
    );
  }

  factory RespuestaResumenDiario.procesado({
    String? codigo,
    String? mensaje,
    String? cdr,
    String? xmlRespuesta,
  }) {
    return RespuestaResumenDiario(
      procesado: true,
      codigo: codigo,
      mensaje: mensaje,
      cdr: cdr,
      xmlRespuesta: xmlRespuesta,
    );
  }

  factory RespuestaResumenDiario.error({
    String? codigo,
    String? mensaje,
    String? xmlRespuesta,
  }) {
    return RespuestaResumenDiario(
      procesado: false,
      codigo: codigo,
      mensaje: mensaje,
      xmlRespuesta: xmlRespuesta,
    );
  }

  @override
  String toString() {
    return 'RespuestaResumenDiario('
        'procesado: $procesado, '
        'ticket: $ticket, '
        'codigo: $codigo, '
        'mensaje: $mensaje'
        ')';
  }
}