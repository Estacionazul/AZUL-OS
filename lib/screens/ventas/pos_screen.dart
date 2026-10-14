import 'package:flutter/material.dart';

import '../../widgets/pos/pos_cart.dart';
import '../../widgets/pos/pos_categories.dart';
import '../../widgets/pos/pos_checkout_button.dart';
import '../../widgets/pos/pos_products.dart';
import '../../widgets/pos/pos_search.dart';
import '../../widgets/pos/pos_total.dart';

/// POS adaptable para escritorio, tablet y celular.
/// No cambia servicios, repositorios, persistencia ni lógica de cobro.
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  bool _showCartOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            if (isMobile) {
              return _buildMobileLayout();
            }
            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: const [
                PosSearch(),
                SizedBox(height: 16),
                PosCategories(),
                SizedBox(height: 16),
                Expanded(child: PosProducts()),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 350,
            child: Column(
              children: const [
                Expanded(child: PosCart()),
                Divider(),
                PosTotal(),
                SizedBox(height: 12),
                PosCheckoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: SegmentedButton<bool>(
            expandedInsets: EdgeInsets.zero,
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.storefront_outlined),
                label: Text('Productos'),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text('Carrito'),
              ),
            ],
            selected: <bool>{_showCartOnMobile},
            onSelectionChanged: (selection) {
              setState(() => _showCartOnMobile = selection.first);
            },
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _showCartOnMobile
                ? const KeyedSubtree(
                    key: ValueKey<String>('pos-cart-mobile'),
                    child: _MobileCartPanel(),
                  )
                : const KeyedSubtree(
                    key: ValueKey<String>('pos-products-mobile'),
                    child: _MobileProductsPanel(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MobileProductsPanel extends StatelessWidget {
  const _MobileProductsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        children: const [
          PosSearch(),
          SizedBox(height: 12),
          PosCategories(),
          SizedBox(height: 12),
          Expanded(child: PosProducts()),
        ],
      ),
    );
  }
}

class _MobileCartPanel extends StatelessWidget {
  const _MobileCartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        children: const [
          Expanded(child: PosCart()),
          Divider(height: 16),
          PosTotal(),
          SizedBox(height: 12),
          PosCheckoutButton(),
        ],
      ),
    );
  }
}
