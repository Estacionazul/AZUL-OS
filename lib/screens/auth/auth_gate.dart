import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/usuarios_repository.dart';
import 'first_setup_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _usuariosExisten;

  @override
  void initState() {
    super.initState();
    _usuariosExisten = _comprobarUsuarios();
  }

  Future<bool> _comprobarUsuarios() async {
    final repository = context.read<UsuariosRepository>();
    final usuarios = await repository.obtenerUsuarios();

    return usuarios.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _usuariosExisten,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No se pudo comprobar la configuración de usuarios.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final existenUsuarios = snapshot.data ?? false;

        if (!existenUsuarios) {
          return const FirstSetupScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
