// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarios_dao.dart';

// ignore_for_file: type=lint
mixin _$UsuariosDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsuariosTable get usuarios => attachedDatabase.usuarios;
  UsuariosDaoManager get managers => UsuariosDaoManager(this);
}

class UsuariosDaoManager {
  final _$UsuariosDaoMixin _db;
  UsuariosDaoManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db.attachedDatabase, _db.usuarios);
}
