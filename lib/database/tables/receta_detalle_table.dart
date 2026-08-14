import 'package:drift/drift.dart';

class RecetaDetalle extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();

  // Receta
  IntColumn get recetaId => integer()();

  // Insumo
  IntColumn get insumoId => integer()();

  // Cantidad utilizada
  RealColumn get cantidad =>
      real().withDefault(const Constant(0))();

  // Unidad
  TextColumn get unidad =>
      text().withDefault(const Constant('unid'))();

  // Orden de aparición
  IntColumn get orden =>
      integer().withDefault(const Constant(0))();
}