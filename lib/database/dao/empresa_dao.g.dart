// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empresa_dao.dart';

// ignore_for_file: type=lint
mixin _$EmpresaDaoMixin on DatabaseAccessor<AppDatabase> {
  $EmpresaTable get empresa => attachedDatabase.empresa;
  EmpresaDaoManager get managers => EmpresaDaoManager(this);
}

class EmpresaDaoManager {
  final _$EmpresaDaoMixin _db;
  EmpresaDaoManager(this._db);
  $$EmpresaTableTableManager get empresa =>
      $$EmpresaTableTableManager(_db.attachedDatabase, _db.empresa);
}
