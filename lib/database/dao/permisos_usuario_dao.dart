import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/permisos_usuario_table.dart';

part 'permisos_usuario_dao.g.dart';

@DriftAccessor(tables: [PermisosUsuario])
class PermisosUsuarioDao extends DatabaseAccessor<AppDatabase>
    with _$PermisosUsuarioDaoMixin {
  PermisosUsuarioDao(AppDatabase db) : super(db);

  // ==========================================================
  // CREAR PERMISO
  // ==========================================================

  Future<int> crearPermiso(
    PermisosUsuarioCompanion permiso,
  ) {
    return into(permisosUsuario).insert(permiso);
  }

  // ==========================================================
  // OBTENER TODOS LOS PERMISOS DE UN USUARIO
  // ==========================================================

  Future<List<PermisosUsuarioData>> obtenerPorUsuario(
    int usuarioId,
  ) {
    return (select(permisosUsuario)
          ..where((p) => p.usuarioId.equals(usuarioId))
          ..orderBy([
            (p) => OrderingTerm(expression: p.modulo),
          ]))
        .get();
  }

  // ==========================================================
  // OBTENER UN PERMISO ESPECIFICO
  // ==========================================================

  Future<PermisosUsuarioData?> obtenerPermiso(
    int usuarioId,
    String modulo,
  ) {
    return (select(permisosUsuario)
          ..where(
            (p) =>
                p.usuarioId.equals(usuarioId) &
                p.modulo.equals(modulo),
          ))
        .getSingleOrNull();
  }

  // ==========================================================
  // COMPROBAR PERMISO
  // ==========================================================

  Future<bool> tienePermiso(
    int usuarioId,
    String modulo,
  ) async {
    final permiso = await obtenerPermiso(
      usuarioId,
      modulo,
    );

    return permiso?.permitido ?? false;
  }

  // ==========================================================
  // CAMBIAR PERMISO
  // ==========================================================

  Future<bool> cambiarPermiso(
    int usuarioId,
    String modulo,
    bool permitido,
  ) async {
    final existente = await obtenerPermiso(
      usuarioId,
      modulo,
    );

    if (existente == null) {
      await crearPermiso(
        PermisosUsuarioCompanion.insert(
          usuarioId: usuarioId,
          modulo: modulo,
          permitido: Value(permitido),
        ),
      );

      return true;
    }

    await (update(permisosUsuario)
          ..where((p) => p.id.equals(existente.id)))
        .write(
      PermisosUsuarioCompanion(
        permitido: Value(permitido),
      ),
    );

    return true;
  }

  // ==========================================================
  // ELIMINAR PERMISOS DE UN USUARIO
  // ==========================================================

  Future<int> eliminarPermisosUsuario(
    int usuarioId,
  ) {
    return (delete(permisosUsuario)
          ..where((p) => p.usuarioId.equals(usuarioId)))
        .go();
  }
}
