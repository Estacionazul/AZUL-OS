import 'package:flutter/material.dart';

import 'widgets/empresa_form.dart';
import 'widgets/impresora_form.dart';
import 'usuarios/usuarios_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("CONFIGURACIÓN"),
        centerTitle: true,
        backgroundColor: const Color(0xff0A2E6E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const EmpresaForm(),

              const SizedBox(height: 20),

              const ImpresoraForm(),

              const SizedBox(height: 20),

              _UsuariosPermisosCard(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UsuariosScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsuariosPermisosCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _UsuariosPermisosCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.manage_accounts_rounded,
                  size: 30,
                  color: Color(0xff0A2E6E),
                ),
              ),

              const SizedBox(width: 18),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuarios y permisos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Administra usuarios, roles y permisos del sistema.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}