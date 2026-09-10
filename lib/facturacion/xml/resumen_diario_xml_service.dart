import 'resumen_diario_linea.dart';

class ResumenDiarioXmlService {
  static const String _summaryDocuments =
      'urn:sunat:names:specification:ubl:peru:schema:xsd:SummaryDocuments-1';

  static const String _cac =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';

  static const String _cbc =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';

  static const String _ext =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2';

  static const String _sac =
      'urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1';

  /// Genera únicamente la estructura base del Resumen Diario.
  ///
  /// Este método NO firma, NO envía a SUNAT y NO modifica la base de datos.
  static String generarBase({
    required String idResumen,
    required DateTime fechaEmision,
    required String rucEmisor,
    required String razonSocialEmisor,
  }) {
    final fecha = _fecha(fechaEmision);

    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<SummaryDocuments '
      'xmlns="$_summaryDocuments" '
      'xmlns:cac="$_cac" '
      'xmlns:cbc="$_cbc" '
      'xmlns:ext="$_ext" '
      'xmlns:sac="$_sac" '
      'xmlns:ds="http://www.w3.org/2000/09/xmldsig#">',
    );

    buffer.writeln('  <ext:UBLExtensions>');
    buffer.writeln('    <ext:UBLExtension>');
    buffer.writeln('      <ext:ExtensionContent/>');
    buffer.writeln('    </ext:UBLExtension>');
    buffer.writeln('  </ext:UBLExtensions>');

    buffer.writeln('  <cbc:UBLVersionID>2.0</cbc:UBLVersionID>');
    buffer.writeln('  <cbc:CustomizationID>1.1</cbc:CustomizationID>');
    buffer.writeln('  <cbc:ID>${_escape(idResumen)}</cbc:ID>');
    buffer.writeln('  <cbc:ReferenceDate>$fecha</cbc:ReferenceDate>');
    buffer.writeln('  <cbc:IssueDate>$fecha</cbc:IssueDate>');

    buffer.writeln('  <cac:Signature>');
    buffer.writeln('    <cbc:ID>${_escape(idResumen)}</cbc:ID>');
    buffer.writeln('    <cac:SignatoryParty>');
    buffer.writeln('      <cac:PartyIdentification>');
    buffer.writeln(
      '        <cbc:ID>${_escape(rucEmisor)}</cbc:ID>',
    );
    buffer.writeln('      </cac:PartyIdentification>');
    buffer.writeln('      <cac:PartyName>');
    buffer.writeln(
      '        <cbc:Name>${_escape(razonSocialEmisor)}</cbc:Name>',
    );
    buffer.writeln('      </cac:PartyName>');
    buffer.writeln('    </cac:SignatoryParty>');
    buffer.writeln('    <cac:DigitalSignatureAttachment>');
    buffer.writeln('      <cac:ExternalReference>');
    buffer.writeln(
      '        <cbc:URI>#${_escape(idResumen)}</cbc:URI>',
    );
    buffer.writeln('      </cac:ExternalReference>');
    buffer.writeln('    </cac:DigitalSignatureAttachment>');
    buffer.writeln('  </cac:Signature>');

    buffer.writeln('  <cac:AccountingSupplierParty>');
    buffer.writeln(
      '    <cbc:CustomerAssignedAccountID>${_escape(rucEmisor)}</cbc:CustomerAssignedAccountID>',
    );
    buffer.writeln('    <cbc:AdditionalAccountID>6</cbc:AdditionalAccountID>');
    buffer.writeln('    <cac:Party>');
    buffer.writeln('      <cac:PartyLegalEntity>');
    buffer.writeln(
      '        <cbc:RegistrationName>${_escape(razonSocialEmisor)}</cbc:RegistrationName>',
    );
    buffer.writeln('      </cac:PartyLegalEntity>');
    buffer.writeln('    </cac:Party>');
    buffer.writeln('  </cac:AccountingSupplierParty>');

    buffer.writeln('</SummaryDocuments>');

    return buffer.toString();
  }

  static String generarLinea(ResumenDiarioLinea linea) {
    final buffer = StringBuffer();

    final conditionCode = switch (linea.estado.toLowerCase()) {
      'anulado' => '3',
      'modificado' => '2',
      _ => '1',
    };

    buffer.writeln('  <sac:SummaryDocumentsLine>');
    buffer.writeln('    <cbc:LineID>${linea.lineId}</cbc:LineID>');
    buffer.writeln(
      '    <cbc:DocumentTypeCode>${_escape(linea.tipoComprobante)}</cbc:DocumentTypeCode>',
    );
    buffer.writeln(
      '    <cbc:ID>${_escape(linea.serieNumero)}</cbc:ID>',
    );

    buffer.writeln('    <cac:AccountingCustomerParty>');
    buffer.writeln(
      '      <cbc:CustomerAssignedAccountID>${_escape(linea.numeroDocumentoAdquiriente)}</cbc:CustomerAssignedAccountID>',
    );
    buffer.writeln(
      '      <cbc:AdditionalAccountID>${_escape(linea.tipoDocumentoAdquiriente)}</cbc:AdditionalAccountID>',
    );
    buffer.writeln('    </cac:AccountingCustomerParty>');

    buffer.writeln('    <cac:Status>');
    buffer.writeln(
      '      <cbc:ConditionCode>$conditionCode</cbc:ConditionCode>',
    );
    buffer.writeln('    </cac:Status>');

    buffer.writeln(
      '    <sac:TotalAmount currencyID="${_escape(linea.moneda)}">${_importe(linea.total)}</sac:TotalAmount>',
    );

    _agregarBillingPayment(
      buffer,
      linea.valorVentaGravada,
      '01',
      linea.moneda,
    );

    _agregarBillingPayment(
      buffer,
      linea.valorVentaExonerada,
      '02',
      linea.moneda,
    );

    _agregarBillingPayment(
      buffer,
      linea.valorVentaInafecta,
      '03',
      linea.moneda,
    );

    if (linea.valorVentaGratuita != 0) {
      _agregarBillingPayment(
        buffer,
        linea.valorVentaGratuita,
        '05',
        linea.moneda,
      );
    }

    buffer.writeln('    <cac:TaxTotal>');
    buffer.writeln(
      '      <cbc:TaxAmount currencyID="${_escape(linea.moneda)}">${_importe(linea.igv)}</cbc:TaxAmount>',
    );
    buffer.writeln('      <cac:TaxSubtotal>');
    buffer.writeln(
      '        <cbc:TaxAmount currencyID="${_escape(linea.moneda)}">${_importe(linea.igv)}</cbc:TaxAmount>',
    );
    buffer.writeln('        <cac:TaxCategory>');
    final porcentajeIgv = linea.valorVentaGravada > 0
    ? (linea.igv / linea.valorVentaGravada) * 100
    : 0.0;

    buffer.writeln(
    '          <cbc:Percent>${_importe(porcentajeIgv)}</cbc:Percent>',
    );
    buffer.writeln('          <cac:TaxScheme>');
    buffer.writeln('            <cbc:ID>1000</cbc:ID>');
    buffer.writeln('            <cbc:Name>IGV</cbc:Name>');
    buffer.writeln('            <cbc:TaxTypeCode>VAT</cbc:TaxTypeCode>');
    buffer.writeln('          </cac:TaxScheme>');
    buffer.writeln('        </cac:TaxCategory>');
    buffer.writeln('      </cac:TaxSubtotal>');
    buffer.writeln('    </cac:TaxTotal>');

    buffer.writeln('  </sac:SummaryDocumentsLine>');

    return buffer.toString();
  }

  static void _agregarBillingPayment(
    StringBuffer buffer,
    double importe,
    String instructionId,
    String moneda,
  ) {
    buffer.writeln('    <sac:BillingPayment>');
    buffer.writeln(
      '      <cbc:PaidAmount currencyID="${_escape(moneda)}">${_importe(importe)}</cbc:PaidAmount>',
    );
    buffer.writeln(
      '      <cbc:InstructionID>$instructionId</cbc:InstructionID>',
    );
    buffer.writeln('    </sac:BillingPayment>');
  }

  static String _importe(double valor) {
    return valor.toStringAsFixed(2);
  }
  static String generarResumen({
    required String idResumen,
    required DateTime fechaEmision,
    required String rucEmisor,
    required String razonSocialEmisor,
    required List<ResumenDiarioLinea> lineas,
  }) {
    final base = generarBase(
      idResumen: idResumen,
      fechaEmision: fechaEmision,
      rucEmisor: rucEmisor,
      razonSocialEmisor: razonSocialEmisor,
    );

    final contenidoLineas = StringBuffer();

    for (final linea in lineas) {
      contenidoLineas.write(generarLinea(linea));
    }

    return base.replaceFirst(
      '</SummaryDocuments>',
      '${contenidoLineas.toString()}</SummaryDocuments>',
    );
  }
  static String _fecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _escape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}






