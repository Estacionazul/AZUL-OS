// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cajas_dao.dart';

// ignore_for_file: type=lint
mixin _$CajasDaoMixin on DatabaseAccessor<AppDatabase> {
  $CajasTable get cajas => attachedDatabase.cajas;
  $MovimientosCajaTable get movimientosCaja => attachedDatabase.movimientosCaja;
  CajasDaoManager get managers => CajasDaoManager(this);
}

class CajasDaoManager {
  final _$CajasDaoMixin _db;
  CajasDaoManager(this._db);
  $$CajasTableTableManager get cajas =>
      $$CajasTableTableManager(_db.attachedDatabase, _db.cajas);
  $$MovimientosCajaTableTableManager get movimientosCaja =>
      $$MovimientosCajaTableTableManager(
        _db.attachedDatabase,
        _db.movimientosCaja,
      );
}
