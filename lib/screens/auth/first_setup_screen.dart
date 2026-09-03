import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/usuarios_repository.dart';
import '../../services/sesion_service.dart';
import '../home_screen.dart';

class FirstSetupScreen extends StatefulWidget {
  const FirstSetupScreen({super.key});

  @override
  State<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends State<FirstSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController(text: 'CEO');

  final _pinController = TextEditingController();
  final _confirmarPinController = TextEditingController();

  bool _mostrarPin = false;
  bool _mostrarConfirmacion = false;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _pinController.dispose();
    _confirmarPinController.dispose();
    super.dispose();
  }

  Future<void> _crearCEO() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final repository = context.read<UsuariosRepository>();

      final idUsuario = await repository.crearUsuario(
        nombre: _nombreController.text.trim(),
        pin: _pinController.text,
        rol: 'CEO',
        activo: true,
      );

      final usuario = await repository.obtenerPorId(idUsuario);

      if (usuario == null) {
        throw Exception('No se pudo recuperar el usuario CEO recién creado.');
      }

      // Iniciar sesión automáticamente como CEO.
      SesionService.instancia.iniciarSesion(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario CEO creado correctamente.')),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo crear el usuario: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'ESTACIÓN AZUL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Configuración inicial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Crea el usuario CEO que administrará el sistema.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),

                      const SizedBox(height: 28),

                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el usuario.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _pinController,
                        obscureText: !_mostrarPin,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'PIN',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _mostrarPin = !_mostrarPin;
                              });
                            },
                            icon: Icon(
                              _mostrarPin
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa un PIN.';
                          }

                          if (value.length < 4) {
                            return 'El PIN debe tener al menos 4 dígitos.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmarPinController,
                        obscureText: !_mostrarConfirmacion,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Confirmar PIN',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _mostrarConfirmacion = !_mostrarConfirmacion;
                              });
                            },
                            icon: Icon(
                              _mostrarConfirmacion
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma el PIN.';
                          }

                          if (value != _pinController.text) {
                            return 'Los PIN no coinciden.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _guardando ? null : _crearCEO,
                          icon: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.admin_panel_settings),
                          label: Text(
                            _guardando ? 'CREANDO...' : 'CREAR CUENTA CEO',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
