import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/carrito_service.dart';
import '../widgets/dialogs/variantes_producto_dialog.dart';
import '../widgets/carrito_panel.dart';
import '../widgets/productos_panel.dart';
import '../widgets/module_header.dart';

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  void actualizarPantalla() {
    setState(() {});
  }

@override
Widget build(BuildContext context) {
final carritoService = context.read<CarritoService>();

return Scaffold(
backgroundColor: const Color(0xffF5F7FA),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ENCABEZADO DEL MÓDULO
const ModuleHeader(
  icon: Icons.local_cafe_outlined,
  title: 'Cafetería',
  subtitle: 'Gestiona productos, ventas y pedidos de la cafetería',
),

const SizedBox(height: 20),

// CONTENIDO DEL MÓDULO
Expanded(
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
flex: 6,
child: ProductosPanel(
onAgregarProducto: (producto) async {
final requiereVariantes =
(producto.categoriaId == 1 &&
producto.nombre.toLowerCase() != "espresso") ||
producto.categoriaId == 2 ||
producto.categoriaId == 5;

if (requiereVariantes) {
final resultado =
await showDialog<Map<String, dynamic>>(
context: context,
builder: (_) =>
VariantesProductoDialog(producto: producto),
);

if (resultado != null) {
carritoService.agregarProducto(
producto,
tamano: resultado["tamano"],
tipoLeche: resultado["tipoLeche"],
endulzante: resultado["endulzante"],
infusion: resultado["infusion"],
observaciones: resultado["observaciones"],
extraShot: resultado["extraShot"] ?? false,
);

actualizarPantalla();
}
} else {
carritoService.agregarProducto(producto);

actualizarPantalla();
}
},
),
),

const SizedBox(width: 20),

Expanded(
flex: 4,
child: CarritoPanel(
carritoService: carritoService,
onActualizar: actualizarPantalla,
),
),
],
),
),
],
),
),
);
}
}
