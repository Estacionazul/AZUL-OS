import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/producto_service.dart';

class PosCategories extends StatelessWidget {
  const PosCategories({super.key});

  static const List<Map<String, dynamic>> categorias = [
    {
      'id': null,
      'nombre': 'Todos',
      'icono': Icons.apps,
    },
    {
      'id': 1,
      'nombre': 'Cafés',
      'icono': Icons.coffee,
    },
    {
      'id': 2,
      'nombre': 'Jugos',
      'icono': Icons.local_drink,
    },
    {
      'id': 3,
      'nombre': 'Bebidas',
      'icono': Icons.local_bar,
    },
    {
      'id': 4,
      'nombre': 'Snacks',
      'icono': Icons.fastfood,
    },
    {
      'id': 5,
      'nombre': 'Hamburguesas',
      'icono': Icons.lunch_dining,
    },
    {
      'id': 6,
      'nombre': 'Postres',
      'icono': Icons.cake,
    },
    {
      'id': 7,
      'nombre': 'Combos',
      'icono': Icons.card_giftcard,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductoService>(
      builder: (
          context,
          service,
          child,
          ) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categorias.map(
                  (categoria) {
                final int? id =
                categoria['id'] as int?;

                final seleccionado =
                    service.categoriaSeleccionadaId ==
                        id;

                return Padding(
                  padding:
                  const EdgeInsets.only(
                    right: 8,
                  ),
                  child: FilterChip(
                    selected: seleccionado,
                    avatar: Icon(
                      categoria['icono']
                      as IconData,
                      size: 18,
                    ),
                    label: Text(
                      categoria['nombre']
                      as String,
                    ),
                    onSelected: (_) {
                      service
                          .seleccionarCategoria(id);
                    },
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}