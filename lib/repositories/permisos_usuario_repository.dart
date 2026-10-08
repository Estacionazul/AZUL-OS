import '../database/app_database.dart';
import '../database/dao/permisos_usuario_dao.dart';

class PermisosUsuarioRepository {
  final PermisosUsuarioDao _dao;

  PermisosUsuarioRepository(AppDatabase database)
    : _dao = PermisosUsuarioDao(database);

  // ==========================================================
  // OBTENER PERMISOS DE UN USUARIO
  // ==========================================================

  Future<List<PermisosUsuarioData>> obtenerPorUsuario(int usuarioId) {
    return _dao.obtenerPorUsuario(usuarioId);
  }

  // ==========================================================
  // OBTENER UN PERMISO
  // ==========================================================

  Future<PermisosUsuarioData?> obtenerPermiso(int usuarioId, String modulo) {
    return _dao.obtenerPermiso(usuarioId, modulo);
  }

  // ==========================================================
  // COMPROBAR PERMISO
  // ==========================================================

  Future<bool> tienePermiso(int usuarioId, String modulo) {
    return _dao.tienePermiso(usuarioId, modulo);
  }

  // ==========================================================
  // CAMBIAR PERMISO
  // ==========================================================

  Future<bool> cambiarPermiso(int usuarioId, String modulo, bool permitido) {
    return _dao.cambiarPermiso(usuarioId, modulo, permitido);
  }

  // ==========================================================
  // ELIMINAR TODOS LOS PERMISOS DE UN USUARIO
  // ==========================================================

  Future<int> eliminarPermisosUsuario(int usuarioId) {
    return _dao.eliminarPermisosUsuario(usuarioId);
  }

  // ==========================================================
  // APLICAR PERFIL OPERATIVO SEGÚN EL ROL
  // ==========================================================

  Future<void> inicializarPerfilPorRol(
    int usuarioId,
    String rol,
  ) async {
    // Los permisos se establecen una sola vez como perfil inicial.
    // Después, el CEO puede personalizarlos sin que un nuevo login
    // vuelva a sobrescribir sus decisiones.
    final existentes = await obtenerPorUsuario(usuarioId);

    if (existentes.isNotEmpty) {
      return;
    }

    final rolNormalizado = rol.trim().toUpperCase();

    if (rolNormalizado == 'CAJERO') {
      const permisosCajero = <String, bool>{
        'CAFETERIA': true,
        'PRODUCTOS': false,
        'INVENTARIO': false,
        'RECETAS': false,
        'PRODUCCION': false,
        'PEDIDOS': true,
        'VENTAS': true,
        'CLIENTES': true,
        'CAJA': true,
        'REPORTES': false,
        'CONFIGURACION': false,
      };

      for (final entry in permisosCajero.entries) {
        await cambiarPermiso(usuarioId, entry.key, entry.value);
      }
    }
  }
}
