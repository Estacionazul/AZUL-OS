import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ubicacion_pedido.dart';
import '../services/pedidos_service.dart';
import '../widgets/ubicacion_pedido_card.dart';
import 'pedido_detalle_screen.dart';
import '../../database/app_database.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PedidosView();
  }
}

class _PedidosView extends StatelessWidget {
  const _PedidosView();

  @override
  Widget build(BuildContext context) {
    final pedidosService = context.watch<PedidosService>();

    final mesas = pedidosService.ubicaciones
        .where((ubicacion) => ubicacion.esMesa)
        .toList();

    final barras = pedidosService.ubicaciones
        .where((ubicacion) => ubicacion.esBarra)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ancho = constraints.maxWidth;

            final columnas = ancho >= 1400
                ? 4
                : ancho >= 900
                ? 3
                : ancho >= 600
                ? 2
                : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      pedidosAbiertos: pedidosService.pedidos.length,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
                  sliver: const SliverToBoxAdapter(
                    child: _SectionTitle(
                      icon: Icons.table_restaurant_rounded,
                      title: 'Mesas',
                      subtitle: 'Pedidos de clientes en salón',
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ubicacion = mesas[index];

                      return UbicacionPedidoCard(
                        ubicacion: ubicacion,
                        pedido: pedidosService.obtenerPedido(ubicacion.id),
                        onTap: () => _abrirUbicacion(context, ubicacion),
                      );
                    }, childCount: mesas.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.22,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 34, 28, 8),
                  sliver: const SliverToBoxAdapter(
                    child: _SectionTitle(
                      icon: Icons.local_bar_rounded,
                      title: 'Barras',
                      subtitle: 'Pedidos para atención en barra',
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ubicacion = barras[index];

                      return UbicacionPedidoCard(
                        ubicacion: ubicacion,
                        pedido: pedidosService.obtenerPedido(ubicacion.id),
                        onTap: () => _abrirUbicacion(context, ubicacion),
                      );
                    }, childCount: barras.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.22,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 34, 28, 8),
                  sliver: const SliverToBoxAdapter(
                    child: _SectionTitle(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Para llevar',
                      subtitle: 'Pedidos sin ubicación en salón',
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  sliver: SliverToBoxAdapter(
                    child: _ParaLlevarCard(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Módulo para llevar preparado para conectar con el carrito.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static void _abrirUbicacion(BuildContext context, UbicacionPedido ubicacion) {
    final service = context.read<PedidosService>();

    // Crea el pedido si la ubicación está libre.
    // Si ya existe, devuelve el pedido existente.
    service.abrirPedido(ubicacion);

    // Abrimos inmediatamente el detalle del pedido.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: service,
          child: PedidoDetalleScreen(ubicacion: ubicacion),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int pedidosAbiertos;

  const _Header({required this.pedidosAbiertos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF0D47A1),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Gestiona mesas, barras y pedidos',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pending_actions_rounded,
                size: 20,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              Text(
                '$pedidosAbiertos abiertos',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 25),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

class _ParaLlevarCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ParaLlevarCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Color(0xFF1565C0),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuevo pedido para llevar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Atiende pedidos que no ocupan mesa ni barra.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
