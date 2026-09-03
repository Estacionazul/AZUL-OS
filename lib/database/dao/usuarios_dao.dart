import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/usuarios_table.dart';

part 'usuarios_dao.g.dart';

@DriftAccessor(tables: [Usuarios])
class UsuariosDao extends DatabaseAccessor<AppDatabase>
    with _$UsuariosDaoMixin {
  UsuariosDao(AppDatabase db) : super(db);

  Future<int> crearUsuario(UsuariosCompanion usuario) {
    return into(usuarios).insert(usuario);
  }

  Future<List<Usuario>> obtenerUsuarios() {
    return (select(
      usuarios,
    )..orderBy([(u) => OrderingTerm(expression: u.nombre)])).get();
  }

  Future<List<Usuario>> obtenerUsuariosActivos() {
    return (select(usuarios)
          ..where((u) => u.activo.equals(true))
          ..orderBy([(u) => OrderingTerm(expression: u.nombre)]))
        .get();
  }

  Future<Usuario?> obtenerPorId(int id) {
    return (select(usuarios)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<Usuario?> obtenerPorNombre(String nombre) {
    return (select(
      usuarios,
    )..where((u) => u.nombre.equals(nombre))).getSingleOrNull();
  }

  Future<Usuario?> validarAcceso(String nombre, String pin) {
    return (select(usuarios)..where(
          (u) =>
              u.nombre.equals(nombre) &
              u.pin.equals(pin) &
              u.activo.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<bool> actualizarUsuario(UsuariosCompanion usuario) {
    return update(usuarios).replace(usuario);
  }

  Future<int> cambiarEstado(int id, bool activo) {
    return (update(usuarios)..where((u) => u.id.equals(id))).write(
      UsuariosCompanion(activo: Value(activo)),
    );
  }

  Future<int> eliminarUsuario(int id) {
    return (delete(usuarios)..where((u) => u.id.equals(id))).go();
  }
}
