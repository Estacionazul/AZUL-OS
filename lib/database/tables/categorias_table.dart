import 'package:drift/drift.dart';

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().unique()();

  TextColumn get icono => text().withDefault(const Constant('📦'))();

  IntColumn get orden => integer().withDefault(const Constant(0))();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}
