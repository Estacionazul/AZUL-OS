import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Divider(color: Colors.white24, height: 1),

          SizedBox(height: AppSpacing.md),

          Text(
            "AZUL OS v1.0.0",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          SizedBox(height: 4),

          Text(
            "La plataforma integral\npara Estación Azul",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
          ),

          SizedBox(height: AppSpacing.sm),

          Text(
            "© 2026 Estación Azul",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
