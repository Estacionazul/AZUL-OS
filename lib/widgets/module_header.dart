import 'package:flutter/material.dart';

class ModuleHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const ModuleHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final movil = MediaQuery.sizeOf(context).width < 600;
    final contenido = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: movil ? 23 : 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: const Color(0xFF171B21),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: movil ? 12 : 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
    final icono = Container(
      width: movil ? 44 : 58,
      height: movil ? 44 : 58,
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: Colors.white, size: movil ? 24 : 30),
    );

    if (movil) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [icono, const SizedBox(width: 12), contenido]),
          if (trailing != null) ...[
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: trailing!),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ==========================================================
        // ICONO DEL MÓDULO
        // ==========================================================
        icono,
        const SizedBox(width: 16),
        contenido,

        // ==========================================================
        // INFORMACIÓN / ACCIONES DEL MÓDULO
        // ==========================================================
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }
}