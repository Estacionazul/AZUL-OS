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
    final nombreController = TextEditingController();
    final pinController = TextEditingController();
    final confirmarPinController = TextEditingController();

    bool ocultarPin = true;
    bool ocultarConfirmacion = true;
    bool guardando = false;

    final creado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuildContext, setDialogState) {
            Future<void> guardar() async {
              if (guardando) return;

              final nombre = nombreController.text.trim();
              final pin = pinController.text.trim();
              final confirmarPin =
              confirmarPinController.text.trim();

              if (nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Ingresa el nombre del usuario.',
                    ),
                  ),
                );
                return;
              }

              if (pin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El PIN debe tener 4 dígitos.',
                    ),
                  ),
                );
                return;
              }

              if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El PIN solo puede contener números.',
                    ),
                  ),
                );
                return;
              }

              if (pin != confirmarPin) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Los PIN no coinciden.',
                    ),
                  ),
                );
                return;
              }

              setDialogState(() {
                guardando = true;
              });

              try {
                final repository =
                context.read<UsuariosRepository>();

                final existente =
                await repository.obtenerPorNombre(nombre);

                if (existente != null) {
                  setDialogState(() {
                    guardando = false;
                  });

                  if (!dialogBuildContext.mounted) return;

                  ScaffoldMessenger.of(dialogBuildContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ya existe un usuario con ese nombre.',
                      ),
                    ),
                  );

                  return;
                }

                await repository.crearUsuario(
                  nombre: nombre,
                  pin: pin,
                  rol: 'CAJERO',
                  activo: true,
                );

                if (!dialogBuildContext.mounted) return;

                Navigator.of(dialogContext).pop(true);
                } catch (e) {
              if (!dialogBuildContext.mounted) return;

              setDialogState(() {
              guardando = false;
              });

              ScaffoldMessenger.of(dialogBuildContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo crear el usuario: $e',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                  ),
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
                      controller: nombreController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej. María',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: pinController,
                      obscureText: ocultarPin,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'PIN',
                        hintText: '4 dígitos',
                        counterText: '',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              ocultarPin = !ocultarPin;
                            });
                          },
                          icon: Icon(
                            ocultarPin
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller:
                      confirmarPinController,
                      obscureText: ocultarConfirmacion,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Confirmar PIN',
                        hintText: 'Repite el PIN',
                        counterText: '',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              ocultarConfirmacion =
                              !ocultarConfirmacion;
                            });
                          },
                          icon: Icon(
                            ocultarConfirmacion
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
                        color: AppColors.info.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Rol: CAJERO',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
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
                  onPressed: guardando
                      ? null
                      : () {
                    Navigator.of(dialogContext)
                        .pop();
                  },
                  child: const Text('CANCELAR'),
                ),
                ElevatedButton.icon(
                  onPressed: guardando ? null : guardar,
                  icon: guardando
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.save_rounded,
                  ),
                  label: Text(
                    guardando
                        ? 'GUARDANDO...'
                        : 'CREAR USUARIO',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    pinController.dispose();
    confirmarPinController.dispose();

    if (!mounted) return;

    if (creado == true) {
      await _cargarUsuarios();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuario creado correctamente.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
          content: Text(
            'No se pudieron cargar los usuarios: $e',
          ),
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
          content: Text(
            'No puedes desactivar tu propio usuario.',
          ),
        ),
      );
      return;
    }

    final repository = context.read<UsuariosRepository>();

    await repository.cambiarEstado(
      usuario.id,
      !usuario.activo,
    );

    await _cargarUsuarios();
  }

  Future<void> _mostrarPermisos(Usuario usuario) async {
    final repository =
    context.read<PermisosUsuarioRepository>();

    const modulos = <Map<String, String>>[
      {
        'codigo': 'CAFETERIA',
        'nombre': 'Cafetería',
      },
      {
        'codigo': 'PRODUCTOS',
        'nombre': 'Productos',
      },
      {
        'codigo': 'INVENTARIO',
        'nombre': 'Inventario',
      },
      {
        'codigo': 'RECETAS',
        'nombre': 'Recetas',
      },
      {
        'codigo': 'PRODUCCION',
        'nombre': 'Producción',
      },
      {
        'codigo': 'VENTAS',
        'nombre': 'Ventas',
      },
      {
        'codigo': 'CLIENTES',
        'nombre': 'Clientes',
      },
      {
        'codigo': 'CAJA',
        'nombre': 'Caja',
      },
      {
        'codigo': 'REPORTES',
        'nombre': 'Reportes',
      },
      {
        'codigo': 'CONFIGURACION',
        'nombre': 'Configuración',
      },
    ];

    final permisos =
    await repository.obtenerPorUsuario(usuario.id);

    if (!mounted) return;

    final permisosActuales = <String, bool>{
      for (final modulo in modulos)
        modulo['codigo']!: permisos.any(
              (permiso) =>
          permiso.modulo == modulo['codigo'] &&
              permiso.permitido,
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
                  const Icon(
                    Icons.security_rounded,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Permisos de ${usuario.nombre}',
                    ),
                  ),
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
                          ...modulos.map(
                                (modulo) {
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

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
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
                            },
                          ),
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
    return activo
        ? AppColors.success
        : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final sesion = SesionService.instancia;

    if (!sesion.esCEO) {
      return const Center(
        child: Text(
          'No tienes permisos para administrar usuarios.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                  ),
                  label: const Text(
                    'NUEVO USUARIO',
                  ),
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
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : _usuarios.isEmpty
                    ? const Center(
                  child: Text(
                    'No existen usuarios registrados.',
                    style: TextStyle(
                      color:
                      AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _usuarios.length,
                  separatorBuilder:
                      (_, _) =>
                  const Divider(),
                  itemBuilder:
                      (context, index) {
                    final usuario =
                    _usuarios[index];

                    final esUsuarioActual =
                        usuario.id ==
                            SesionService
                                .instancia
                                .idUsuario;

                    final esCEO =
                        usuario.rol
                            .toUpperCase() ==
                            'CEO';

                    return ListTile(
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        AppColors.primary
                            .withValues(
                          alpha: 0.10,
                        ),
                        child: Icon(
                          esCEO
                              ? Icons
                              .admin_panel_settings_rounded
                              : Icons
                              .person_rounded,
                          color:
                          AppColors.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            usuario.nombre,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          if (esUsuarioActual) ...[
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration:
                              BoxDecoration(
                                color: AppColors
                                    .info
                                    .withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                              child: const Text(
                                'TÚ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  color:
                                  AppColors
                                      .info,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 5,
                        ),
                        child: Row(
                          children: [
                            Text(
                              usuario.rol,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Icon(
                              Icons.circle,
                              size: 9,
                              color:
                              _colorEstado(
                                usuario.activo,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              usuario.activo
                                  ? 'Activo'
                                  : 'Inactivo',
                              style: TextStyle(
                                color:
                                _colorEstado(
                                  usuario.activo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: esCEO
                          ? const Chip(
                        avatar: Icon(
                          Icons
                              .verified_user_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'ADMINISTRADOR',
                        ),
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
                            onChanged:
                            esUsuarioActual
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
                  color: AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
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