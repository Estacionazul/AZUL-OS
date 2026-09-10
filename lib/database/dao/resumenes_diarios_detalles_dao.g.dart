// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resumenes_diarios_detalles_dao.dart';

// ignore_for_file: type=lint
mixin _$ResumenesDiariosDetallesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ResumenesDiariosDetallesTable get resumenesDiariosDetalles =>
      attachedDatabase.resumenesDiariosDetalles;
  ResumenesDiariosDetallesDaoManager get managers =>
      ResumenesDiariosDetallesDaoManager(this);
}

class ResumenesDiariosDetallesDaoManager {
  final _$ResumenesDiariosDetallesDaoMixin _db;
  ResumenesDiariosDetallesDaoManager(this._db);
  $$ResumenesDiariosDetallesTableTableManager get resumenesDiariosDetalles =>
      $$ResumenesDiariosDetallesTableTableManager(
        _db.attachedDatabase,
        _db.resumenesDiariosDetalles,
      );
}
