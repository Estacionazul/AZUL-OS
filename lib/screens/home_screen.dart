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
import 'produccion/produccion_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const CafeteriaScreen(),
      const ProductosScreen(),
      const InventarioScreen(),
      const RecetasScreen(),
      const ProduccionScreen(),
      const PedidosScreen(),
      const VentasScreen(),
      const ClientesScreen(),

      const CajaScreen(),

      const ReportesScreen(),

      const ConfiguracionScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
