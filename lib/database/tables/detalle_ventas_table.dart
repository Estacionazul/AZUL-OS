import 'package:drift/drift.dart';

class DetalleVentas extends Table {
  //==========================
  // ID
  //==========================

  IntColumn get id => integer().autoIncrement()();

  //==========================
  // Venta
  //==========================

  IntColumn get ventaId => integer()();

  //==========================
  // Producto
  //==========================

  IntColumn get productoId => integer()();

  TextColumn get nombreProducto => text()();

  //==========================
  // Cantidad
  //==========================

  IntColumn get cantidad =>
      integer().withDefault(const Constant(1))();

  //==========================
  // Precio
  //==========================

  RealColumn get precioUnitario =>
      real().withDefault(const Constant(0))();

  RealColumn get subtotal =>
      real().withDefault(const Constant(0))();

  //==========================
  // Personalización
  //==========================

  TextColumn get tamano => text().nullable()();

  TextColumn get tipoLeche => text().nullable()();

  TextColumn get endulzante => text().nullable()();

  TextColumn get infusion => text().nullable()();

  BoolColumn get extraShot =>
      boolean().withDefault(const Constant(false))();

  TextColumn get observaciones => text().nullable()();
}