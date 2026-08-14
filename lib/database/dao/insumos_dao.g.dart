// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insumos_dao.dart';

// ignore_for_file: type=lint
mixin _$InsumosDaoMixin on DatabaseAccessor<AppDatabase> {
  $InsumosTable get insumos => attachedDatabase.insumos;
  InsumosDaoManager get managers => InsumosDaoManager(this);
}

class InsumosDaoManager {
  final _$InsumosDaoMixin _db;
  InsumosDaoManager(this._db);
  $$InsumosTableTableManager get insumos =>
      $$InsumosTableTableManager(_db.attachedDatabase, _db.insumos);
}
