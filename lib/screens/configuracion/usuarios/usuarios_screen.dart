import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../database/app_database.dart';
import '../../../repositories/usuarios_repository.dart';
import '../../../repositories/permisos_usuario_repository.dart';
import '../../../services/sesion_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  bool _cargando = true;
  List<Usuario> _usuarios = [];

  Future<void> _mostrarDialogoNuevoUsuario() async {
    final repository = context.read<UsuariosRepository>();

    final creado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _NuevoUsuarioDialog(
        repository: repository,
      ),
    );

    if (!mounted || creado != true) return;

    await _cargarUsuarios();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Usuario creado correctamente.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    try {
      final repository = context.read<UsuariosRepository>();

      final usuarios = await repository.obtenerUsuarios();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron cargar los usuarios: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _cambiarEstado(Usuario usuario) async {
    // El CEO actualmente conectado queda protegido.
    if (usuario.id == SesionService.instancia.idUsuario) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes desactivar tu propio usuario.'),
        ),
      );
      return;
    }

    final repository = context.read<UsuariosRepository>();

    await repository.cambiarEstado(usuario.id, !usuario.activo);

    await _cargarUsuarios();
  }

  Future<void> _mostrarPermisos(Usuario usuario) async {
    final repository = context.read<PermisosUsuarioRepository>();

    const modulos = <Map<String, String>>[
      {'codigo': 'CAFETERIA', 'nombre': 'Cafetería'},
      {'codigo': 'PRODUCTOS', 'nombre': 'Productos'},
      {'codigo': 'INVENTARIO', 'nombre': 'Inventario'},
      {'codigo': 'RECETAS', 'nombre': 'Recetas'},
      {'codigo': 'PRODUCCION', 'nombre': 'Producción'},
      {'codigo': 'VENTAS', 'nombre': 'Ventas'},
      {'codigo': 'CLIENTES', 'nombre': 'Clientes'},
      {'codigo': 'CAJA', 'nombre': 'Caja'},
      {'codigo': 'REPORTES', 'nombre': 'Reportes'},
      {'codigo': 'CONFIGURACION', 'nombre': 'Configuración'},
    ];

    final permisos = await repository.obtenerPorUsuario(usuario.id);

    if (!mounted) return;

    final permisosActuales = <String, bool>{
      for (final modulo in modulos)
        modulo['codigo']!: permisos.any(
          (permiso) => permiso.modulo == modulo['codigo'] && permiso.permitido,
        ),
    };

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.security_rounded),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Permisos de ${usuario.nombre}')),
                ],
              ),
              content: SizedBox(
                width: 420,
                height: 430,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona los módulos a los que tendrá acceso:',
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView(
                        children: [
                          ...modulos.map((modulo) {
                            final codigo = modulo['codigo']!;
                            final nombre = modulo['nombre']!;

                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(nombre),
                              value: permisosActuales[codigo] ?? false,
                              onChanged: (valor) async {
                                try {
                                  await repository.cambiarPermiso(
                                    usuario.id,
                                    codigo,
                                    valor,
                                  );

                                  if (!context.mounted) return;

                                  setState(() {
                                    permisosActuales[codigo] = valor;
                                  });
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo cambiar el permiso: $e',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('CERRAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _colorEstado(bool activo) {
    return activo ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final sesion = SesionService.instancia;

    if (!sesion.esCEO) {
      return const Center(
        child: Text(
          'No tienes permisos para administrar usuarios.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ENCABEZADO
            // ==================================================
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Volver',
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usuarios y permisos',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Administra los usuarios que tienen acceso a AZUL OS.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _mostrarDialogoNuevoUsuario,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('NUEVO USUARIO'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // RESUMEN
            // ==================================================
            Row(
              children: [
                _ResumenCard(
                  icon: Icons.people_alt_rounded,
                  titulo: 'Usuarios',
                  valor: '${_usuarios.length}',
                ),

                const SizedBox(width: 16),

                _ResumenCard(
                  icon: Icons.check_circle_rounded,
                  titulo: 'Activos',
                  valor: '${_usuarios.where((u) => u.activo).length}',
                ),

                const SizedBox(width: 16),

                _ResumenCard(
                  icon: Icons.admin_panel_settings_rounded,
                  titulo: 'CEO',
                  valor:
                      '${_usuarios.where((u) => u.rol.toUpperCase() == 'CEO').length}',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // LISTA
            // ==================================================
            Expanded(
              child: Card(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _usuarios.isEmpty
                    ? const Center(
                        child: Text(
                          'No existen usuarios registrados.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _usuarios.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final usuario = _usuarios[index];

                          final esUsuarioActual =
                              usuario.id == SesionService.instancia.idUsuario;

                          final esCEO = usuario.rol.toUpperCase() == 'CEO';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.10,
                              ),
                              child: Icon(
                                esCEO
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.person_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  usuario.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                if (esUsuarioActual) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'TÚ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    usuario.rol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.circle,
                                    size: 9,
                                    color: _colorEstado(usuario.activo),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    usuario.activo ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      color: _colorEstado(usuario.activo),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: esCEO
                                ? const Chip(
                                    avatar: Icon(
                                      Icons.verified_user_rounded,
                                      size: 18,
                                    ),
                                    label: Text('ADMINISTRADOR'),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          _mostrarPermisos(usuario);
                                        },
                                        icon: const Icon(
                                          Icons.security_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('PERMISOS'),
                                      ),

                                      const SizedBox(width: 12),

                                      Switch(
                                        value: usuario.activo,
                                        onChanged: esUsuarioActual
                                            ? null
                                            : (_) => _cambiarEstado(usuario),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NuevoUsuarioDialog extends StatefulWidget {
  final UsuariosRepository repository;

  const _NuevoUsuarioDialog({
    required this.repository,
  });

  @override
  State<_NuevoUsuarioDialog> createState() => _NuevoUsuarioDialogState();
}

class _NuevoUsuarioDialogState extends State<_NuevoUsuarioDialog> {
  final _nombreController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmarPinController = TextEditingController();

  bool _ocultarPin = true;
  bool _ocultarConfirmacion = true;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _pinController.dispose();
    _confirmarPinController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final nombre = _nombreController.text.trim();
    final pin = _pinController.text.trim();
    final confirmarPin = _confirmarPinController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('Ingresa el nombre del usuario.');
      return;
    }

    if (pin.length != 4) {
      _mostrarMensaje('El PIN debe tener 4 dígitos.');
      return;
    }

    if (!RegExp(r'^\\d{4}$').hasMatch(pin)) {
      _mostrarMensaje('El PIN solo puede contener números.');
      return;
    }

    if (pin != confirmarPin) {
      _mostrarMensaje('Los PIN no coinciden.');
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final existente = await widget.repository.obtenerPorNombre(nombre);

      if (!mounted) return;

      if (existente != null) {
        setState(() {
          _guardando = false;
        });
        _mostrarMensaje('Ya existe un usuario con ese nombre.');
        return;
      }

      await widget.repository.crearUsuario(
        nombre: nombre,
        pin: pin,
        rol: 'CAJERO',
        activo: true,
      );

      if (!mounted) return;

      // El usuario se crea como CAJERO. Sus permisos operativos
      // se aplicarán al iniciar sesión mediante el perfil por rol.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarMensaje(
        'No se pudo crear el usuario: $e',
        error: true,
      );
    }
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1_rounded),
          SizedBox(width: 10),
          Text('Nuevo usuario'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej. María',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: _ocultarPin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'PIN',
                hintText: '4 dígitos',
                counterText: '',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarPin = !_ocultarPin;
                    });
                  },
                  icon: Icon(
                    _ocultarPin
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmarPinController,
              obscureText: _ocultarConfirmacion,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Confirmar PIN',
                hintText: 'Repite el PIN',
                counterText: '',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarConfirmacion = !_ocultarConfirmacion;
                    });
                  },
                  icon: Icon(
                    _ocultarConfirmacion
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.badge_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rol: CAJERO',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(
            _guardando ? 'GUARDANDO...' : 'CREAR USUARIO',
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// TARJETA DE RESUMEN
// ==========================================================

class _ResumenCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const _ResumenCard({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
