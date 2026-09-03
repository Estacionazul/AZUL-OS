import '../models/comprobante_electronico.dart';

class ComprobanteXmlService {
  static const String _ubl =
      'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';

  static const String _cac =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';

  static const String _cbc =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';

  static const String _ext =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2';

  // ==========================================================
  // GENERAR XML
  // ==========================================================

  static String generar({
    required ComprobanteElectronico comprobante,
    required String rucEmisor,
    required String razonSocialEmisor,
    String? nombreComercial,
    String? direccionEmisor,
    String moneda = 'PEN',
    List<dynamic> detalles = const [],
  }) {
    final esFactura = comprobante.tipo == TipoComprobanteElectronico.factura;

    final tipoDocumento = esFactura ? '01' : '03';

    final fecha = _formatearFecha(comprobante.fechaEmision);

    final hora = _formatearHora(comprobante.fechaEmision);

    final buffer = StringBuffer();

    // ==========================================================
    // CABECERA XML
    // ==========================================================

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');

    buffer.writeln(
      '<Invoice '
      'xmlns="$_ubl" '
      'xmlns:cac="$_cac" '
      'xmlns:cbc="$_cbc" '
      'xmlns:ext="$_ext" '
      'xmlns:ds="http://www.w3.org/2000/09/xmldsig#">',
    );

    // ==========================================================
    // EXTENSION
    // ==========================================================

    buffer.writeln('<ext:UBLExtensions>');
    buffer.writeln('<ext:UBLExtension>');
    buffer.writeln('<ext:ExtensionContent>');
    buffer.writeln('</ext:ExtensionContent>');
    buffer.writeln('</ext:UBLExtension>');
    buffer.writeln('</ext:UBLExtensions>');

    // ==========================================================
    // INFORMACIÓN GENERAL
    // ==========================================================

    buffer.writeln('<cbc:UBLVersionID>2.1</cbc:UBLVersionID>');

    buffer.writeln('<cbc:CustomizationID>2.0</cbc:CustomizationID>');

    buffer.writeln(
      '<cbc:ProfileID '
          'schemeName="SUNAT:Identificador de Tipo de Operación" '
          'schemeAgencyName="PE:SUNAT" '
          'schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo17">'
          '0101'
          '</cbc:ProfileID>',
    );

    buffer.writeln('<cbc:ID>${_escape(comprobante.numeroCompleto)}</cbc:ID>');

    buffer.writeln('<cbc:IssueDate>$fecha</cbc:IssueDate>');

    buffer.writeln('<cbc:IssueTime>$hora</cbc:IssueTime>');

    buffer.writeln(
      '<cbc:InvoiceTypeCode '
          'listID="0101" '
          'name="Tipo de Operacion" '
          'listAgencyName="PE:SUNAT" '
          'listName="SUNAT:Identificador de Tipo de Documento" '
          'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo01" '
          'listSchemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo51">'
          '$tipoDocumento'
          '</cbc:InvoiceTypeCode>',
    );

    buffer.writeln(
      '<cbc:DocumentCurrencyCode '
      'listID="ISO 4217 Alpha" '
      'listName="Currency" '
      'listAgencyName="United Nations Economic Commission for Europe">'
      '$moneda'
      '</cbc:DocumentCurrencyCode>',
    );

    // ==========================================================
    // EMISOR
    // ==========================================================

    buffer.writeln('<cac:AccountingSupplierParty>');
    buffer.writeln('<cac:Party>');

    buffer.writeln('<cac:PartyIdentification>');

    buffer.writeln(
      '<cbc:ID schemeID="6">'
      '${_escape(rucEmisor)}'
      '</cbc:ID>',
    );

    buffer.writeln('</cac:PartyIdentification>');

    if (nombreComercial != null && nombreComercial.trim().isNotEmpty) {
      buffer.writeln('<cac:PartyName>');

      buffer.writeln(
        '<cbc:Name>'
        '${_escape(nombreComercial)}'
        '</cbc:Name>',
      );

      buffer.writeln('</cac:PartyName>');
    }

    buffer.writeln('<cac:PartyLegalEntity>');

    buffer.writeln(
      '<cbc:RegistrationName>'
      '${_escape(razonSocialEmisor)}'
      '</cbc:RegistrationName>',
    );

    if (direccionEmisor != null && direccionEmisor.trim().isNotEmpty) {
      buffer.writeln('<cac:RegistrationAddress>');
      buffer.writeln('<cac:AddressLine>');

      buffer.writeln(
        '<cbc:Line>'
        '${_escape(direccionEmisor)}'
        '</cbc:Line>',
      );

      buffer.writeln('</cac:AddressLine>');
      buffer.writeln('</cac:RegistrationAddress>');
    }

    buffer.writeln('</cac:PartyLegalEntity>');
    buffer.writeln('</cac:Party>');
    buffer.writeln('</cac:AccountingSupplierParty>');

    // ==========================================================
    // CLIENTE
    // ==========================================================

    buffer.writeln('<cac:AccountingCustomerParty>');
    buffer.writeln('<cac:Party>');

    final numeroDocumento = esFactura ? comprobante.ruc : comprobante.dni;

    final tipoDocumentoCliente = esFactura ? '6' : '1';

    if (numeroDocumento != null && numeroDocumento.trim().isNotEmpty) {
      buffer.writeln('<cac:PartyIdentification>');

      buffer.writeln(
        '<cbc:ID schemeID="$tipoDocumentoCliente">'
        '${_escape(numeroDocumento)}'
        '</cbc:ID>',
      );

      buffer.writeln('</cac:PartyIdentification>');
    }

    buffer.writeln('<cac:PartyLegalEntity>');

    buffer.writeln(
      '<cbc:RegistrationName>'
      '${_escape((comprobante.nombreCliente ?? '').trim().isEmpty ? 'CLIENTE GENERAL' : comprobante.nombreCliente!.trim())}'
      '</cbc:RegistrationName>',
    );

    if (comprobante.direccionFiscal != null &&
        comprobante.direccionFiscal!.trim().isNotEmpty) {
      buffer.writeln('<cac:RegistrationAddress>');
      buffer.writeln('<cac:AddressLine>');

      buffer.writeln(
        '<cbc:Line>'
        '${_escape(comprobante.direccionFiscal!)}'
        '</cbc:Line>',
      );

      buffer.writeln('</cac:AddressLine>');
      buffer.writeln('</cac:RegistrationAddress>');
    }

    buffer.writeln('</cac:PartyLegalEntity>');
    buffer.writeln('</cac:Party>');
    buffer.writeln('</cac:AccountingCustomerParty>');

    // ==========================================================
    // IGV TOTAL
    // ==========================================================

    buffer.writeln('<cac:TaxTotal>');

    buffer.writeln(
      '<cbc:TaxAmount currencyID="$moneda">'
      '${_decimal(comprobante.igv)}'
      '</cbc:TaxAmount>',
    );

    buffer.writeln('<cac:TaxSubtotal>');

    buffer.writeln(
      '<cbc:TaxableAmount currencyID="$moneda">'
      '${_decimal(comprobante.subtotal)}'
      '</cbc:TaxableAmount>',
    );

    buffer.writeln(
      '<cbc:TaxAmount currencyID="$moneda">'
      '${_decimal(comprobante.igv)}'
      '</cbc:TaxAmount>',
    );

    buffer.writeln('<cac:TaxCategory>');

    buffer.writeln(
      '<cbc:ID '
      'schemeID="UN/ECE 5305" '
      'schemeName="Tax Category Identifier" '
      'schemeAgencyName="United Nations Economic Commission for Europe">'
      'S'
      '</cbc:ID>',
    );

    buffer.writeln('<cbc:Percent>18.00</cbc:Percent>');

    buffer.writeln(
      '<cbc:TaxExemptionReasonCode '
      'listAgencyName="PE:SUNAT" '
      'listName="SUNAT:Codigo de Tipo de Afectación del IGV" '
      'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo07">'
      '10'
      '</cbc:TaxExemptionReasonCode>',
    );

    buffer.writeln('<cac:TaxScheme>');

    buffer.writeln(
      '<cbc:ID '
      'schemeID="UN/ECE 5153" '
      'schemeName="Tax Scheme Identifier" '
      'schemeAgencyName="United Nations Economic Commission for Europe">'
      '1000'
      '</cbc:ID>',
    );

    buffer.writeln('<cbc:Name>IGV</cbc:Name>');

    buffer.writeln('<cbc:TaxTypeCode>VAT</cbc:TaxTypeCode>');

    buffer.writeln('</cac:TaxScheme>');
    buffer.writeln('</cac:TaxCategory>');
    buffer.writeln('</cac:TaxSubtotal>');
    buffer.writeln('</cac:TaxTotal>');

    // ==========================================================
    // TOTALES
    // ==========================================================

    buffer.writeln('<cac:LegalMonetaryTotal>');

    buffer.writeln(
      '<cbc:LineExtensionAmount currencyID="$moneda">'
      '${_decimal(comprobante.subtotal)}'
      '</cbc:LineExtensionAmount>',
    );

    buffer.writeln(
      '<cbc:TaxInclusiveAmount currencyID="$moneda">'
      '${_decimal(comprobante.total)}'
      '</cbc:TaxInclusiveAmount>',
    );

    buffer.writeln(
      '<cbc:PayableAmount currencyID="$moneda">'
      '${_decimal(comprobante.total)}'
      '</cbc:PayableAmount>',
    );

    buffer.writeln('</cac:LegalMonetaryTotal>');

    // ==========================================================
    // DETALLES DE LA VENTA
    // ==========================================================

    for (int i = 0; i < detalles.length; i++) {
      final detalle = detalles[i];

      _agregarInvoiceLine(
        buffer: buffer,
        detalle: detalle,
        numeroLinea: i + 1,
        moneda: moneda,
      );
    }

    // ==========================================================
    // CIERRE
    // ==========================================================

    buffer.writeln('</Invoice>');

    return buffer.toString();
  }

  // ==========================================================
  // INVOICE LINE
  // ==========================================================

  static void _agregarInvoiceLine({
    required StringBuffer buffer,
    required dynamic detalle,
    required int numeroLinea,
    required String moneda,
  }) {
    final cantidad = _leerDouble(detalle, 'cantidad');

    final precioUnitario = _leerDouble(detalle, 'precioUnitario');

    final subtotal = _leerDouble(detalle, 'subtotal');

    final nombre = _leerString(detalle, 'nombreProducto') ?? 'PRODUCTO';

    // El precio almacenado en AZUL OS es precio de venta
    // con IGV incluido.
    //
    // Calculamos el valor unitario sin IGV para UBL.

    final valorUnitario = precioUnitario / 1.18;

    final valorVenta = subtotal / 1.18;

    final igvLinea = subtotal - valorVenta;

    buffer.writeln('<cac:InvoiceLine>');

    // ========================================================
    // ID DE LÍNEA
    // ========================================================

    buffer.writeln('<cbc:ID>$numeroLinea</cbc:ID>');

    // ========================================================
    // CANTIDAD
    // ========================================================

    buffer.writeln(
      '<cbc:InvoicedQuantity unitCode="NIU">'
      '${_decimalCantidad(cantidad)}'
      '</cbc:InvoicedQuantity>',
    );

    // ========================================================
    // VALOR DE VENTA
    // ========================================================

    buffer.writeln(
      '<cbc:LineExtensionAmount currencyID="$moneda">'
      '${_decimal(valorVenta)}'
      '</cbc:LineExtensionAmount>',
    );

    // ========================================================
    // REFERENCIA DE PRECIO
    // ========================================================

    buffer.writeln('<cac:PricingReference>');
    buffer.writeln('<cac:AlternativeConditionPrice>');

    buffer.writeln(
      '<cbc:PriceAmount currencyID="$moneda">'
      '${_decimal(precioUnitario)}'
      '</cbc:PriceAmount>',
    );

    buffer.writeln(
      '<cbc:PriceTypeCode>'
      '01'
      '</cbc:PriceTypeCode>',
    );

    buffer.writeln('</cac:AlternativeConditionPrice>');
    buffer.writeln('</cac:PricingReference>');

    // ========================================================
    // IGV DE LA LÍNEA
    // ========================================================

    buffer.writeln('<cac:TaxTotal>');

    buffer.writeln(
      '<cbc:TaxAmount currencyID="$moneda">'
      '${_decimal(igvLinea)}'
      '</cbc:TaxAmount>',
    );

    buffer.writeln('<cac:TaxSubtotal>');

    buffer.writeln(
      '<cbc:TaxableAmount currencyID="$moneda">'
      '${_decimal(valorVenta)}'
      '</cbc:TaxableAmount>',
    );

    buffer.writeln(
      '<cbc:TaxAmount currencyID="$moneda">'
      '${_decimal(igvLinea)}'
      '</cbc:TaxAmount>',
    );

    buffer.writeln('<cac:TaxCategory>');

    buffer.writeln(
      '<cbc:ID '
      'schemeID="UN/ECE 5305" '
      'schemeName="Tax Category Identifier" '
      'schemeAgencyName="United Nations Economic Commission for Europe">'
      'S'
      '</cbc:ID>',
    );

    buffer.writeln('<cbc:Percent>18.00</cbc:Percent>');

    buffer.writeln(
      '<cbc:TaxExemptionReasonCode '
      'listAgencyName="PE:SUNAT" '
      'listName="SUNAT:Codigo de Tipo de Afectación del IGV" '
      'listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo07">'
      '10'
      '</cbc:TaxExemptionReasonCode>',
    );

    buffer.writeln('<cac:TaxScheme>');

    buffer.writeln('<cbc:ID>1000</cbc:ID>');
    buffer.writeln('<cbc:Name>IGV</cbc:Name>');
    buffer.writeln('<cbc:TaxTypeCode>VAT</cbc:TaxTypeCode>');

    buffer.writeln('</cac:TaxScheme>');
    buffer.writeln('</cac:TaxCategory>');
    buffer.writeln('</cac:TaxSubtotal>');
    buffer.writeln('</cac:TaxTotal>');

    // ========================================================
    // PRODUCTO
    // ========================================================

    buffer.writeln('<cac:Item>');

    buffer.writeln(
      '<cbc:Description>'
      '${_escape(nombre)}'
      '</cbc:Description>',
    );

    buffer.writeln('</cac:Item>');

    // ========================================================
    // PRECIO
    // ========================================================

    buffer.writeln('<cac:Price>');

    buffer.writeln(
      '<cbc:PriceAmount currencyID="$moneda">'
      '${_decimal(valorUnitario)}'
      '</cbc:PriceAmount>',
    );

    buffer.writeln('</cac:Price>');

    buffer.writeln('</cac:InvoiceLine>');
  }

  // ==========================================================
  // LECTURA SEGURA
  // ==========================================================

  static double _leerDouble(dynamic objeto, String campo) {
    final valor = _leerValor(objeto, campo);

    if (valor is num) {
      return valor.toDouble();
    }

    return double.tryParse(valor?.toString() ?? '') ?? 0.0;
  }

  static String? _leerString(dynamic objeto, String campo) {
    final valor = _leerValor(objeto, campo);

    if (valor == null) {
      return null;
    }

    return valor.toString();
  }

  static dynamic _leerValor(dynamic objeto, String campo) {
    switch (campo) {
      case 'cantidad':
        return objeto.cantidad;

      case 'precioUnitario':
        return objeto.precioUnitario;

      case 'subtotal':
        return objeto.subtotal;

      case 'nombreProducto':
        return objeto.producto.nombre;

      default:
        return null;
    }
  }

  // ==========================================================
  // FECHA
  // ==========================================================

  static String _formatearFecha(DateTime fecha) {
    return '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // HORA
  // ==========================================================

  static String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}:'
        '${fecha.second.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // DECIMALES
  // ==========================================================

  static String _decimal(double valor) {
    return valor.toStringAsFixed(2);
  }

  static String _decimalCantidad(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }

    return valor.toString();
  }

  // ==========================================================
  // ESCAPE XML
  // ==========================================================

  static String _escape(String valor) {
    return valor
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
