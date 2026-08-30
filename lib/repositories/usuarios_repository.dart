import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/dao/usuarios_dao.dart';

class UsuariosRepository {
  final UsuariosDao _dao;

  UsuariosRepository(AppDatabase database)
      : _dao = UsuariosDao(database);

  // ==========================================================
  // CREAR USUARIO
  // ==========================================================

  Future<int> crearUsuario({
    required String nombre,
    required String pin,
    String rol = 'CAJERO',
    bool activo = true,
  }) {
    return _dao.crearUsuario(
      UsuariosCompanion.insert(
        nombre: nombre.trim(),
        pin: pin,
        rol: Value(rol),
        activo: Value(activo),
      ),
    );
  }

  // ==========================================================
  // OBTENER TODOS
  // ==========================================================

  Future<List<Usuario>> obtenerUsuarios() {
    return _dao.obtenerUsuarios();
  }

  // ==========================================================
  // OBTENER ACTIVOS
  // ==========================================================

  Future<List<Usuario>> obtenerUsuariosActivos() {
    return _dao.obtenerUsuariosActivos();
  }

  // ==========================================================
  // OBTENER POR ID
  // ==========================================================

  Future<Usuario?> obtenerPorId(int id) {
    return _dao.obtenerPorId(id);
  }

  // ==========================================================
  // OBTENER POR NOMBRE
  // ==========================================================

  Future<Usuario?> obtenerPorNombre(String nombre) {
    return _dao.obtenerPorNombre(nombre.trim());
  }

  // ==========================================================
  // VALIDAR ACCESO
  // ==========================================================

  Future<Usuario?> validarAcceso({
    required String nombre,
    required String pin,
  }) {
    return _dao.validarAcceso(
      nombre.trim(),
      pin,
    );
  }

  // ==========================================================
  // ACTUALIZAR
  // ==========================================================

  Future<bool> actualizarUsuario(UsuariosCompanion usuario) {
    return _dao.actualizarUsuario(usuario);
  }

  // ==========================================================
  // CAMBIAR ESTADO
  // ==========================================================

  Future<int> cambiarEstado(
    int id,
    bool activo,
  ) {
    return _dao.cambiarEstado(id, activo);
  }

  // ==========================================================
  // ELIMINAR
  // ==========================================================

  Future<int> eliminarUsuario(int id) {
    return _dao.eliminarUsuario(id);
  }
}
