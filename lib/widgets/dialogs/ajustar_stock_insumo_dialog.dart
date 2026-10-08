import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insumo_model.dart';
import '../../services/movimiento_inventario_service.dart';

class AjustarStockInsumoDialog extends StatefulWidget {
  final InsumoModel insumo;

  const AjustarStockInsumoDialog({
    super.key,
    required this.insumo,
  });

  @override
  State<AjustarStockInsumoDialog> createState() =>
      _AjustarStockInsumoDialogState();
}

class _AjustarStockInsumoDialogState
    extends State<AjustarStockInsumoDialog> {
  final _nuevoStockController = TextEditingController();
  final _motivoController = TextEditingController(
    text: 'Ajuste de inventario',
  );

  bool _guardando = false;

  @override
  void dispose() {
    _nuevoStockController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _ajustarStock() async {
    final nuevoStock = double.tryParse(
      _nuevoStockController.text.trim().replaceAll(',', '.'),
    );
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

    final id = widget.insumo.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El insumo no tiene un ID válido.'),
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

      await movimientoService.ajustarStockInsumoA(
        insumo: widget.insumo,
        nuevoStock: nuevoStock,
        motivo: motivo,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock de ${widget.insumo.nombre} actualizado a ${nuevoStock.toString()}.',
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
                    widget.insumo.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.insumo.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stock actual: ${widget.insumo.stock} ${widget.insumo.unidadMedida}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nuevoStockController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Nuevo stock',
                hintText: 'Ejemplo: 5000',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                suffixText: widget.insumo.unidadMedida,
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
                hintText: 'Ejemplo: Merma o vencimiento',
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
