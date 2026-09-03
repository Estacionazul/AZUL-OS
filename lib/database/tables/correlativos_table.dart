import 'package:drift/drift.dart';

class Correlativos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get clave => text().unique()();

  IntColumn get ultimoNumero => integer().withDefault(const Constant(0))();
}
