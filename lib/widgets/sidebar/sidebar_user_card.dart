import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/sesion_service.dart';

class SidebarUserCard extends StatelessWidget {
  const SidebarUserCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = SesionService.instancia;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primary),
          ),

          SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sesion.nombreUsuario ?? 'Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  sesion.rolUsuario ?? '',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),

                SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.greenAccent),

                    SizedBox(width: 6),

                    Text(
                      "Sistema en línea",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
