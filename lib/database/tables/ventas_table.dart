import 'package:drift/drift.dart';

class Ventas extends Table {
  //==========================
  // ID
  //==========================

  IntColumn get id => integer().autoIncrement()();

  //==========================
  // Número de venta
  //==========================

  TextColumn get numero => text().unique()();

  //==========================
  // Fecha
  //==========================

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  //==========================
  // Documento
  //==========================

  TextColumn get tipoDocumento =>
      text().withDefault(const Constant('Nota de Venta'))();

  //==========================
  // Cliente
  //==========================

  TextColumn get dni => text().nullable()();

  TextColumn get ruc => text().nullable()();

  TextColumn get nombreCliente => text().nullable()();

  TextColumn get razonSocial => text().nullable()();

  TextColumn get direccionFiscal => text().nullable()();

  //==========================
  // Totales
  //==========================

  RealColumn get subtotal => real().withDefault(const Constant(0))();

  RealColumn get igv => real().withDefault(const Constant(0))();

  RealColumn get descuento => real().withDefault(const Constant(0))();

  RealColumn get total => real().withDefault(const Constant(0))();

  //==========================
  // Pago
  //==========================

  TextColumn get metodoPago => text().withDefault(const Constant('Efectivo'))();

  //==========================
  // Observaciones
  //==========================

  TextColumn get observaciones => text().nullable()();
}
