import 'package:flutter_test/flutter_test.dart';

import 'package:azul_os/facturacion/models/comprobante_electronico.dart';
import 'package:azul_os/facturacion/xml/comprobante_xml_service.dart';

void main() {
  test('genera XML de boleta gravada con totales correctos', () {
    final comprobante = ComprobanteElectronico(
      tipo: TipoComprobanteElectronico.boleta,
      serie: 'B001',
      numero: 1,
      fechaEmision: DateTime(2026, 9, 17, 10, 30),
      subtotal: 8.47,
      igv: 1.53,
      total: 10.00,
      metodoPago: 'EFECTIVO',
    );

    final xml = ComprobanteXmlService.generar(
      comprobante: comprobante,
      rucEmisor: '20100066603',
      razonSocialEmisor: 'ESTACION AZUL',
      nombreComercial: 'ESTACION AZUL',
      direccionEmisor: 'LIMA',
      moneda: 'PEN',
      detalles: const [
        _DetallePrueba(
          cantidad: 1,
          precioUnitario: 10.00,
          subtotal: 10.00,
          producto: _ProductoPrueba(
            nombre: 'Café con leche',
          ),
        ),
      ],
    );

    expect(xml, contains('<cbc:UBLVersionID>2.1</cbc:UBLVersionID>'));
    expect(xml, contains('<cbc:CustomizationID>2.0</cbc:CustomizationID>'));
    expect(xml, contains('>03</cbc:InvoiceTypeCode>'));

    expect(xml, contains('<cbc:ID>B001-00000001</cbc:ID>'));
    expect(xml, contains('>PEN</cbc:DocumentCurrencyCode>'));
    expect(
      xml,
      contains('<cbc:InvoicedQuantity unitCode="NIU">1</cbc:InvoicedQuantity>'),
    );

    expect(
      xml,
      contains(
        '<cbc:LineExtensionAmount currencyID="PEN">8.47</cbc:LineExtensionAmount>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:PriceAmount currencyID="PEN">8.47</cbc:PriceAmount>',
      ),
    );

    expect(
      xml,
      contains('<cbc:PriceTypeCode>01</cbc:PriceTypeCode>'),
    );

    expect(
      xml,
      contains('<cbc:Description>Café con leche</cbc:Description>'),
    );

    expect(
      xml,
      contains('<cbc:TaxableAmount currencyID="PEN">8.47</cbc:TaxableAmount>'),
    );

    expect(
      xml,
      contains('<cbc:TaxAmount currencyID="PEN">1.53</cbc:TaxAmount>'),
    );

    expect(
      xml,
      contains(
        '<cbc:LineExtensionAmount currencyID="PEN">8.47</cbc:LineExtensionAmount>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:TaxInclusiveAmount currencyID="PEN">10.00</cbc:TaxInclusiveAmount>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:PayableAmount currencyID="PEN">10.00</cbc:PayableAmount>',
      ),
    );

    expect(xml, contains('<cbc:Percent>18.00</cbc:Percent>'));
    expect(xml, contains('<cbc:TaxExemptionReasonCode'));
    expect(xml, contains('>10</cbc:TaxExemptionReasonCode>'));
    expect(xml, contains('<cbc:Name>IGV</cbc:Name>'));
    expect(xml, contains('<cbc:TaxTypeCode>VAT</cbc:TaxTypeCode>'));
  });

  test('genera XML de factura gravada con totales correctos', () {
    final comprobante = ComprobanteElectronico(
      tipo: TipoComprobanteElectronico.factura,
      serie: 'F001',
      numero: 1,
      fechaEmision: DateTime(2026, 9, 17, 10, 30),
      ruc: '20123456789',
      razonSocial: 'CLIENTE FACTURA SAC',
      direccionFiscal: 'LIMA',
      subtotal: 8.47,
      igv: 1.53,
      total: 10.00,
      metodoPago: 'EFECTIVO',
    );

    final xml = ComprobanteXmlService.generar(
      comprobante: comprobante,
      rucEmisor: '20100066603',
      razonSocialEmisor: 'ESTACION AZUL',
      nombreComercial: 'ESTACION AZUL',
      direccionEmisor: 'LIMA',
      moneda: 'PEN',
      detalles: const [
        _DetallePrueba(
          cantidad: 1,
          precioUnitario: 10.00,
          subtotal: 10.00,
          producto: _ProductoPrueba(
            nombre: 'Café con leche',
          ),
        ),
      ],
    );

    expect(xml, contains('<cbc:UBLVersionID>2.1</cbc:UBLVersionID>'));
    expect(xml, contains('<cbc:CustomizationID>2.0</cbc:CustomizationID>'));
    expect(xml, contains('>01</cbc:InvoiceTypeCode>'));

    expect(xml, contains('<cbc:ID>F001-00000001</cbc:ID>'));
    expect(xml, contains('>PEN</cbc:DocumentCurrencyCode>'));

    expect(
      xml,
      contains(
        '<cbc:RegistrationName>CLIENTE FACTURA SAC</cbc:RegistrationName>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:CompanyID '
            'schemeID="6" '
            'schemeName="SUNAT:Identificador de Documento de Identidad" '
            'schemeAgencyName="PE:SUNAT" '
            'schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">'
            '20123456789'
            '</cbc:CompanyID>',
      ),
    );

    expect(
      xml,
      contains('<cbc:Line>LIMA</cbc:Line>'),
    );

    expect(
      xml,
      contains(
        '<cbc:LineExtensionAmount currencyID="PEN">8.47</cbc:LineExtensionAmount>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:TaxableAmount currencyID="PEN">8.47</cbc:TaxableAmount>',
      ),
    );

    expect(
      xml,
      contains('<cbc:TaxAmount currencyID="PEN">1.53</cbc:TaxAmount>'),
    );

    expect(
      xml,
      contains(
        '<cbc:TaxInclusiveAmount currencyID="PEN">10.00</cbc:TaxInclusiveAmount>',
      ),
    );

    expect(
      xml,
      contains(
        '<cbc:PayableAmount currencyID="PEN">10.00</cbc:PayableAmount>',
      ),
    );

    expect(
      xml,
      contains('<cbc:Description>Café con leche</cbc:Description>'),
    );
  });
}

class _DetallePrueba {
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final _ProductoPrueba producto;

  const _DetallePrueba({
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.producto,
  });
}

class _ProductoPrueba {
  final String nombre;

  const _ProductoPrueba({
    required this.nombre,
  });
}