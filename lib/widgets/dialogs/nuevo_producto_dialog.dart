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
  final _costoController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  String _categoria = "Cafés";
  String _tipoInventario = "receta";

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    if (producto != null) {
      // ==============================
      // DATOS EXISTENTES
      // ==============================

      _nombreController.text = producto.nombre;
      _codigoController.text = producto.codigo;

      _costoController.text = producto.costo.toString();
      _precioController.text = producto.precioVenta.toString();
      _stockMinimoController.text = producto.stockMinimo.toString();

      _tipoInventario = producto.tipoInventario;

      // ==============================
      // CATEGORÍA
      // ==============================

      switch (producto.categoriaId) {
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
    _costoController.dispose();
    _precioController.dispose();
    _stockMinimoController.dispose();

    super.dispose();
  }

  // ============================================================
  // GUARDAR / ACTUALIZAR
  // ============================================================

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final codigo = _codigoController.text.trim();

    final costo =
        double.tryParse(
          _costoController.text.replaceAll(',', '.'),
        ) ??
            0;

    final precio =
        double.tryParse(
          _precioController.text.replaceAll(',', '.'),
        ) ??
            0;

    final stockMinimo =
        int.tryParse(
          _stockMinimoController.text.trim(),
        ) ??
            0;

    // ============================================================
    // VALIDACIONES
    // ============================================================

    if (nombre.isEmpty || codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Completa el nombre y código del producto.",
          ),
        ),
      );
      return;
    }

    if (precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El precio de venta debe ser mayor a 0.",
          ),
        ),
      );
      return;
    }

    if (costo < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El costo no puede ser negativo.",
          ),
        ),
      );
      return;
    }

    if (stockMinimo < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "El stock mínimo no puede ser negativo.",
          ),
        ),
      );
      return;
    }

    // ============================================================
    // CATEGORÍA
    // ============================================================

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

    // ============================================================
    // CREAR PRODUCTO
    // ============================================================

    final producto = ProductoModel(
      // Si estamos editando, conservamos el ID.
      id: widget.producto?.id,

      codigo: codigo,

      // Conservamos código de barras si ya existía.
      codigoBarras: widget.producto?.codigoBarras ?? '',

      nombre: nombre,

      // Conservamos descripción existente.
      descripcion: widget.producto?.descripcion ?? '',

      categoriaId: categoriaId,

      // NUEVO / EDITABLE
      costo: costo,
      precioVenta: precio,

      // ==========================================================
      // IMPORTANTE:
      // Si editamos NO tocamos el stock actual.
      // Si es nuevo, comienza en 0.
      // ==========================================================

      stock: widget.producto?.stock ?? 0,

      stockMinimo: stockMinimo,

      tipoInventario: _tipoInventario,

      // Si estamos editando conservamos la imagen.
      imagen: widget.producto?.imagen ?? '',

      // Si editamos y la categoría no cambió,
      // conservamos el emoji existente.
      emoji: widget.producto?.emoji ?? emoji,

      // Conservamos el estado activo.
      activo: widget.producto?.activo ?? true,
    );

    // ============================================================
    // GUARDAR EN BASE DE DATOS
    // ============================================================

    if (widget.producto == null) {
      await context
          .read<ProductoService>()
          .agregarProducto(producto);
    } else {
      await context
          .read<ProductoService>()
          .editarProducto(producto);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;

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
            esEdicion
                ? "Editar Producto"
                : "Nuevo Producto",
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
              // ==================================================
              // NOMBRE
              // ==================================================

              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre",
                  prefixIcon: const Icon(
                    Icons.shopping_bag,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CÓDIGO
              // ==================================================

              TextField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: "Código",
                  prefixIcon: const Icon(
                    Icons.qr_code,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CATEGORÍA
              // ==================================================

              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: InputDecoration(
                  labelText: "Categoría",
                  prefixIcon: const Icon(
                    Icons.category,
                  ),
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

              // ==================================================
              // COSTO
              // ==================================================

              TextField(
                controller: _costoController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Costo de compra",
                  prefixIcon: const Icon(
                    Icons.payments_outlined,
                  ),
                  prefixText: "S/ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // PRECIO DE VENTA
              // ==================================================

              TextField(
                controller: _precioController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Precio de venta",
                  prefixIcon: const Icon(
                    Icons.sell_outlined,
                  ),
                  prefixText: "S/ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // STOCK MÍNIMO
              // ==================================================

              TextField(
                controller: _stockMinimoController,
                keyboardType:
                TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stock mínimo",
                  prefixIcon: const Icon(
                    Icons.warning_amber_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  helperText:
                  "Cuando llegue a este nivel se marcará como stock bajo.",
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TIPO DE INVENTARIO
              // ==================================================

              DropdownButtonFormField<String>(
                initialValue: _tipoInventario,
                decoration: InputDecoration(
                  labelText: "Tipo de inventario",
                  prefixIcon: const Icon(
                    Icons.inventory,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "receta",
                    child: Text(
                      "Receta — descuenta insumos",
                    ),
                  ),
                  DropdownMenuItem(
                    value: "producto",
                    child: Text(
                      "Producto — descuenta stock",
                    ),
                  ),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _tipoInventario = valor;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              // ==================================================
              // INFORMACIÓN DEL STOCK
              // ==================================================

              if (esEdicion)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Color(0xff0A2E6E),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Stock actual: ${widget.producto!.stock}\n"
                              "El stock se modifica mediante inventario "
                              "y ventas, no desde esta edición.",
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BOTONES
      // ==========================================================

      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
          label: const Text("Cancelar"),
        ),
        ElevatedButton.icon(
          onPressed: _guardarProducto,
          icon: const Icon(Icons.save),
          label: Text(
            esEdicion
                ? "Actualizar"
                : "Guardar",
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