import 'package:drift/drift.dart';

class Recetas extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();

  // Producto al que pertenece la receta
  IntColumn get productoId => integer().unique()();

  // Nombre de la receta
  TextColumn get nombre => text()();

  // Estado
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  // Auditoría
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
}
