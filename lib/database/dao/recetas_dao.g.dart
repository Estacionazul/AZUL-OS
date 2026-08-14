// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recetas_dao.dart';

// ignore_for_file: type=lint
mixin _$RecetasDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecetasTable get recetas => attachedDatabase.recetas;
  RecetasDaoManager get managers => RecetasDaoManager(this);
}

class RecetasDaoManager {
  final _$RecetasDaoMixin _db;
  RecetasDaoManager(this._db);
  $$RecetasTableTableManager get recetas =>
      $$RecetasTableTableManager(_db.attachedDatabase, _db.recetas);
}
