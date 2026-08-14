// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productos_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductosDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductosTable get productos => attachedDatabase.productos;
  ProductosDaoManager get managers => ProductosDaoManager(this);
}

class ProductosDaoManager {
  final _$ProductosDaoMixin _db;
  ProductosDaoManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db.attachedDatabase, _db.productos);
}
