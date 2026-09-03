import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

enum PrinterDataType {
  raw('RAW'),
  text('TEXT'),
  xpsPass('XPS_PASS');

  const PrinterDataType(this.value);

  final String value;
}

final class RawPrinter {
  const RawPrinter(this.printerName);

  final String printerName;

  Future<void> send(
    List<int> bytes, {
    String documentName = 'Ticket Estación Azul',
    PrinterDataType dataType = PrinterDataType.raw,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('No se puede imprimir un documento vacío.');
    }

    print('');
    print('==========================================');
    print('        RAW PRINTER - INICIO');
    print('==========================================');

    print('🖨️ Impresora: $printerName');
    print('📄 Documento: $documentName');
    print('📦 Bytes: ${bytes.length}');
    print('📡 Tipo: ${dataType.value}');

    using((arena) {
      print('');
      print('1️⃣ Preparando nombre de impresora...');

      final printerNamePtr = printerName.toNativeUtf16(allocator: arena);

      final printerHandlePtr = arena<IntPtr>();

      print('2️⃣ Ejecutando OpenPrinter()...');

      final opened = OpenPrinter(printerNamePtr, printerHandlePtr, nullptr);

      print('3️⃣ OpenPrinter() terminó.');
      print('   Resultado: $opened');

      if (opened == 0) {
        final error = GetLastError();

        throw Exception(
          'No se pudo abrir la impresora "$printerName". '
          'Código de Windows: $error',
        );
      }

      print('✅ OpenPrinter OK');

      final printerHandle = printerHandlePtr.value;

      print('🔑 Handle: $printerHandle');

      var documentStarted = false;
      var pageStarted = false;

      try {
        print('');
        print('4️⃣ Preparando DOC_INFO_1...');

        final docInfo = arena<DOC_INFO_1>();

        docInfo.ref.pDocName = documentName.toNativeUtf16(allocator: arena);

        docInfo.ref.pDatatype = dataType.value.toNativeUtf16(allocator: arena);

        docInfo.ref.pOutputFile = nullptr;

        print('5️⃣ Ejecutando StartDocPrinter()...');

        final jobId = StartDocPrinter(printerHandle, 1, docInfo);

        print('6️⃣ StartDocPrinter() terminó.');
        print('   Job ID: $jobId');

        if (jobId == 0) {
          final error = GetLastError();

          throw Exception(
            'No se pudo iniciar el trabajo de impresión. '
            'Código de Windows: $error',
          );
        }

        documentStarted = true;

        print('✅ StartDocPrinter OK');

        print('');
        print('7️⃣ Ejecutando StartPagePrinter()...');

        final pageResult = StartPagePrinter(printerHandle);

        print('8️⃣ StartPagePrinter() terminó.');
        print('   Resultado: $pageResult');

        if (pageResult == 0) {
          final error = GetLastError();

          throw Exception(
            'No se pudo iniciar la página de impresión. '
            'Código de Windows: $error',
          );
        }

        pageStarted = true;

        print('✅ StartPagePrinter OK');

        print('');
        print('9️⃣ Preparando buffer de ${bytes.length} bytes...');

        final buffer = arena<Uint8>(bytes.length);

        for (var i = 0; i < bytes.length; i++) {
          buffer[i] = bytes[i];
        }

        print('🔟 Buffer preparado.');

        final written = arena<Uint32>();

        print('');
        print('1️⃣1️⃣ EJECUTANDO WritePrinter()...');
        print('⚠️ Si la consola se queda aquí, encontramos el problema.');

        final writeResult = WritePrinter(
          printerHandle,
          buffer,
          bytes.length,
          written,
        );

        print('');
        print('1️⃣2️⃣ WritePrinter() terminó.');
        print('   Resultado: $writeResult');
        print('   Bytes escritos: ${written.value}');

        if (writeResult == 0) {
          final error = GetLastError();

          throw Exception(
            'No se pudieron enviar los datos a la impresora. '
            'Código de Windows: $error',
          );
        }

        if (written.value != bytes.length) {
          throw Exception(
            'La impresora recibió ${written.value} bytes '
            'de ${bytes.length} bytes esperados.',
          );
        }

        print('✅ WritePrinter OK');

        print('');
        print('1️⃣3️⃣ Ejecutando EndPagePrinter()...');

        final pageEnded = EndPagePrinter(printerHandle);

        print('1️⃣4️⃣ EndPagePrinter() terminó.');
        print('   Resultado: $pageEnded');

        if (pageEnded == 0) {
          final error = GetLastError();

          throw Exception(
            'No se pudo finalizar la página de impresión. '
            'Código de Windows: $error',
          );
        }

        pageStarted = false;

        print('✅ EndPagePrinter OK');

        print('');
        print('1️⃣5️⃣ Ejecutando EndDocPrinter()...');

        final documentEnded = EndDocPrinter(printerHandle);

        print('1️⃣6️⃣ EndDocPrinter() terminó.');
        print('   Resultado: $documentEnded');

        if (documentEnded == 0) {
          final error = GetLastError();

          throw Exception(
            'No se pudo finalizar el trabajo de impresión. '
            'Código de Windows: $error',
          );
        }

        documentStarted = false;

        print('✅ EndDocPrinter OK');

        print('');
        print('==========================================');
        print('       ✅ RAW PRINTER FINALIZADO');
        print('==========================================');
      } finally {
        print('');
        print('🧹 Ejecutando limpieza...');

        if (pageStarted) {
          print('🧹 Cerrando página...');
          EndPagePrinter(printerHandle);
        }

        if (documentStarted) {
          print('🧹 Cerrando documento...');
          EndDocPrinter(printerHandle);
        }

        print('🧹 Cerrando impresora...');

        ClosePrinter(printerHandle);

        print('✅ Limpieza terminada.');
      }
    });
  }
}
