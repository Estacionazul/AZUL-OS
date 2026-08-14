import '../printer/printer_adapter.dart';

/// Servicio encargado de coordinar el proceso de impresión.
///
/// No conoce cómo se construye un ticket.
/// No conoce la plataforma (Windows o Android).
/// No conoce el contenido del ticket.
///
/// Su única responsabilidad es enviar los bytes generados
/// por el motor ESC/POS a la impresora mediante un
/// [PrinterAdapter].
class PrinterService {
  final PrinterAdapter _printerAdapter;

  const PrinterService(this._printerAdapter);

  /// Verifica si existe una impresora disponible.
  Future<bool> isPrinterConnected() {
    return _printerAdapter.isConnected();
  }

  /// Envía un ticket ya convertido a comandos ESC/POS.
  ///
  /// [bytes] debe contener el ticket completo listo para imprimir.
  Future<void> print(List<int> bytes) async {
    final connected = await _printerAdapter.isConnected();

    if (!connected) {
      throw Exception(
        'No se encontró una impresora disponible para imprimir.',
      );
    }

    await _printerAdapter.printTicket(bytes);
  }
}