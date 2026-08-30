import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../repositories/usuarios_repository.dart';
import '../../services/sesion_service.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usuarioController = TextEditingController();
  final _pinController = TextEditingController();

  bool _mostrarPin = false;
  bool _ingresando = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _ingresando = true;
    });

    try {
      final repository = context.read<UsuariosRepository>();

      final usuario = await repository.validarAcceso(
        nombre: _usuarioController.text.trim(),
        pin: _pinController.text,
      );

      if (!mounted) return;

      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Usuario o PIN incorrecto.',
            ),
            backgroundColor: AppColors.error,
          ),
        );

        return;
      }

      SesionService.instancia.iniciarSesion(usuario);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo iniciar sesión: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _ingresando = false;
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
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
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
                        'Inicio de sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Ingresa tus datos para acceder al sistema.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      TextFormField(
                        controller: _usuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(
                            Icons.person_outline,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
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
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),
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
                          if (value == null ||
                              value.isEmpty) {
                            return 'Ingresa el PIN.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _ingresando
                                  ? null
                                  : _iniciarSesion,
                          icon: _ingresando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.login_rounded,
                                ),
                          label: Text(
                            _ingresando
                                ? 'INGRESANDO...'
                                : 'INGRESAR',
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
