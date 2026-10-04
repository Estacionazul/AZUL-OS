import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insumo_model.dart';
import '../../models/movimiento_inventario_model.dart';
import '../../services/movimiento_inventario_service.dart';

class RegistrarEntradaInsumoDialog extends StatefulWidget {
  final InsumoModel insumo;

  const RegistrarEntradaInsumoDialog({
    super.key,
    required this.insumo,
  });

  @override
  State<RegistrarEntradaInsumoDialog> createState() =>
      _RegistrarEntradaInsumoDialogState();
}

class _RegistrarEntradaInsumoDialogState
    extends State<RegistrarEntradaInsumoDialog> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController(text: 'Compra');

  bool _guardando = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _registrarEntrada() async {
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

    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el motivo de la entrada.'),
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
          tipo: 'ENTRADA',
          nombreItem: widget.insumo.nombre,
          emoji: widget.insumo.emoji,
          unidad: widget.insumo.unidadMedida,
          referenciaId: null,
          insumoId: id,
          productoId: null,
          cantidad: cantidad,
          signo: 1,
          observacion:
              '${motivo} - Stock anterior: ${stockAnterior.toString()}',
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entrada registrada: +${cantidad.toString()} ${widget.insumo.unidadMedida} de ${widget.insumo.nombre}',
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
          content: Text('No se pudo registrar la entrada: $e'),
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
            Icons.move_to_inbox,
            color: Color(0xff0A2E6E),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Registrar entrada',
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                labelText: 'Cantidad',
                hintText: 'Ejemplo: 5000',
                prefixIcon: const Icon(Icons.add_box),
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
                hintText: 'Ejemplo: Compra',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
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
          onPressed: _guardando ? null : _registrarEntrada,
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
          label: Text(_guardando ? 'Guardando...' : 'Registrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
