import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'printer_adapter.dart';
import 'raw_printer.dart';

class WindowsPrinterAdapter implements PrinterAdapter {
  String? _selectedPrinter;

  RawPrinter? _rawPrinter;

  WindowsPrinterAdapter();

  @override
  Future<List<String>> discoverPrinters() async {
    final printers = <String>[];

    final flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;

    final needed = calloc<Uint32>();
    final returned = calloc<Uint32>();

    try {
      EnumPrinters(
        flags,
        nullptr,
        2,
        nullptr,
        0,
        needed,
        returned,
      );

      if (needed.value == 0) {
        return printers;
      }

      final buffer = calloc<Uint8>(needed.value);

      try {
        final result = EnumPrinters(
          flags,
          nullptr,
          2,
          buffer,
          needed.value,
          needed,
          returned,
        );

        if (result == 0) {
          return printers;
        }

        final printersInfo = buffer.cast<PRINTER_INFO_2>();

        for (var i = 0; i < returned.value; i++) {
          final printer = printersInfo[i];

          if (printer.pPrinterName != nullptr) {
            final name = printer.pPrinterName
                .cast<Utf16>()
                .toDartString();

            if (name.isNotEmpty) {
              printers.add(name);
            }
          }
        }
      } finally {
        calloc.free(buffer);
      }
    } finally {
      calloc.free(needed);
      calloc.free(returned);
    }

    print('===== IMPRESORAS DETECTADAS EN WINDOWS =====');

    for (final printer in printers) {
      print('🖨️ $printer');
    }

    print('===== FIN IMPRESORAS =====');

    return printers;
  }

  @override
  Future<void> selectPrinter(String printerName) async {
    if (printerName.trim().isEmpty) {
      throw ArgumentError(
        'El nombre de la impresora no puede estar vacío.',
      );
    }

    _selectedPrinter = printerName;
    _rawPrinter = RawPrinter(printerName);

    print(
      '===== IMPRESORA WINDOWS SELECCIONADA =====',
    );
    print(_selectedPrinter);
  }

  @override
  Future<bool> isConnected() async {
    if (_selectedPrinter == null ||
        _selectedPrinter!.trim().isEmpty) {
      return false;
    }

    final printers = await discoverPrinters();

    return printers.contains(_selectedPrinter);
  }

  @override
  Future<void> printTicket(List<int> bytes) async {
    final printer = _rawPrinter;

    if (printer == null) {
      throw Exception(
        'No hay una impresora Windows seleccionada.',
      );
    }

    await printer.send(bytes);
  }

  @override
  Future<void> disconnect() async {
    _selectedPrinter = null;
    _rawPrinter = null;

    print(
      '===== IMPRESORA WINDOWS DESCONECTADA =====',
    );
  }
}