import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class SidebarLogo extends StatelessWidget {
  const SidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.storefront_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        const Text(
          "AZUL OS",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        const Text(
          "La plataforma integral\npara Estación Azul",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, height: 1.4, fontSize: 13),
        ),
      ],
    );
  }
}
