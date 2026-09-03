import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto_model.dart';
import '../services/producto_service.dart';
import 'producto_card.dart';

class ProductosPanel extends StatefulWidget {
  final void Function(ProductoModel producto) onAgregarProducto;

  const ProductosPanel({super.key, required this.onAgregarProducto});

  @override
  State<ProductosPanel> createState() => _ProductosPanelState();
}

class _ProductosPanelState extends State<ProductosPanel> {
  String _busqueda = "";

  final Map<int, Map<String, String>> categorias = {
    1: {"titulo": "☕ CAFÉS"},
    2: {"titulo": "🥤 JUGOS NATURALES"},
    3: {"titulo": "🧃 BEBIDAS FRÍAS"},
    4: {"titulo": "🥪 SNACKS"},
    5: {"titulo": "🍔 HAMBURGUESAS"},
    6: {"titulo": "🍰 POSTRES"},
    7: {"titulo": "⭐ COMBOS"},
  };

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoService>().todosProductos;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "PRODUCTOS",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value.toLowerCase().trim();
                });
              },
            ),

            const SizedBox(height: 25),

            ...categorias.entries.map((categoria) {
              final lista = productos.where((p) {
                final perteneceCategoria = p.categoriaId == categoria.key;

                final coincideBusqueda =
                    _busqueda.isEmpty ||
                    p.nombre.toLowerCase().contains(_busqueda) ||
                    p.codigo.toLowerCase().contains(_busqueda);

                return perteneceCategoria && coincideBusqueda;
              }).toList();

              if (lista.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.value["titulo"]!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...lista.map(
                    (producto) => ProductoCard(
                      producto: producto,
                      onAgregar: () => widget.onAgregarProducto(producto),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
