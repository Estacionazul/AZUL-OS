import 'package:flutter/material.dart';

class AppConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final Color colorConfirmar;

  const AppConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = "Aceptar",
    this.colorConfirmar = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colorConfirmar),
          onPressed: () => Navigator.pop(context, true),
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
