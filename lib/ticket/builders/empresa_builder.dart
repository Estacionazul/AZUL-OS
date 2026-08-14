import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../models/ticket.dart';

class EmpresaBuilder {
  const EmpresaBuilder();

  void build(
      Generator generator,
      List<int> bytes,
      Ticket ticket,
      ) {
    bytes.addAll(
      generator.text(
        ticket.empresa.nombre,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    );

    if (ticket.empresa.eslogan.isNotEmpty) {
      bytes.addAll(
        generator.text(
          ticket.empresa.eslogan,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
      );
    }

    if (ticket.empresa.instagram.isNotEmpty) {
      bytes.addAll(
        generator.text(
          ticket.empresa.instagram,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );
    }

    bytes.addAll(generator.hr());
  }
}