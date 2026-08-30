class RespuestaSunat {
  final bool aceptado;
  final String? codigo;
  final String? mensaje;
  final String? cdr;
  final String? xmlRespuesta;

  const RespuestaSunat({
    required this.aceptado,
    this.codigo,
    this.mensaje,
    this.cdr,
    this.xmlRespuesta,
  });

  factory RespuestaSunat.aceptada({
    String? codigo,
    String? mensaje,
    String? cdr,
    String? xmlRespuesta,
  }) {
    return RespuestaSunat(
      aceptado: true,
      codigo: codigo,
      mensaje: mensaje,
      cdr: cdr,
      xmlRespuesta: xmlRespuesta,
    );
  }

  factory RespuestaSunat.rechazada({
    String? codigo,
    String? mensaje,
    String? cdr,
    String? xmlRespuesta,
  }) {
    return RespuestaSunat(
      aceptado: false,
      codigo: codigo,
      mensaje: mensaje,
      cdr: cdr,
      xmlRespuesta: xmlRespuesta,
    );
  }

  @override
  String toString() {
    return 'RespuestaSunat('
        'aceptado: $aceptado, '
        'codigo: $codigo, '
        'mensaje: $mensaje'
        ')';
  }
}