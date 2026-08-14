import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_section_title.dart';

import '../models/dashboard_resumen.dart';
import '../repositories/ventas_repository.dart';

import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/quick_action_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _cargando = true;

  DashboardResumen? _resumen;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    final repository = context.read<VentasRepository>();

    final resumen = await repository.obtenerResumenDashboard();

    if (!mounted) return;

    setState(() {
      _resumen = resumen;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle(
                    title: 'Dashboard',
                    subtitle: 'Resumen general de Estación Azul',
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          icon: Icons.attach_money,
                          titulo: "Ventas Hoy",
                          valor:
                          "S/ ${_resumen!.ventasHoy.toStringAsFixed(2)}",
                          color: AppColors.success,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.receipt_long,
                          titulo: "Tickets",
                          valor: _resumen!.ticketsHoy.toString(),
                          color: Colors.brown,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.people,
                          titulo: "Clientes",
                          valor: _resumen!.clientesHoy.toString(),
                          color: AppColors.info,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.warning_amber,
                          titulo: "Alertas",
                          valor: _resumen!.alertas.toString(),
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.local_cafe,
                          titulo: "Cafetería",
                          color: Colors.brown,
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.inventory_2,
                          titulo: "Inventario",
                          color: Colors.indigo,
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.people,
                          titulo: "Clientes",
                          color: AppColors.info,
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.bar_chart,
                          titulo: "Reportes",
                          color: AppColors.success,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const AppCard(
                    child: SizedBox(
                      height: 280,
                      child: Center(
                        child: Text(
                          "En el siguiente sprint aparecerán\nlas últimas ventas aquí.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}