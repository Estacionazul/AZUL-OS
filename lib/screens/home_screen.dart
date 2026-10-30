import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../widgets/sidebar_menu.dart';

import 'cafeteria_screen.dart';
import 'inventario/inventario_screen.dart';
import 'productos/productos_screen.dart';
import 'clientes_screen.dart';
import 'recetas_screen.dart';
import 'ventas/ventas_screen.dart';
import '../pedidos/screens/pedidos_screen.dart';
import 'configuracion/configuracion_screen.dart';
import 'caja/caja_screen.dart';
import 'reportes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const double _mobileBreakpoint = 700;

  static const List<String> _pageTitles = [
    'Centro de Control',
    'Cafetería',
    'Productos',
    'Inventario',
    'Recetas',
    'Pedidos',
    'Ventas',
    'Clientes',
    'Caja',
    'Reportes',
    'Configuración',
  ];

  void _selectPage(int index) {
    if (index < 0 || index >= _pageTitles.length) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onNavigate: _selectPage),
      const CafeteriaScreen(),
      const ProductosScreen(),
      const InventarioScreen(),
      const RecetasScreen(),
      const PedidosScreen(),
      const VentasScreen(),
      const ClientesScreen(),
      const CajaScreen(),
      const ReportesScreen(),
      const ConfiguracionScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;

        if (!isMobile) {
          return Scaffold(
            body: Row(
              children: [
                SidebarMenu(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _selectPage,
                ),
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _pageTitles[_selectedIndex],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: const Color(0xFF174D7A),
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<int>(
                tooltip: 'Abrir menú',
                icon: const Icon(Icons.menu),
                onSelected: _selectPage,
                itemBuilder: (context) => List.generate(
                  _pageTitles.length,
                  (index) => PopupMenuItem<int>(
                    value: index,
                    child: Row(
                      children: [
                        if (index == _selectedIndex)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 10),
                        Flexible(child: Text(_pageTitles[index])),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: pages[_selectedIndex],
          ),
        );
      },
    );
  }
}