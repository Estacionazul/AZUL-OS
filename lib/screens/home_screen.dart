import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import '../widgets/sidebar_menu.dart';

import 'cafeteria_screen.dart';
import 'inventario/inventario_screen.dart';
import 'productos/productos_screen.dart';
import 'clientes_screen.dart';
import 'recetas_screen.dart';
import 'ventas/ventas_screen.dart';
import 'produccion/produccion_screen.dart';
import 'configuracion/configuracion_screen.dart';
import 'caja/caja_screen.dart';

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
      const DashboardScreen(),
      const CafeteriaScreen(),
      const ProductosScreen(),
      const InventarioScreen(),
      const RecetasScreen(),
      const ProduccionScreen(),
      const VentasScreen(),
      const ClientesScreen(),

      const CajaScreen(),

      const Center(
        child: Text(
          "Reportes\n(Próximamente)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
      ),

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