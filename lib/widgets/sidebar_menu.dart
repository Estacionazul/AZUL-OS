import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../repositories/permisos_usuario_repository.dart';
import '../services/sesion_service.dart';

import 'sidebar/sidebar_footer.dart';
import 'sidebar/sidebar_logo.dart';
import 'sidebar/sidebar_menu_item.dart';
import 'sidebar/sidebar_user_card.dart';

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  Future<Map<String, bool>> _cargarPermisos(
      BuildContext context,
      ) async {
    final sesion = SesionService.instancia;

    // ==========================================================
    // CEO: acceso total a todos los módulos
    // ==========================================================

    if (sesion.esCEO) {
      return {
        'CAFETERIA': true,
        'PRODUCTOS': true,
        'INVENTARIO': true,
        'RECETAS': true,
        'PRODUCCION': true,
        'VENTAS': true,
        'CLIENTES': true,
        'CAJA': true,
        'REPORTES': true,
        'CONFIGURACION': true,
      };
    }

    // ==========================================================
    // SIN SESIÓN: no tiene permisos
    // ==========================================================

    if (sesion.idUsuario == null) {
      return {};
    }

    // ==========================================================
    // CAJERO: consultar permisos guardados en la base de datos
    // ==========================================================

    final repository =
    context.read<PermisosUsuarioRepository>();

    final usuarioId = sesion.idUsuario!;

    final resultados = await Future.wait([
      repository.tienePermiso(usuarioId, 'CAFETERIA'),
      repository.tienePermiso(usuarioId, 'PRODUCTOS'),
      repository.tienePermiso(usuarioId, 'INVENTARIO'),
      repository.tienePermiso(usuarioId, 'RECETAS'),
      repository.tienePermiso(usuarioId, 'PRODUCCION'),
      repository.tienePermiso(usuarioId, 'VENTAS'),
      repository.tienePermiso(usuarioId, 'CLIENTES'),
      repository.tienePermiso(usuarioId, 'CAJA'),
      repository.tienePermiso(usuarioId, 'REPORTES'),
    ]);

    return {
      'CAFETERIA': resultados[0],
      'PRODUCTOS': resultados[1],
      'INVENTARIO': resultados[2],
      'RECETAS': resultados[3],
      'PRODUCCION': resultados[4],
      'VENTAS': resultados[5],
      'CLIENTES': resultados[6],
      'CAJA': resultados[7],
      'REPORTES': resultados[8],
      'CONFIGURACION': false,
    };
  }

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
              child: FutureBuilder<Map<String, bool>>(
                future: _cargarPermisos(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'No se pudieron cargar los permisos.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final permisos = snapshot.data ?? {};

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // ==================================================
                        // CENTRO DE CONTROL
                        // ==================================================

                        if (SesionService.instancia.esCEO)
                          SidebarMenuItem(
                            icon: Icons.dashboard_rounded,
                            title: 'Centro de Control',
                            selected: selectedIndex == 0,
                            onTap: () => onItemSelected(0),
                          ),

                        // ==================================================
// CAFETERÍA
// ==================================================

                        if (permisos['CAFETERIA'] == true)
                          SidebarMenuItem(
                            icon: Icons.local_cafe_rounded,
                            title: 'Cafetería',
                            selected: selectedIndex == 1,
                            onTap: () => onItemSelected(1),
                          ),

                        // ==================================================
                        // PRODUCTOS
                        // ==================================================

                        if (permisos['PRODUCTOS'] == true)
                          SidebarMenuItem(
                            icon: Icons.shopping_bag_rounded,
                            title: 'Productos',
                            selected: selectedIndex == 2,
                            onTap: () => onItemSelected(2),
                          ),

                        // ==================================================
                        // INVENTARIO
                        // ==================================================

                        if (permisos['INVENTARIO'] == true)
                          SidebarMenuItem(
                            icon: Icons.inventory_2_rounded,
                            title: 'Inventario',
                            selected: selectedIndex == 3,
                            onTap: () => onItemSelected(3),
                          ),

                        // ==================================================
// RECETAS
// ==================================================

                        if (permisos['RECETAS'] == true)
                          SidebarMenuItem(
                            icon: Icons.restaurant_menu_rounded,
                            title: 'Recetas',
                            selected: selectedIndex == 4,
                            onTap: () => onItemSelected(4),
                          ),

// ==================================================
// PRODUCCIÓN
// ==================================================

                        if (permisos['PRODUCCION'] == true)
                          SidebarMenuItem(
                            icon: Icons.factory_rounded,
                            title: 'Producción',
                            selected: selectedIndex == 5,
                            onTap: () => onItemSelected(5),
                          ),

                        // ==================================================
                        // VENTAS
                        // ==================================================

                        if (permisos['VENTAS'] == true)
                          SidebarMenuItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Ventas',
                            selected: selectedIndex == 6,
                            onTap: () => onItemSelected(6),
                          ),

                        // ==================================================
                        // CLIENTES
                        // ==================================================

                        if (permisos['CLIENTES'] == true)
                          SidebarMenuItem(
                            icon: Icons.people_alt_rounded,
                            title: 'Clientes',
                            selected: selectedIndex == 7,
                            onTap: () => onItemSelected(7),
                          ),

                        // ==================================================
                        // CAJA
                        // ==================================================

                        if (permisos['CAJA'] == true)
                          SidebarMenuItem(
                            icon: Icons.point_of_sale_rounded,
                            title: 'Caja',
                            selected: selectedIndex == 8,
                            onTap: () => onItemSelected(8),
                          ),

                        // ==================================================
                        // REPORTES
                        // ==================================================

                        if (permisos['REPORTES'] == true)
                          SidebarMenuItem(
                            icon: Icons.bar_chart_rounded,
                            title: 'Reportes',
                            selected: selectedIndex == 9,
                            onTap: () => onItemSelected(9),
                          ),

                        // ==================================================
                        // CONFIGURACIÓN
                        // ==================================================

                        // La configuración queda exclusivamente
                        // para el CEO por seguridad.
                        if (SesionService.instancia.esCEO)
                          SidebarMenuItem(
                            icon: Icons.settings_rounded,
                            title: 'Configuración',
                            selected: selectedIndex == 10,
                            onTap: () => onItemSelected(10),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SidebarFooter(),
          ],
        ),
      ),
    );
  }
}