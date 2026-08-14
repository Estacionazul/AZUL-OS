import 'package:drift/drift.dart';

class Empresa extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text()();

  TextColumn get ruc => text()();
  TextColumn get tipoContribuyente =>
      text().withDefault(
        const Constant('RUC10'),
      )();

  TextColumn get direccion => text().nullable()();

  TextColumn get telefono => text().nullable()();

  TextColumn get instagram => text().nullable()();

  TextColumn get logo => text().nullable()();

  TextColumn get serieBoleta =>
      text().withDefault(const Constant('B001'))();

  TextColumn get serieFactura =>
      text().withDefault(const Constant('F001'))();

  IntColumn get correlativoBoleta =>
      integer().withDefault(const Constant(1))();

  IntColumn get correlativoFactura =>
      integer().withDefault(const Constant(1))();

  RealColumn get igv =>
      real().withDefault(const Constant(18))();

  TextColumn get moneda =>
      text().withDefault(const Constant('PEN'))();

  TextColumn get impresora =>
      text().nullable()();
}