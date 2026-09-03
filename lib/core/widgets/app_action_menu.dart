import 'package:flutter/material.dart';

class AppActionMenu extends StatelessWidget {
  final VoidCallback? onDetalle;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const AppActionMenu({
    super.key,
    this.onDetalle,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case "detalle":
            onDetalle?.call();
            break;

          case "editar":
            onEditar?.call();
            break;

          case "eliminar":
            onEliminar?.call();
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: "detalle",
          child: Row(
            children: [
              Icon(Icons.visibility_outlined),
              SizedBox(width: 10),
              Text("Ver detalle"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "editar",
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 10),
              Text("Editar"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "eliminar",
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 10),
              Text("Eliminar", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
