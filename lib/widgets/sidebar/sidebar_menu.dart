import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import 'sidebar_footer.dart';
import 'sidebar_logo.dart';
import 'sidebar_menu_item.dart';
import 'sidebar_user_card.dart';

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            const SidebarLogo(),

            const SizedBox(height: AppSpacing.xl),

            const SidebarUserCard(),

            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SidebarMenuItem(
                      icon: Icons.dashboard_rounded,
                      title: "Centro de Control",
                      selected: selectedIndex == 0,
                      onTap: () => onItemSelected(0),
                    ),

                    SidebarMenuItem(
                      icon: Icons.local_cafe_rounded,
                      title: "Cafetería",
                      selected: selectedIndex == 1,
                      onTap: () => onItemSelected(1),
                    ),

                    SidebarMenuItem(
                      icon: Icons.inventory_2_rounded,
                      title: "Inventario",
                      selected: selectedIndex == 2,
                      onTap: () => onItemSelected(2),
                    ),

                    SidebarMenuItem(
                      icon: Icons.people_alt_rounded,
                      title: "Clientes",
                      selected: selectedIndex == 3,
                      onTap: () => onItemSelected(3),
                    ),

                    SidebarMenuItem(
                      icon: Icons.point_of_sale_rounded,
                      title: "Caja",
                      selected: selectedIndex == 4,
                      onTap: () => onItemSelected(4),
                    ),

                    SidebarMenuItem(
                      icon: Icons.bar_chart_rounded,
                      title: "Reportes",
                      selected: selectedIndex == 5,
                      onTap: () => onItemSelected(5),
                    ),

                    SidebarMenuItem(
                      icon: Icons.settings_rounded,
                      title: "Configuración",
                      selected: selectedIndex == 6,
                      onTap: () => onItemSelected(6),
                    ),
                  ],
                ),
              ),
            ),

            const SidebarFooter(),
          ],
        ),
      ),
    );
  }
}