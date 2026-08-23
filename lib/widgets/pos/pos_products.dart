import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/carrito_service.dart';
import '../../services/producto_service.dart';

class PosProducts extends StatefulWidget {
  const PosProducts({super.key});

  @override
  State<PosProducts> createState() =>
      _PosProductsState();
}

class _PosProductsState
    extends State<PosProducts> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<ProductoService>()
          .cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductoService>(
      builder: (
          context,
          service,
          child,
          ) {
        final productos =
            service.productos;

        if (productos.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron productos.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          );
        }

        return GridView.builder(
          padding:
          const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productos.length,
          itemBuilder: (
              context,
              index,
              ) {
            final ProductoModel producto =
            productos[index];

            return InkWell(
              borderRadius:
              BorderRadius.circular(14),
              onTap: () {
                context
                    .read<CarritoService>()
                    .agregarProducto(producto);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${producto.nombre} '
                          'agregado al carrito',
                    ),
                    duration:
                    const Duration(
                      milliseconds: 700,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        producto.emoji,
                        style:
                        const TextStyle(
                          fontSize: 34,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        producto.nombre,
                        textAlign:
                        TextAlign.center,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'S/ ${producto.precioVenta.toStringAsFixed(2)}',
                        style:
                        const TextStyle(
                          color: Colors.blue,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
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
  }
}