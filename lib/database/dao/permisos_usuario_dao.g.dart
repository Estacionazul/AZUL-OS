// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permisos_usuario_dao.dart';

// ignore_for_file: type=lint
mixin _$PermisosUsuarioDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsuariosTable get usuarios => attachedDatabase.usuarios;
  $PermisosUsuarioTable get permisosUsuario => attachedDatabase.permisosUsuario;
  PermisosUsuarioDaoManager get managers => PermisosUsuarioDaoManager(this);
}

class PermisosUsuarioDaoManager {
  final _$PermisosUsuarioDaoMixin _db;
  PermisosUsuarioDaoManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db.attachedDatabase, _db.usuarios);
  $$PermisosUsuarioTableTableManager get permisosUsuario =>
      $$PermisosUsuarioTableTableManager(
        _db.attachedDatabase,
        _db.permisosUsuario,
      );
}
