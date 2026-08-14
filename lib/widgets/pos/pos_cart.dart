import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/carrito_service.dart';

class PosCart extends StatelessWidget {
  const PosCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoService>(
      builder: (context, carrito, child) {
        if (carrito.items.isEmpty) {
          return const Center(
            child: Text(
              "Carrito vacío",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: carrito.items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = carrito.items[index];

            return ListTile(
              leading: Text(
                item.producto.emoji,
                style: const TextStyle(fontSize: 28),
              ),

              title: Text(
                item.producto.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                "Cantidad: ${item.cantidad}",
              ),

              trailing: Text(
                "S/ ${item.subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}