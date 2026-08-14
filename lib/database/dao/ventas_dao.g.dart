// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ventas_dao.dart';

// ignore_for_file: type=lint
mixin _$VentasDaoMixin on DatabaseAccessor<AppDatabase> {
  $VentasTable get ventas => attachedDatabase.ventas;
  $DetalleVentasTable get detalleVentas => attachedDatabase.detalleVentas;
  VentasDaoManager get managers => VentasDaoManager(this);
}

class VentasDaoManager {
  final _$VentasDaoMixin _db;
  VentasDaoManager(this._db);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db.attachedDatabase, _db.ventas);
  $$DetalleVentasTableTableManager get detalleVentas =>
      $$DetalleVentasTableTableManager(_db.attachedDatabase, _db.detalleVentas);
}
