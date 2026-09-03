import 'package:flutter/material.dart';

import '../../models/cliente.dart';

class ClienteDetalleDialog extends StatelessWidget {
  final ClienteModel cliente;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const ClienteDetalleDialog({
    super.key,
    required this.cliente,
    this.onEditar,
    this.onEliminar,
  });

  Widget _item(IconData icon, String titulo, String valor) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(valor.isEmpty ? "-" : valor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Detalle del cliente",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 38,
                child: Icon(Icons.person, size: 38),
              ),

              const SizedBox(height: 18),

              Text(
                cliente.nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              const Divider(),

              _item(Icons.badge_outlined, "DNI", cliente.dni ?? ""),

              _item(Icons.phone_outlined, "Teléfono", cliente.telefono),

              _item(Icons.email_outlined, "Correo", cliente.correo ?? ""),

              _item(
                Icons.location_on_outlined,
                "Dirección",
                cliente.direccion ?? "",
              ),

              const Divider(),

              _item(
                Icons.attach_money,
                "Total gastado",
                "S/ ${cliente.totalGastado.toStringAsFixed(2)}",
              ),

              _item(
                Icons.shopping_bag_outlined,
                "Compras realizadas",
                cliente.cantidadCompras.toString(),
              ),

              _item(Icons.star_outline, "Puntos", cliente.puntos.toString()),

              _item(
                Icons.workspace_premium_outlined,
                "Cliente VIP",
                cliente.esVip ? "Sí" : "No",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);

            if (onEditar != null) {
              onEditar!();
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);

            if (onEliminar != null) {
              onEliminar!();
            }
          },
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
