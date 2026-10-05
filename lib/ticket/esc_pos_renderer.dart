import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../models/ticket.dart';

class EscPosRenderer {
  const EscPosRenderer();

  //====================================================
  // CONFIGURACIÓN DE CARACTERES ESPAÑOLES
  //====================================================

  /*
   * La POS-58 trabaja con CP850.
   *
   * esc_pos_utils_plus usa Latin-1 como codec por defecto
   * cuando recibe un String.
   *
   * Para evitar que las tildes se transformen en caracteres
   * incorrectos, convertimos manualmente los caracteres
   * españoles a sus bytes CP850 y utilizamos textEncoded().
   */

  Uint8List _cp850(String texto) {
    final bytes = <int>[];

    for (final caracter in texto.runes) {
      switch (caracter) {
        //==============================================
        // MINÚSCULAS
        //==============================================

        case 0xE1: // á
          bytes.add(0xA0);
          break;

        case 0xE9: // é
          bytes.add(0x82);
          break;

        case 0xED: // í
          bytes.add(0xA1);
          break;

        case 0xF3: // ó
          bytes.add(0xA2);
          break;

        case 0xFA: // ú
          bytes.add(0xA3);
          break;

        case 0xFC: // ü
          bytes.add(0x81);
          break;

        case 0xF1: // ñ
          bytes.add(0xA4);
          break;

        //==============================================
        // MAYÚSCULAS
        //==============================================

        case 0xC1: // Á
          bytes.add(0xB5);
          break;

        case 0xC9: // É
          bytes.add(0x90);
          break;

        case 0xCD: // Í
          bytes.add(0xD6);
          break;

        case 0xD3: // Ó
          bytes.add(0xE0);
          break;

        case 0xDA: // Ú
          bytes.add(0xE9);
          break;

        case 0xDC: // Ü
          bytes.add(0x9A);
          break;

        case 0xD1: // Ñ
          bytes.add(0xA5);
          break;

        //==============================================
        // SIGNOS ESPAÑOLES
        //==============================================

        case 0xBF: // ¿
          bytes.add(0xA8);
          break;

        case 0xA1: // ¡
          bytes.add(0xAD);
          break;

        case 0xB0: // °
          bytes.add(0xF8);
          break;

        //==============================================
        // CEDILLA
        //==============================================

        case 0xE7: // ç
          bytes.add(0x87);
          break;

        case 0xC7: // Ç
          bytes.add(0x80);
          break;

        //==============================================
        // ESPACIO
        //==============================================

        case 0x20:
          bytes.add(0x20);
          break;

        //==============================================
        // ASCII NORMAL
        //==============================================

        default:
          if (caracter <= 0x7F) {
            bytes.add(caracter);
          } else {
            // Carácter no soportado.
            bytes.add(0x3F);
          }
      }
    }

    return Uint8List.fromList(bytes);
  }

  //====================================================
  // RENDER PRINCIPAL
  //====================================================

  Future<List<int>> render(Ticket ticket) async {
    final profile = await CapabilityProfile.load();

    // POS-58: eliminar el espacio vertical automático entre líneas.
    // La impresora ya agrega su avance físico; el valor por defecto de
    // esc_pos_utils_plus (5) hace que el ticket quede innecesariamente largo.
    final generator = Generator(
      PaperSize.mm58,
      profile,
      spaceBetweenRows: 0,
    );

    final bytes = <int>[];

    //==================================================
    // REINICIAR IMPRESORA
    //==================================================

    bytes.addAll(generator.reset());

    //==================================================
    // SELECCIONAR CP850
    //==================================================

    bytes.addAll(generator.setGlobalCodeTable('CP850'));

    //==================================================
    // ENCABEZADO
    //==================================================

    await _renderEmpresa(generator, bytes, ticket);

    //==================================================
    // DOCUMENTO
    //==================================================

    _renderHeader(generator, bytes, ticket);

    //==================================================
    // CLIENTE
    //==================================================

    _renderCliente(generator, bytes, ticket);

    //==================================================
    // PRODUCTOS
    //==================================================

    _renderItems(generator, bytes, ticket);

    //==================================================
    // TOTALES
    //==================================================

    _renderTotales(generator, bytes, ticket);

    //==================================================
// PIE
//==================================================

    _renderFooter(generator, bytes, ticket);

//==================================================
// QR SUNAT
//==================================================

    if (ticket.qr != null) {
      bytes.addAll(generator.emptyLines(1));

      bytes.addAll(
        generator.textEncoded(
          _cp850('ESCANEA PARA CONSULTAR'),
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );

      bytes.addAll(
        generator.qrcode(
          ticket.qr!.contenido,
          align: PosAlign.center,
          size: QRSize.size4,
          cor: QRCorrection.Q,
        ),
      );

      bytes.addAll(generator.emptyLines(1));
    }

//==================================================
// CORTE COMPACTO
//==================================================
// esc_pos_utils_plus añade 5 líneas automáticamente antes de cut().
// Para una POS-58 eso deja demasiado papel en blanco al final.
// Dejamos solo una línea y enviamos el comando ESC/POS de corte directo.

    bytes.addAll(generator.emptyLines(1));
    bytes.addAll(generator.rawBytes([0x1D, 0x56, 0x00]));

    return bytes;
  }

  //====================================================
  // EMPRESA
  //====================================================

  Future<void> _renderEmpresa(
    Generator generator,
    List<int> bytes,
    Ticket ticket,
  ) async {
    try {
      //==================================================
      // CARGAR LOGO ESTACIÓN AZUL
      //==================================================

      final data = await rootBundle.load('assets/images/logo.png');

      final logoBytes = data.buffer.asUint8List();

      final img.Image? logoOriginal = img.decodeImage(logoBytes);

      if (logoOriginal != null) {
        //================================================
        // RECORTAR EL LIENZO BLANCO/TRANSPARENTE DEL PNG.
        // Esto evita que el logo arrastre márgenes superiores e inferiores
        // que terminan convirtiéndose en papel en blanco en la POS-58.
        //================================================

        final logoRecortado = img.trim(
          logoOriginal,
          mode: img.TrimMode.topLeftColor,
          fuzzy: 0.05,
        );

        //================================================
        // CONVERTIR EL LOGO A ESCALA DE GRISES
        //
        // La POS-58 es monocromática.
        // Convertimos azul y dorado en tonos oscuros.
        //================================================

        final gris = img.grayscale(logoRecortado);

        //================================================
        // AUMENTAR CONTRASTE
        //================================================

        final contraste = img.adjustColor(gris, contrast: 1.8);

        //================================================
        // CONVERTIR A BLANCO/NEGRO
        //
        // El dorado debe convertirse en NEGRO para que
        // no desaparezca al imprimir.
        //================================================

        for (var y = 0; y < contraste.height; y++) {
          for (var x = 0; x < contraste.width; x++) {
            final pixel = contraste.getPixel(x, y);

            final luminancia =
                (0.299 * pixel.r) + (0.587 * pixel.g) + (0.114 * pixel.b);

            if (luminancia < 225) {
              contraste.setPixelRgba(x, y, 0, 0, 0, 255);
            } else {
              contraste.setPixelRgba(x, y, 255, 255, 255, 255);
            }
          }
        }

        //================================================
        // REDIMENSIONAR PARA POS-58
        //
        // 250 px conserva buena definición y reduce la altura del logo.
        //================================================

        final logo = img.copyResize(
          contraste,
          width: 250,
          interpolation: img.Interpolation.cubic,
        );

        //================================================
        // IMPRIMIR LOGO
        //
        // ESC * es el método que acabamos de comprobar
        // que esta impresora sí está interpretando.
        //================================================

        bytes.addAll(
          generator.image(logo, align: PosAlign.center, isDoubleDensity: true),
        );

        // Separación visual mínima entre el logo y los datos fiscales.
        // Una sola línea mantiene el encabezado compacto sin pegar el RUC al logo.
        bytes.addAll(generator.emptyLines(1));

        bytes.addAll(
          generator.textEncoded(
            _cp850("RUC: 10446152080"),
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
            ),
          ),
        );

        bytes.addAll(
          generator.textEncoded(
            _cp850("Av. Nicolás Ayllón 582 - Ate"),
            styles: const PosStyles(
              align: PosAlign.center,
            ),
          ),
        );

      }
    } catch (e, stackTrace) {
      debugPrint('ERROR IMPRIMIENDO LOGO: $e');

      debugPrint(stackTrace.toString());
    }
  }

  //====================================================
  // DOCUMENTO / FECHA / HORA
  //====================================================

  void _renderHeader(Generator generator, List<int> bytes, Ticket ticket) {
    final tipo = ticket.cliente.tipoDocumento;

    bytes.addAll(
      generator.textEncoded(
        _cp850(tipo.toUpperCase()),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
        ),
      ),
    );

    bytes.addAll(
      generator.textEncoded(
        _cp850("N° ${ticket.header.numero}"),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          width: 4,
          textEncoded: _cp850("Fecha:"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          width: 8,
          textEncoded: _cp850(
            "${ticket.header.fecha.day.toString().padLeft(2, '0')}/"
            "${ticket.header.fecha.month.toString().padLeft(2, '0')}/"
            "${ticket.header.fecha.year}",
          ),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          width: 4,
          textEncoded: _cp850("Hora:"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          width: 8,
          textEncoded: _cp850(
            "${ticket.header.fecha.hour.toString().padLeft(2, '0')}:"
            "${ticket.header.fecha.minute.toString().padLeft(2, '0')}",
          ),
        ),
      ]),
    );

    bytes.addAll(generator.hr());
  }

  //====================================================
  // CLIENTE
  //====================================================

  void _renderCliente(Generator generator, List<int> bytes, Ticket ticket) {
    final cliente = ticket.cliente;

    switch (cliente.tipoDocumento) {
      //================================================
      // NOTA DE VENTA
      //================================================

      case "Nota de Venta":
        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("Cliente:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(
              width: 8,
              textEncoded: _cp850(
                cliente.cliente?.isNotEmpty == true
                    ? cliente.cliente!
                    : "Cliente General",
              ),
            ),
          ]),
        );

        break;

      //================================================
      // BOLETA
      //================================================

      case "Boleta":
        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("Cliente:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(width: 8, textEncoded: _cp850(cliente.cliente ?? "")),
          ]),
        );

        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("DNI:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(width: 8, textEncoded: _cp850(cliente.dni ?? "")),
          ]),
        );

        break;

      //================================================
      // FACTURA
      //================================================

      case "Factura":
        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("RUC:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(width: 8, textEncoded: _cp850(cliente.ruc ?? "")),
          ]),
        );

        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("Razón:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(width: 8, textEncoded: _cp850(cliente.razonSocial ?? "")),
          ]),
        );

        bytes.addAll(
          generator.row([
            PosColumn(
              width: 4,
              textEncoded: _cp850("Dirección:"),
              styles: const PosStyles(bold: true),
            ),
            PosColumn(
              width: 8,
              textEncoded: _cp850(cliente.direccionFiscal ?? ""),
            ),
          ]),
        );

        break;
    }

    bytes.addAll(generator.hr());
  }

  //====================================================
  // PRODUCTOS
  //====================================================

  void _renderItems(Generator generator, List<int> bytes, Ticket ticket) {
    for (final item in ticket.items) {
      //================================================
      // PRODUCTO + PRECIO
      //================================================

      bytes.addAll(
        generator.row([
          PosColumn(
            width: 8,
            textEncoded: _cp850(item.nombre),
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            width: 4,
            textEncoded: _cp850("S/ ${item.total.toStringAsFixed(2)}"),
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );

      //================================================
      // CANTIDAD + PRECIO UNITARIO
      //================================================

      bytes.addAll(
        generator.textEncoded(
          _cp850(
            "${item.cantidad} x S/ "
            "${item.precioUnitario.toStringAsFixed(2)}",
          ),
          styles: const PosStyles(fontType: PosFontType.fontA),
        ),
      );

      //================================================
      // OPCIONES COMPACTAS
      //================================================

      final opcionesCompactas = <String>[];
      String? observacion;

      for (final opcionOriginal in item.opciones) {
        final opcion = opcionOriginal.trim();

        if (opcion.isEmpty) {
          continue;
        }

        //==============================================
        // TAMAÑO
        //==============================================

        if (opcion.startsWith('Tamaño:')) {
          final valor = opcion.substring('Tamaño:'.length).trim();

          if (valor.isNotEmpty) {
            opcionesCompactas.add(valor);
          }

          continue;
        }

        //==============================================
        // LECHE
        //==============================================

        if (opcion.startsWith('Leche:')) {
          final valor = opcion.substring('Leche:'.length).trim();

          if (valor.isNotEmpty) {
            opcionesCompactas.add(_abreviarLeche(valor));
          }

          continue;
        }

        //==============================================
        // ENDULZANTE
        //==============================================

        if (opcion.startsWith('Endulzante:')) {
          final valor = opcion.substring('Endulzante:'.length).trim();

          if (valor.isNotEmpty) {
            opcionesCompactas.add(_abreviarEndulzante(valor));
          }

          continue;
        }

        //==============================================
        // INFUSIÓN
        //==============================================

        if (opcion.startsWith('Infusión:')) {
          final valor = opcion.substring('Infusión:'.length).trim();

          if (valor.isNotEmpty) {
            opcionesCompactas.add(valor);
          }

          continue;
        }

        //==============================================
        // EXTRA SHOT
        //==============================================

        if (opcion == 'Extra Shot') {
          opcionesCompactas.add('Extra Shot');
          continue;
        }

        //==============================================
        // OBSERVACIÓN
        //==============================================

        if (opcion.startsWith('Observación:')) {
          observacion = opcion.substring('Observación:'.length).trim();

          continue;
        }

        //==============================================
        // CUALQUIER OTRA OPCIÓN
        //==============================================

        opcionesCompactas.add(opcion);
      }

      //================================================
      // OPCIONES EN UNA SOLA LÍNEA
      //================================================

      if (opcionesCompactas.isNotEmpty) {
        bytes.addAll(
          generator.textEncoded(
            _cp850(opcionesCompactas.join(' | ')),
            styles: const PosStyles(
              align: PosAlign.left,
              width: PosTextSize.size1,
              height: PosTextSize.size1,
            ),
          ),
        );
      }

      //================================================
      // OBSERVACIÓN
      //================================================

      if (observacion != null && observacion.isNotEmpty) {
        bytes.addAll(
          generator.textEncoded(
            _cp850('Obs: $observacion'),
            styles: const PosStyles(
              align: PosAlign.left,
              width: PosTextSize.size1,
              height: PosTextSize.size1,
            ),
          ),
        );
      }

      //================================================
      // SEPARACIÓN PEQUEÑA ENTRE PRODUCTOS
      // Solo se deja separación cuando realmente hay otro
      // producto; una venta de un solo producto queda compacta.
      //================================================

      if (item != ticket.items.last) {
        bytes.addAll(generator.emptyLines(1));
      }
    }

    bytes.addAll(generator.hr());
  }

  //====================================================
  // ABREVIACIONES
  //====================================================

  String _abreviarLeche(String valor) {
    final texto = valor.trim();

    switch (texto.toLowerCase()) {
      case 'deslactosada':
        return 'Deslact.';

      case 'descremada':
        return 'Descrem.';

      case 'vegetal':
        return 'Vegetal';

      default:
        return texto;
    }
  }

  String _abreviarEndulzante(String valor) {
    final texto = valor.trim();

    switch (texto.toLowerCase()) {
      case 'azúcar':
      case 'azucar':
        return 'Azúcar';

      case 'stevia':
        return 'Stevia';

      case 'sin azúcar':
      case 'sin azucar':
        return 'Sin azúcar';

      default:
        return texto;
    }
  }

  //====================================================
  // TOTALES
  //====================================================

  void _renderTotales(Generator generator, List<int> bytes, Ticket ticket) {
    bytes.addAll(
      generator.row([
        PosColumn(
          width: 8,
          textEncoded: _cp850("Subtotal"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          width: 4,
          textEncoded: _cp850(
            "S/ ${ticket.totals.subtotal.toStringAsFixed(2)}",
          ),
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(
      generator.row([
        PosColumn(
          width: 8,
          textEncoded: _cp850("IGV (18%)"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          width: 4,
          textEncoded: _cp850("S/ ${ticket.totals.igv.toStringAsFixed(2)}"),
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );

    bytes.addAll(generator.hr());

    //==================================================
    // TOTAL
    //==================================================

    bytes.addAll(
      generator.row([
        PosColumn(
          width: 7,
          textEncoded: _cp850("TOTAL"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          width: 5,
          textEncoded: _cp850("S/ ${ticket.totals.total.toStringAsFixed(2)}"),
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    );

    //==================================================
    // MÉTODO DE PAGO
    //==================================================

    bytes.addAll(
      generator.row([
        PosColumn(
          width: 5,
          textEncoded: _cp850("Pago:"),
          styles: const PosStyles(bold: true),
        ),
        PosColumn(width: 7, textEncoded: _cp850(ticket.totals.metodoPago)),
      ]),
    );

    bytes.addAll(generator.hr());
  }

  //====================================================
  // PIE
  //====================================================

  void _renderFooter(Generator generator, List<int> bytes, Ticket ticket) {
    //==================================================
    // MENSAJE
    //==================================================

    bytes.addAll(
      generator.textEncoded(
        _cp850(ticket.footer.mensaje),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );

    //==================================================
    // INSTAGRAM
    //==================================================

    bytes.addAll(
      generator.textEncoded(
        _cp850(ticket.empresa.instagram),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
  }
}
