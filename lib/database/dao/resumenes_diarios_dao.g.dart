// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resumenes_diarios_dao.dart';

// ignore_for_file: type=lint
mixin _$ResumenesDiariosDaoMixin on DatabaseAccessor<AppDatabase> {
  $ResumenesDiariosTable get resumenesDiarios =>
      attachedDatabase.resumenesDiarios;
  ResumenesDiariosDaoManager get managers => ResumenesDiariosDaoManager(this);
}

class ResumenesDiariosDaoManager {
  final _$ResumenesDiariosDaoMixin _db;
  ResumenesDiariosDaoManager(this._db);
  $$ResumenesDiariosTableTableManager get resumenesDiarios =>
      $$ResumenesDiariosTableTableManager(
        _db.attachedDatabase,
        _db.resumenesDiarios,
      );
}
