class EmpresaModel {
  final int? id;

  // Información fiscal
  final String nombre;
  final String ruc;
  final String direccion;
  final String telefono;

  // Información comercial
  final String instagram;
  final String logo;

  // Configuración de comprobantes
  final String serieBoleta;
  final String serieFactura;
  final int correlativoBoleta;
  final int correlativoFactura;

  // Configuración tributaria
  final double igv;
  final String moneda;
  final String tipoContribuyente;

  // Impresora predeterminada
  final String impresora;

  const EmpresaModel({
    this.id,
    required this.nombre,
    required this.ruc,
    this.direccion = '',
    this.telefono = '',
    this.instagram = '',
    this.logo = '',
    this.serieBoleta = 'B001',
    this.serieFactura = 'F001',
    this.correlativoBoleta = 1,
    this.correlativoFactura = 1,
    this.igv = 18,
    this.moneda = 'PEN',
    this.tipoContribuyente = 'PERSONA_NATURAL',
    this.impresora = '',
  });
}