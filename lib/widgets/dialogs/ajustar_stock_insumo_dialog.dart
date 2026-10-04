import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insumo_model.dart';
import '../../models/movimiento_inventario_model.dart';
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
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController(
    text: 'Ajuste de inventario',
  );

  bool _guardando = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _registrarSalida() async {
    final cantidad = double.tryParse(
          _cantidadController.text.trim().replaceAll(',', '.'),
        ) ??
        0;

    final motivo = _motivoController.text.trim();

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una cantidad válida mayor a 0.'),
        ),
      );
      return;
    }

    if (cantidad > widget.insumo.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad no puede superar el stock actual.'),
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

      final stockAnterior = widget.insumo.stock;

      await movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime.now(),
          tipo: 'AJUSTE_SALIDA',
          nombreItem: widget.insumo.nombre,
          emoji: widget.insumo.emoji,
          unidad: widget.insumo.unidadMedida,
          referenciaId: null,
          insumoId: id,
          productoId: null,
          cantidad: cantidad,
          signo: -1,
          observacion:
              '${motivo} - Stock anterior: ${stockAnterior.toString()} - Ajuste: -${cantidad.toString()}',
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ajuste registrado: -${cantidad.toString()} ${widget.insumo.unidadMedida} de ${widget.insumo.nombre}',
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
          content: Text('No se pudo registrar el ajuste: $e'),
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
              controller: _cantidadController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad a retirar',
                hintText: 'Ejemplo: 100',
                prefixIcon: const Icon(Icons.remove_circle_outline),
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
                'Este movimiento quedará registrado en el Kardex como ajuste de salida.',
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
          onPressed: _guardando ? null : _registrarSalida,
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
          label: Text(_guardando ? 'Guardando...' : 'Registrar ajuste'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
