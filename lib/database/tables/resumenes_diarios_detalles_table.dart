import 'package:drift/drift.dart';

class ResumenesDiariosDetalles extends Table {
  // ==========================================================
  // ID
  // ==========================================================

  IntColumn get id => integer().autoIncrement()();

  // ==========================================================
  // RELACIÓN CON EL RESUMEN DIARIO
  // ==========================================================

  /// Resumen Diario al que pertenece esta línea.
  IntColumn get resumenDiarioId => integer()();

  // ==========================================================
  // RELACIÓN CON EL COMPROBANTE
  // ==========================================================

  /// Comprobante electrónico incluido en esta línea.
  IntColumn get comprobanteElectronicoId => integer()();

  // ==========================================================
  // LÍNEA DEL XML
  // ==========================================================

  /// Número de línea del comprobante dentro del SummaryDocuments.
  ///
  /// Ejemplo:
  /// 1 = primera boleta
  /// 2 = segunda boleta
  /// 3 = tercera boleta
  IntColumn get lineId => integer()();

  // ==========================================================
  // REGLAS DE UNICIDAD
  // ==========================================================

  /// Una misma boleta no puede aparecer dos veces
  /// dentro del mismo Resumen Diario.
  @override
  List<Set<Column>> get uniqueKeys => [
    {resumenDiarioId, comprobanteElectronicoId},
  ];
}