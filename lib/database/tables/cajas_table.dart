import 'package:drift/drift.dart';

class Cajas extends Table {
  // ==========================================================
  // ID
  // ==========================================================

  IntColumn get id => integer().autoIncrement()();

  // ==========================================================
  // APERTURA
  // ==========================================================

  DateTimeColumn get fechaApertura =>
      dateTime().withDefault(currentDateAndTime)();

  RealColumn get montoInicial =>
      real().withDefault(const Constant(0))();

  // ==========================================================
  // CIERRE
  // ==========================================================

  DateTimeColumn get fechaCierre =>
      dateTime().nullable()();

  RealColumn get montoCierre =>
      real().nullable()();

  // ==========================================================
  // ESTADO
  // ==========================================================

  TextColumn get estado =>
      text().withDefault(const Constant('ABIERTA'))();

  // ==========================================================
  // OBSERVACIONES
  // ==========================================================

  TextColumn get observaciones =>
      text().nullable()();
}