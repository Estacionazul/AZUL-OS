import 'printer_adapter.dart';

/// Adaptador seguro para plataformas sin impresión integrada.
/// No simula una conexión ni envía tickets.
class NoPrinterAdapter implements PrinterAdapter {
  const NoPrinterAdapter();

  @override
  Future<List<String>> discoverPrinters() async => <String>[];

  @override
  Future<void> selectPrinter(String printerName) async {
    throw UnsupportedError(
      'La impresión no está configurada en esta plataforma.',
    );
  }

  @override
  Future<void> printTicket(List<int> bytes) async {
    throw UnsupportedError(
      'La impresión no está configurada en esta plataforma.',
    );
  }

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<void> disconnect() async {}
}
