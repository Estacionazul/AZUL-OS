// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movimientos_inventario_dao.dart';

// ignore_for_file: type=lint
mixin _$MovimientosInventarioDaoMixin on DatabaseAccessor<AppDatabase> {
  $MovimientosInventarioTable get movimientosInventario =>
      attachedDatabase.movimientosInventario;
  MovimientosInventarioDaoManager get managers =>
      MovimientosInventarioDaoManager(this);
}

class MovimientosInventarioDaoManager {
  final _$MovimientosInventarioDaoMixin _db;
  MovimientosInventarioDaoManager(this._db);
  $$MovimientosInventarioTableTableManager get movimientosInventario =>
      $$MovimientosInventarioTableTableManager(
        _db.attachedDatabase,
        _db.movimientosInventario,
      );
}
