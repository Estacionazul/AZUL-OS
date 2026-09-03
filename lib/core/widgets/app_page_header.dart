import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget {
  final String titulo;
  final Widget? action;

  const AppPageHeader({super.key, required this.titulo, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        if (action != null) action!,
      ],
    );
  }
}
