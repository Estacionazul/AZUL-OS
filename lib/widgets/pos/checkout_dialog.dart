import 'package:flutter/material.dart';

class CheckoutDialog extends StatelessWidget {
  const CheckoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Cobrar Venta",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("TOTAL", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 8),

            const Text(
              "S/ 0.00",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Método de pago",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "EFECTIVO", child: Text("💵 Efectivo")),

                DropdownMenuItem(value: "YAPE", child: Text("📱 Yape")),

                DropdownMenuItem(value: "PLIN", child: Text("📱 Plin")),

                DropdownMenuItem(value: "TARJETA", child: Text("💳 Tarjeta")),
              ],
              onChanged: (_) {},
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Documento",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "TICKET", child: Text("Ticket")),

                DropdownMenuItem(value: "BOLETA", child: Text("Boleta")),

                DropdownMenuItem(value: "FACTURA", child: Text("Factura")),
              ],
              onChanged: (_) {},
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),

        ElevatedButton(onPressed: () {}, child: const Text("Cobrar")),
      ],
    );
  }
}
