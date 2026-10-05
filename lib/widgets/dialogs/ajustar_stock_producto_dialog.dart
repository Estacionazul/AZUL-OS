import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/movimiento_inventario_service.dart';

class AjustarStockProductoDialog extends StatefulWidget {
  final ProductoModel producto;

  const AjustarStockProductoDialog({
    super.key,
    required this.producto,
  });

  @override
  State<AjustarStockProductoDialog> createState() =>
      _AjustarStockProductoDialogState();
}

class _AjustarStockProductoDialogState
    extends State<AjustarStockProductoDialog> {
  final _nuevoStockController = TextEditingController();
  final _motivoController = TextEditingController(text: 'Ajuste de inventario');

  bool _guardando = false;

  @override
  void dispose() {
    _nuevoStockController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _ajustarStock() async {
    final nuevoStock =
        int.tryParse(_nuevoStockController.text.trim());
    final motivo = _motivoController.text.trim();

    if (nuevoStock == null || nuevoStock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un stock final válido de 0 o más.'),
        ),
      );
      return;
    }

    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el motivo del ajuste.'),
        ),
      );
      return;
    }

    if (widget.producto.tipoInventario == 'receta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este producto usa inventario por receta. '
            'El ajuste se realiza sobre sus insumos.',
          ),
        ),
      );
      return;
    }

    if (widget.producto.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El producto no tiene un ID válido.'),
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final movimientoService =
          context.read<MovimientoInventarioService>();

      await movimientoService.ajustarStockProductoA(
        producto: widget.producto,
        nuevoStock: nuevoStock,
        motivo: motivo,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock de ${widget.producto.nombre} actualizado a $nuevoStock.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo ajustar el stock: $e'),
        ),
      );
    }
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
            Icons.tune,
            color: Color(0xff0A2E6E),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Ajustar stock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffEAF1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    widget.producto.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.producto.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock actual: ${widget.producto.stock} und',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _cantidadController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nuevo stock',
                hintText: 'Ejemplo: 5',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ejemplo: Corrección de inventario',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ingresa el stock físico final. AZUL OS calculará automáticamente la diferencia y la registrará en el Kardex.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _guardando ? null : _ajustarStock,
          icon: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_guardando ? 'Guardando...' : 'Ajustar stock'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
