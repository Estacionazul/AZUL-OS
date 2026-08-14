import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/producto_service.dart';

class NuevoProductoDialog extends StatefulWidget {
  final ProductoModel? producto;
  final int? index;

  const NuevoProductoDialog({
    super.key,
    this.producto,
    this.index,
  });

  @override
  State<NuevoProductoDialog> createState() => _NuevoProductoDialogState();
}

class _NuevoProductoDialogState extends State<NuevoProductoDialog> {
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _precioController = TextEditingController();

  String _categoria = "Cafés";

  @override
  void initState() {
    super.initState();

    if (widget.producto != null) {
      _nombreController.text = widget.producto!.nombre;
      _codigoController.text = widget.producto!.codigo;
      _precioController.text = widget.producto!.precioVenta.toString();

      switch (widget.producto!.categoriaId) {
        case 1:
          _categoria = "Cafés";
          break;
        case 2:
          _categoria = "Jugos";
          break;
        case 3:
          _categoria = "Snacks";
          break;
        case 4:
          _categoria = "Postres";
          break;
        default:
          _categoria = "General";
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final codigo = _codigoController.text.trim();
    final precio =
        double.tryParse(_precioController.text.replaceAll(',', '.')) ?? 0;

    if (nombre.isEmpty || codigo.isEmpty || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos correctamente."),
        ),
      );
      return;
    }

    int categoriaId;
    String emoji;

    switch (_categoria) {
      case "Cafés":
        categoriaId = 1;
        emoji = "☕";
        break;

      case "Jugos":
        categoriaId = 2;
        emoji = "🥤";
        break;

      case "Snacks":
        categoriaId = 3;
        emoji = "🥪";
        break;

      case "Postres":
        categoriaId = 4;
        emoji = "🍰";
        break;

      default:
        categoriaId = 0;
        emoji = "📦";
    }

    final producto = ProductoModel(
      id: widget.producto?.id,
      codigo: codigo,
      nombre: nombre,
      categoriaId: categoriaId,
      precioVenta: precio,
      emoji: emoji,
    );

    if (widget.producto == null) {
      await context.read<ProductoService>().agregarProducto(producto);
    } else {
      await context.read<ProductoService>().editarProducto(producto);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.inventory_2,
            color: Color(0xff0A2E6E),
          ),
          const SizedBox(width: 10),
          Text(
            widget.producto == null
                ? "Nuevo Producto"
                : "Editar Producto",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: "Código",
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: InputDecoration(
                  labelText: "Categoría",
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Cafés",
                    child: Text("Cafés"),
                  ),
                  DropdownMenuItem(
                    value: "Jugos",
                    child: Text("Jugos"),
                  ),
                  DropdownMenuItem(
                    value: "Snacks",
                    child: Text("Snacks"),
                  ),
                  DropdownMenuItem(
                    value: "Postres",
                    child: Text("Postres"),
                  ),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _categoria = valor;
                    });
                  }
                },
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Precio",
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text("Cancelar"),
        ),
        ElevatedButton.icon(
          onPressed: _guardarProducto,
          icon: const Icon(Icons.save),
          label: Text(
            widget.producto == null ? "Guardar" : "Actualizar",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}