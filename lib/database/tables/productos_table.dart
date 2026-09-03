import 'package:drift/drift.dart';

class Productos extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();

  // Código interno (ej. CAF001)
  TextColumn get codigo => text().unique()();

  // Código de barras (opcional)
  TextColumn get codigoBarras => text().nullable()();

  // Nombre del producto
  TextColumn get nombre => text()();

  // Descripción
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  // Relación con Categorías
  IntColumn get categoriaId => integer()();

  // Costos
  RealColumn get costo => real()();

  // Precio de venta
  RealColumn get precioVenta => real()();

  // Inventario
  IntColumn get stock => integer().withDefault(const Constant(0))();

  IntColumn get stockMinimo => integer().withDefault(const Constant(0))();

  // Tipo de inventario
  // receta = descuenta insumos
  // producto = descuenta stock del producto
  TextColumn get tipoInventario =>
      text().withDefault(const Constant('receta'))();

  // Apariencia
  TextColumn get emoji => text().withDefault(const Constant('📦'))();

  TextColumn get imagen => text().withDefault(const Constant(''))();

  // Estado
  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  // Auditoría
  DateTimeColumn get fechaCreacion =>
      dateTime().withDefault(currentDateAndTime)();
}
