import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/producto_service.dart';

class PosSearch extends StatelessWidget {
  const PosSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (texto) {
        context.read<ProductoService>().buscarProductos(texto);
      },
      decoration: InputDecoration(
        hintText: 'Buscar producto...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
