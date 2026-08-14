import 'package:drift/drift.dart';

class Insumos extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();

  // Código interno
  TextColumn get codigo => text().unique()();

  // Nombre
  TextColumn get nombre => text()();

  // Descripción
  TextColumn get descripcion =>
      text().withDefault(const Constant(''))();

  // Categoría
  IntColumn get categoriaId => integer()();

  // Unidad base:
  // g | ml | unid
  TextColumn get unidadMedida => text()();

  // Stock actual
  RealColumn get stock =>
      real().withDefault(const Constant(0))();

  // Stock mínimo
  RealColumn get stockMinimo =>
      real().withDefault(const Constant(0))();

  // Costo de compra
  RealColumn get costoCompra =>
      real().withDefault(const Constant(0))();

  // Apariencia
  TextColumn get emoji =>
      text().withDefault(const Constant('📦'))();

  TextColumn get imagen =>
      text().withDefault(const Constant(''))();

  // Estado
  BoolColumn get activo =>
      boolean().withDefault(const Constant(true))();

  // Auditoría
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
}