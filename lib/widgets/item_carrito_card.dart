import 'package:flutter/material.dart';
import '../models/item_carrito.dart';

class ItemCarritoCard extends StatelessWidget {
  final ItemCarrito item;
  final VoidCallback onSumar;
  final VoidCallback onRestar;
  final VoidCallback onEliminar;

  const ItemCarritoCard({
    super.key,
    required this.item,
    required this.onSumar,
    required this.onRestar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  item.producto.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.producto.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onRestar,
                  icon: const Icon(Icons.remove_circle),
                ),

                Text(
                  "${item.cantidad}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: onSumar,
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Subtotal: S/. ${item.subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}