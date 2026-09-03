import 'package:flutter/material.dart';

import '../models/insumo.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;

  const InsumoCard({super.key, required this.insumo});

  @override
  Widget build(BuildContext context) {
    Color colorStock = Colors.green;

    if (insumo.stock <= 5) {
      colorStock = Colors.orange;
    }

    if (insumo.stock <= 1) {
      colorStock = Colors.red;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.inventory_2, color: Colors.blue),
        ),
        title: Text(
          insumo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text("Código: ${insumo.codigo}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${insumo.stock} ${insumo.unidadMedida}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorStock,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
