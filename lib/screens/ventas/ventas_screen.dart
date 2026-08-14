import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_section_title.dart';

import '../../models/venta.dart';
import '../../repositories/ventas_repository.dart';

import '../../widgets/ventas/venta_empty.dart';
import '../../widgets/ventas/venta_search_bar.dart';
import '../../widgets/ventas/ventas_table.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final TextEditingController _searchController =
  TextEditingController();

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
            const AppSectionTitle(
              title: "Historial de Ventas",
              subtitle: "Todas las ventas registradas",
            ),

            const SizedBox(height: AppSpacing.lg),

            VentaSearchBar(
              controller: _searchController,
            ),

            const SizedBox(height: AppSpacing.lg),

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