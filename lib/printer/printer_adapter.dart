/// Contrato base para cualquier sistema de impresión compatible con AZUL OS.
///
/// Esta interfaz desacopla el resto del sistema de cualquier librería o
/// tecnología de impresión.
///
/// Implementaciones:
/// - WindowsPrinterAdapter (USB)
/// - AndroidPrinterAdapter (Bluetooth)
/// - NetworkPrinterAdapter (Ethernet/WiFi)
abstract class PrinterAdapter {
  const PrinterAdapter();

  /// Devuelve los nombres de las impresoras disponibles.
  Future<List<String>> discoverPrinters();

  /// Selecciona la impresora que será utilizada.
  Future<void> selectPrinter(String printerName);

  /// Imprime una secuencia de comandos ESC/POS.
  Future<void> printTicket(List<int> bytes);

  /// Indica si existe una impresora seleccionada y disponible.
  Future<bool> isConnected();

  /// Libera la conexión con la impresora.
  Future<void> disconnect();
}