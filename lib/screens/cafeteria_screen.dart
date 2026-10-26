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
  bool _mostrarCarrito = false;

  void actualizarPantalla() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final carritoService = context.read<CarritoService>();
    final movil = MediaQuery.sizeOf(context).width < 700;

    final productosPanel = ProductosPanel(
      onAgregarProducto: (producto) async {
        final requiereVariantes =
            (producto.categoriaId == 1 &&
                producto.nombre.toLowerCase() != 'espresso') ||
            producto.categoriaId == 2 ||
            producto.categoriaId == 5;

        if (requiereVariantes) {
          final resultado = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => VariantesProductoDialog(producto: producto),
          );

          if (resultado != null) {
            carritoService.agregarProducto(
              producto,
              tamano: resultado['tamano'],
              tipoLeche: resultado['tipoLeche'],
              endulzante: resultado['endulzante'],
              infusion: resultado['infusion'],
              observaciones: resultado['observaciones'],
              extraShot: resultado['extraShot'] ?? false,
            );
            actualizarPantalla();
          }
        } else {
          carritoService.agregarProducto(producto);
          actualizarPantalla();
        }
      },
    );

    final carritoPanel = CarritoPanel(
      carritoService: carritoService,
      onActualizar: actualizarPantalla,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(movil ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModuleHeader(
                icon: Icons.local_cafe_outlined,
                title: 'Cafetería',
                subtitle: 'Gestiona productos, ventas y pedidos de la cafetería',
              ),
              SizedBox(height: movil ? 12 : 20),
              if (movil) ...[
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
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
                    selected: {_mostrarCarrito},
                    onSelectionChanged: (selection) {
                      setState(() => _mostrarCarrito = selection.first);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: _mostrarCarrito ? carritoPanel : productosPanel),
              ] else
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: productosPanel),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: carritoPanel),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
