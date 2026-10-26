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

  static const _titles = [
    'Dashboard',
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

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final movil = ancho < 700;
    final pages = <Widget>[
      DashboardScreen(onNavigate: _seleccionar),
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

    if (movil) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          backgroundColor: const Color(0xFF0D2B45),
          foregroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              tooltip: 'Abrir menú',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: SidebarMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                _seleccionar(index);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: pages[_selectedIndex],
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: _seleccionar,
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
    );
  }

  void _seleccionar(int index) {
    if (index < 0 || index >= _titles.length) return;
    setState(() => _selectedIndex = index);
  }
}
