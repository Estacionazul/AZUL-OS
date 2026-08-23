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
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final item = carrito.items[index];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ICONO
                SizedBox(
                  width: 44,
                  child: Text(
                    item.producto.emoji,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),

                const SizedBox(width: 8),

                // PRODUCTO + CANTIDAD
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.producto.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // CONTROLES DE CANTIDAD
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Disminuir',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () {
                              carrito.disminuirCantidad(item);
                            },
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 22,
                            ),
                          ),

                          Text(
                            '${item.cantidad}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Aumentar',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () {
                              carrito.aumentarCantidad(item);
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                // SUBTOTAL
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "S/ ${item.subtotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),

                    IconButton(
                      tooltip: 'Eliminar',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        carrito.eliminarProducto(item);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}