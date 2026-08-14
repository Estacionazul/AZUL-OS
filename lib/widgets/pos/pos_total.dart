import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/carrito_service.dart';

class PosTotal extends StatelessWidget {
  const PosTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoService>(
      builder: (context, carrito, child) {
        return ListTile(
          title: const Text(
            "TOTAL",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            "S/ ${carrito.total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}