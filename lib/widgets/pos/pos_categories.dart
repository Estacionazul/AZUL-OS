import 'package:flutter/material.dart';

class PosCategories extends StatelessWidget {
  const PosCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      "☕ Cafés",
      "🥤 Jugos",
      "🥛 Bebidas",
      "🥪 Snacks",
      "🍔 Hamburguesas",
      "🍰 Postres",
      "🎁 Combos",
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Chip(
            label: Text(categorias[index]),
          );
        },
      ),
    );
  }
}