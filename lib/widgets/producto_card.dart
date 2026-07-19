import 'package:flutter/material.dart';
import '../models/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onAgregar;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Text(
          producto.emoji,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(
          producto.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "S/. ${producto.precio.toStringAsFixed(2)}",
        ),
        trailing: ElevatedButton.icon(
          onPressed: onAgregar,
          icon: const Icon(Icons.add),
          label: const Text("Agregar"),
        ),
      ),
    );
  }
}