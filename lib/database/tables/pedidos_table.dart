import 'package:drift/drift.dart';

class Pedidos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get numero => text().unique()();

  TextColumn get ubicacionId => text()();

  TextColumn get ubicacionNombre => text()();

  BoolColumn get esMesa =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get fechaApertura =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get estado =>
      text().withDefault(const Constant('abierto'))();

  IntColumn get numeroComanda =>
      integer().withDefault(const Constant(0))();

  TextColumn get observaciones =>
      text().withDefault(const Constant(''))();

  RealColumn get total =>
      real().withDefault(const Constant(0))();
}