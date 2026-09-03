import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';

import '../../models/venta.dart';
import '../../repositories/ventas_repository.dart';

import '../../widgets/ventas/venta_empty.dart';
import '../../widgets/ventas/venta_search_bar.dart';
import '../../widgets/ventas/ventas_table.dart';
import '../../widgets/module_header.dart';

import 'pos_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _cargando = true;

  List<Venta> _ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final repository = context.read<VentasRepository>();

    final ventas = await repository.obtenerVentas();

    if (!mounted) return;

    setState(() {
      _ventas = ventas;
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // ENCABEZADO DEL MÓDULO
            // ========================================================
            const ModuleHeader(
              icon: Icons.point_of_sale_outlined,
              title: 'Ventas',
              subtitle: 'Gestiona las ventas y el historial de operaciones',
            ),

            const SizedBox(height: AppSpacing.lg),

            // ========================================================
            // ACCIÓN: NUEVA VENTA
            // ========================================================
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PosScreen(),
                    ),
                  );

                  if (!mounted) return;

                  await _cargarVentas();
                },
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Nueva venta'),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ========================================================
            // BUSCADOR
            // ========================================================
            VentaSearchBar(
              controller: _searchController,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ========================================================
            // TABLA / HISTORIAL
            // ========================================================
            Expanded(
              child: AppCard(
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : _ventas.isEmpty
                    ? const VentaEmpty()
                    : VentasTable(
                  ventas: _ventas,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}