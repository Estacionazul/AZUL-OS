import 'package:flutter/material.dart';

import 'widgets/empresa_form.dart';
import 'widgets/impresora_form.dart';

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
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EmpresaForm(),

              SizedBox(height: 20),

              ImpresoraForm(),
            ],
          ),
        ),
      ),
    );
  }
}