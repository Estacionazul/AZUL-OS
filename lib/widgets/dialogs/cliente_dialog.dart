import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../forms/cliente_form.dart';

class ClienteDialog extends StatelessWidget {
  final ClienteModel? cliente;

  const ClienteDialog({
    super.key,
    this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        cliente == null
            ? "Nuevo cliente"
            : "Editar cliente",
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: ClienteForm(
            cliente: cliente,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}