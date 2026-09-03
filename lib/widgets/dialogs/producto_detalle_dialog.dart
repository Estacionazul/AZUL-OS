import 'package:flutter/material.dart';

import '../../models/producto_model.dart';

class ProductoDetalleDialog extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const ProductoDetalleDialog({
    super.key,
    required this.producto,
    this.onEditar,
    this.onEliminar,
  });

  String _categoria() {
    switch (producto.categoriaId) {
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

  Widget _item(IconData icono, String titulo, String valor) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Text(producto.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          const Text("Detalle del Producto"),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _item(Icons.shopping_bag, "Nombre", producto.nombre),

              _item(Icons.qr_code, "Código", producto.codigo),

              _item(Icons.category, "Categoría", _categoria()),

              _item(
                Icons.attach_money,
                "Precio",
                "S/. ${producto.precioVenta.toStringAsFixed(2)}",
              ),

              _item(
                Icons.monetization_on_outlined,
                "Costo",
                "S/. ${producto.costo.toStringAsFixed(2)}",
              ),

              _item(Icons.inventory_2, "Stock", producto.stock.toString()),

              _item(
                Icons.warning_amber,
                "Stock mínimo",
                producto.stockMinimo.toString(),
              ),

              _item(
                Icons.circle,
                "Estado",
                producto.activo ? "Activo" : "Inactivo",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);

            if (onEditar != null) {
              onEditar!();
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text("Editar"),
        ),

        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);

            if (onEliminar != null) {
              onEliminar!();
            }
          },
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),

        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
