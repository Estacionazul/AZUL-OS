import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/carrito_service.dart';
import '../../services/producto_service.dart';

class PosProducts extends StatefulWidget {
  const PosProducts({super.key});

  @override
  State<PosProducts> createState() => _PosProductsState();
}

class _PosProductsState extends State<PosProducts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductoService>().cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductoService>(
      builder: (context, service, child) {
        final productos = service.productos;
        if (productos.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron productos.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width < 360 ? 1 : width < 600 ? 2 : width < 950 ? 3 : 4;
            final aspectRatio = width < 360 ? 2.5 : width < 600 ? 1.18 : 1.45;
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final ProductoModel producto = productos[index];
                return Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.read<CarritoService>().agregarProducto(producto);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('${producto.nombre} agregado al carrito'),
                            duration: const Duration(milliseconds: 700),
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(producto.emoji, style: const TextStyle(fontSize: 30)),
                          const SizedBox(height: 5),
                          Flexible(
                            child: Text(
                              producto.nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'S/ ${producto.precioVenta.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
