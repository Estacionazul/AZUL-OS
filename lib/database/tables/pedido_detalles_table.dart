import 'package:drift/drift.dart';

class PedidoDetalles extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedidoId => integer()();

  IntColumn get productoId => integer()();

  TextColumn get codigoProducto => text()();

  TextColumn get nombreProducto => text()();

  IntColumn get cantidad =>
      integer().withDefault(const Constant(1))();

  IntColumn get cantidadComandada =>
      integer().withDefault(const Constant(0))();

  RealColumn get precioUnitario =>
      real().withDefault(const Constant(0))();

  RealColumn get subtotal =>
      real().withDefault(const Constant(0))();

  TextColumn get tamano => text().nullable()();

  TextColumn get tipoLeche => text().nullable()();

  TextColumn get endulzante => text().nullable()();

  TextColumn get infusion => text().nullable()();

  BoolColumn get extraShot =>
      boolean().withDefault(const Constant(false))();

  TextColumn get observaciones => text().nullable()();

  IntColumn get orden =>
      integer().withDefault(const Constant(0))();
}