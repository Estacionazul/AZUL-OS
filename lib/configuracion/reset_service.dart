
import '../database/app_database.dart';

class ResetService {
  final AppDatabase db;

  ResetService(this.db);

  /// Limpia únicamente datos operativos de prueba.
  ///
  /// NO elimina:
  /// - comprobantes electrónicos
  /// - correlativos
  /// - productos
  /// - insumos
  /// - recetas
  /// - clientes
  /// - empresa
  /// - usuarios
  /// - permisos
  /// - movimientos de inventario
  ///
  /// Los movimientos de inventario se conservan porque el stock
  /// actual de los insumos depende de ellos.
  Future<void> limpiarDatosOperativosPrueba() async {
    await db.transaction(() async {
      // Primero los detalles.
      await db.delete(db.detalleVentas).go();
      await db.delete(db.pedidoDetalles).go();

      // Luego las cabeceras.
      await db.delete(db.ventas).go();
      await db.delete(db.pedidos).go();

      // Finalmente movimientos de caja.
      await db.delete(db.movimientosCaja).go();
    });
  }
}
