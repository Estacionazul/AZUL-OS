import 'package:flutter/material.dart';

class ExecutiveGreeting extends StatelessWidget {
  const ExecutiveGreeting({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "☀ Buenos días";
    }

    if (hour < 18) {
      return "🌤 Buenas tardes";
    }

    return "🌙 Buenas noches";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text(
          "Centro de Control",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          "${now.day}/${now.month}/${now.year}",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),

        const SizedBox(height: 16),

        const Text(
          "Bienvenida a la plataforma integral para Estación Azul.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
