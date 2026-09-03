import '../database/app_database.dart';

class SesionService {
  SesionService._();

  static final SesionService instancia = SesionService._();

  Usuario? _usuarioActual;

  // ==========================================================
  // USUARIO ACTUAL
  // ==========================================================

  Usuario? get usuarioActual => _usuarioActual;

  // ==========================================================
  // SESION ACTIVA
  // ==========================================================

  bool get estaIniciada => _usuarioActual != null;

  // ==========================================================
  // DATOS DE SESION
  // ==========================================================

  String? get nombreUsuario => _usuarioActual?.nombre;

  String? get rolUsuario => _usuarioActual?.rol;

  int? get idUsuario => _usuarioActual?.id;

  // ==========================================================
  // PERMISOS BASICOS
  // ==========================================================

  bool get esCEO => _usuarioActual?.rol.toUpperCase() == 'CEO';

  bool get esCajero => _usuarioActual?.rol.toUpperCase() == 'CAJERO';

  // ==========================================================
  // INICIAR SESION
  // ==========================================================

  void iniciarSesion(Usuario usuario) {
    _usuarioActual = usuario;
  }

  // ==========================================================
  // CERRAR SESION
  // ==========================================================

  void cerrarSesion() {
    _usuarioActual = null;
  }
}
