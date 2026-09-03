import 'package:drift/drift.dart';

class MovimientosInventario extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  TextColumn get tipo => text()();

  // Nombre del artículo al momento del movimiento
  TextColumn get nombreItem => text().withDefault(const Constant(''))();

  // Emoji del artículo
  TextColumn get emoji => text().withDefault(const Constant('📦'))();

  // Unidad del artículo
  TextColumn get unidad => text().withDefault(const Constant(''))();

  IntColumn get referenciaId => integer().nullable()();

  IntColumn get insumoId => integer().nullable()();

  IntColumn get productoId => integer().nullable()();

  RealColumn get cantidad => real()();

  IntColumn get signo => integer()();

  TextColumn get observacion => text().nullable()();
}
