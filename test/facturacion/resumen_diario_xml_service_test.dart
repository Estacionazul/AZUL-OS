import 'package:flutter_test/flutter_test.dart';

import 'package:azul_os/facturacion/xml/resumen_diario_xml_service.dart';

void main() {
  test('separa ReferenceDate de IssueDate en el Resumen Diario', () {
    final xml = ResumenDiarioXmlService.generarResumen(
      idResumen: 'RC-20260916-1',
      fechaEmision: DateTime(2026, 9, 17),
      fechaReferencia: DateTime(2026, 9, 16),
      rucEmisor: '20100066603',
      razonSocialEmisor: 'ESTACION AZUL',
      lineas: const [],
    );

    expect(
      xml,
      contains('<cbc:ReferenceDate>2026-09-16</cbc:ReferenceDate>'),
    );

    expect(
      xml,
      contains('<cbc:IssueDate>2026-09-17</cbc:IssueDate>'),
    );

    expect(xml, contains('<cbc:UBLVersionID>2.0</cbc:UBLVersionID>'));
    expect(xml, contains('<cbc:CustomizationID>1.1</cbc:CustomizationID>'));
  });
}
