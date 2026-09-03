import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_carrito.dart';
import '../services/carrito_service.dart';
import '../services/cobro_service.dart';
import 'dialogs/finalizar_venta_dialog.dart';
import 'item_carrito_card.dart';

class CarritoPanel extends StatelessWidget {
  final CarritoService carritoService;
  final VoidCallback onActualizar;

  const CarritoPanel({
    super.key,
    required this.carritoService,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🛒 CARRITO",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: carritoService.items.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay productos agregados.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: carritoService.items.length,
                      itemBuilder: (context, index) {
                        final ItemCarrito item = carritoService.items[index];

                        return ItemCarritoCard(
                          item: item,
                          onSumar: () {
                            carritoService.aumentarCantidad(item);
                            onActualizar();
                          },
                          onRestar: () {
                            carritoService.disminuirCantidad(item);
                            onActualizar();
                          },
                          onEliminar: () {
                            carritoService.eliminarProducto(item);
                            onActualizar();
                          },
                        );
                      },
                    ),
            ),

            const Divider(thickness: 2, height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "S/. ${carritoService.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: carritoService.items.isEmpty
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (_) => FinalizarVentaDialog(
                            total: carritoService.total,
                            onConfirmar: (metodoPago) {
                              context.read<CobroService>().cobrar(
                                metodoPago: metodoPago,
                              );

                              onActualizar();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "✅ Venta registrada correctamente",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        );
                      },
                icon: const Icon(Icons.point_of_sale),
                label: const Text(
                  "COBRAR",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
