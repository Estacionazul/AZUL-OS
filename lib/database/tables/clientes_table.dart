import 'package:drift/drift.dart';

class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text()();

  TextColumn get dni => text().nullable()();

  TextColumn get ruc => text().nullable()();

  TextColumn get telefono => text().nullable()();

  TextColumn get correo => text().nullable()();

  TextColumn get direccion => text().nullable()();

  DateTimeColumn get fechaRegistro =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get ultimaVisita =>
      dateTime().nullable()();

  RealColumn get totalGastado =>
      real().withDefault(const Constant(0))();

  IntColumn get cantidadCompras =>
      integer().withDefault(const Constant(0))();

  TextColumn get observaciones =>
      text().nullable()();
}