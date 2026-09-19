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

  static const Map<String, int> _categorias = {
    'Cafés': 1,
    'Jugos Naturales': 2,
    'Bebidas Frías': 3,
    'Snacks': 4,
    'Hamburguesas': 5,
    'Postres': 6,
    'Combos': 7,
    'Insumos': 8,
  };

  String _categoria = 'Cafés';
  String _tipoInventario = 'receta';
  String _tipoAfectacionIgv = '10';
  String? _errorGuardar;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    if (producto != null) {
      _nombreController.text = producto.nombre;
      _codigoController.text = producto.codigo;
      _costoController.text = producto.costo.toString();
      _precioController.text = producto.precioVenta.toString();
      _stockMinimoController.text = producto.stockMinimo.toString();

      _tipoInventario = producto.tipoInventario;
      _tipoAfectacionIgv = producto.tipoAfectacionIgv;

      final categoria = _categorias.entries.where(
        (entry) => entry.value == producto.categoriaId,
      );

      if (categoria.isNotEmpty) {
        _categoria = categoria.first.key;
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

  String _emojiPorCategoria(String categoria) {
    switch (categoria) {
      case 'Cafés':
        return '☕';
      case 'Jugos Naturales':
        return '🥤';
      case 'Bebidas Frías':
        return '🧋';
      case 'Snacks':
        return '🥪';
      case 'Hamburguesas':
        return '🍔';
      case 'Postres':
        return '🍰';
      case 'Combos':
        return '🎁';
      case 'Insumos':
        return '📦';
      default:
        return '📦';
    }
  }

  Future<void> _guardarProducto() async {
    setState(() {
      _errorGuardar = null;
    });

    final nombre = _nombreController.text.trim();
    final codigo = _codigoController.text.trim();

    final costo =
        double.tryParse(_costoController.text.replaceAll(',', '.')) ?? 0;

    final precio =
        double.tryParse(_precioController.text.replaceAll(',', '.')) ?? 0;

    final stockMinimo =
        int.tryParse(_stockMinimoController.text.trim()) ?? 0;

    if (nombre.isEmpty || codigo.isEmpty) {
      setState(() {
        _errorGuardar = 'Completa el nombre y código del producto.';
      });
      return;
    }

    if (precio <= 0) {
      setState(() {
        _errorGuardar = 'El precio de venta debe ser mayor a 0.';
      });
      return;
    }

    if (costo < 0) {
      setState(() {
        _errorGuardar = 'El costo no puede ser negativo.';
      });
      return;
    }

    if (stockMinimo < 0) {
      setState(() {
        _errorGuardar = 'El stock mínimo no puede ser negativo.';
      });
      return;
    }

    final categoriaId = _categorias[_categoria];

    if (categoriaId == null) {
      setState(() {
        _errorGuardar = 'Selecciona una categoría válida.';
      });
      return;
    }

    final producto = ProductoModel(
      id: widget.producto?.id,
      codigo: codigo,
      codigoBarras: widget.producto?.codigoBarras ?? '',
      nombre: nombre,
      descripcion: widget.producto?.descripcion ?? '',
      categoriaId: categoriaId,
      costo: costo,
      precioVenta: precio,
      stock: widget.producto?.stock ?? 0,
      stockMinimo: stockMinimo,
      tipoInventario: _tipoInventario,
      tipoAfectacionIgv: _tipoAfectacionIgv,
      imagen: widget.producto?.imagen ?? '',
      emoji: widget.producto?.emoji ?? _emojiPorCategoria(_categoria),
      activo: widget.producto?.activo ?? true,
    );

    try {
      final service = context.read<ProductoService>();

      if (widget.producto == null) {
        await service.agregarProducto(producto);
      } else {
        await service.editarProducto(producto);
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorGuardar = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

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
            esEdicion ? 'Editar Producto' : 'Nuevo Producto',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                  labelText: 'Nombre',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Código',
                  prefixIcon: const Icon(Icons.qr_code),
                  helperText: 'Debe ser único en todo AZUL OS.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _categorias.keys
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      ),
                    )
                    .toList(),
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
                controller: _costoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Costo de compra',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  prefixText: 'S/ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Precio de venta',
                  prefixIcon: const Icon(Icons.sell_outlined),
                  prefixText: 'S/ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _stockMinimoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock mínimo',
                  prefixIcon: const Icon(Icons.warning_amber_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  helperText:
                      'Cuando llegue a este nivel se marcará como stock bajo.',
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _tipoInventario,
                decoration: InputDecoration(
                  labelText: 'Tipo de inventario',
                  prefixIcon: const Icon(Icons.inventory),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'receta',
                    child: Text('Receta — descuenta insumos'),
                  ),
                  DropdownMenuItem(
                    value: 'producto',
                    child: Text('Producto — descuenta stock'),
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
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _tipoAfectacionIgv,
                decoration: InputDecoration(
                  labelText: 'Afectación IGV',
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '10',
                    child: Text('10 - Gravado - Operación Onerosa'),
                  ),
                  DropdownMenuItem(
                    value: '20',
                    child: Text('20 - Exonerado - Operación Onerosa'),
                  ),
                  DropdownMenuItem(
                    value: '30',
                    child: Text('30 - Inafecto - Operación Onerosa'),
                  ),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() {
                      _tipoAfectacionIgv = valor;
                    });
                  }
                },
              ),
              if (_errorGuardar != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorGuardar!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (esEdicion) ...[
                const SizedBox(height: 18),
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
                          'Stock actual: ${widget.producto!.stock}\n'
                          'El stock se modifica mediante inventario '
                          'y ventas, no desde esta edición.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _guardarProducto,
          icon: const Icon(Icons.save),
          label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
