import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../models/receta_model.dart';
import '../../services/producto_service.dart';
import '../../services/recetas_service.dart';

class NuevaRecetaDialog extends StatefulWidget {
  const NuevaRecetaDialog({super.key});

  @override
  State<NuevaRecetaDialog> createState() => _NuevaRecetaDialogState();
}

class _NuevaRecetaDialogState extends State<NuevaRecetaDialog> {
  final TextEditingController _nombreController = TextEditingController();

  ProductoModel? _productoSeleccionado;
  bool _activo = true;

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleccione un producto."),
        ),
      );
      return;
    }

    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingrese el nombre de la receta."),
        ),
      );
      return;
    }

    final receta = RecetaModel(
      productoId: _productoSeleccionado!.id ?? 0,
      nombre: _nombreController.text.trim(),
      activo: _activo,
    );

    await context.read<RecetasService>().guardarReceta(receta);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoService>().productos;

    return AlertDialog(
      title: const Text("Nueva receta"),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductoModel>(
                value: _productoSeleccionado,
                decoration: const InputDecoration(
                  labelText: "Producto",
                  border: OutlineInputBorder(),
                ),
                items: productos.map((producto) {
                  return DropdownMenuItem(
                    value: producto,
                    child: Text(producto.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productoSeleccionado = value;

                    if (value != null) {
                      _nombreController.text = value.nombre;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la receta",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Activa"),
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}