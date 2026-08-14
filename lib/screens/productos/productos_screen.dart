import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/producto_service.dart';
import '../../widgets/dialogs/nuevo_producto_dialog.dart';
import '../../widgets/dialogs/producto_detalle_dialog.dart';

import '../../core/widgets/app_action_menu.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_search_field.dart';


class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

  String _nombreCategoria(int id) {
    switch (id) {
      case 1:
        return "Cafés";
      case 2:
        return "Jugos";
      case 3:
        return "Snacks";
      case 4:
        return "Postres";
      case 5:
        return "Bebidas";
      default:
        return "General";
    }
  }

  @override
  Widget build(BuildContext context) {
    final productoService = context.watch<ProductoService>();
    final productos = productoService.productos;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("PRODUCTOS"),
        centerTitle: true,
        backgroundColor: const Color(0xff0A2E6E),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const NuevoProductoDialog(),
          );
        },
        backgroundColor: const Color(0xff0A2E6E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nuevo Producto",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppSearchField(
              hintText: "Buscar producto...",
              onChanged: (texto) {
                productoService.buscarProductos(texto);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: productos.isEmpty
                  ? const AppEmptyState(
                icon: Icons.inventory_2_outlined,
                titulo: "No hay productos",
                mensaje: "Presiona 'Nuevo Producto' para comenzar.",
              )
                  : ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      leading: Text(
                        producto.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                      title: Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Código: ${producto.codigo}"),
                            Text(
                              "Categoría: ${_nombreCategoria(producto.categoriaId)}",
                            ),
                            Text(
                              "Precio: S/. ${producto.precioVenta.toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      ),
                      trailing: AppActionMenu(
                        onDetalle: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProductoDetalleDialog(
                              producto: producto,

                              onEditar: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => NuevoProductoDialog(
                                    producto: producto,
                                  ),
                                );
                              },

                              onEliminar: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AppConfirmDialog(
                                    titulo: "Eliminar producto",
                                    mensaje:
                                    "¿Deseas eliminar '${producto.nombre}'?\n\nEsta acción no se puede deshacer.",
                                    textoConfirmar: "Eliminar",
                                  ),
                                );

                                if (confirmar == true && producto.id != null) {
                                  await productoService.eliminarProducto(producto.id!);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Producto eliminado correctamente",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },

                        onEditar: () {
                          showDialog(
                            context: context,
                            builder: (_) => NuevoProductoDialog(
                              producto: producto,
                            ),
                          );
                        },

                        onEliminar: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (_) => AppConfirmDialog(
                              titulo: "Eliminar producto",
                              mensaje:
                              "¿Deseas eliminar '${producto.nombre}'?\n\nEsta acción no se puede deshacer.",
                              textoConfirmar: "Eliminar",
                            ),
                          );

                          if (confirmar == true && producto.id != null) {
                            await productoService.eliminarProducto(producto.id!);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Producto eliminado correctamente"),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}