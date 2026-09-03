import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/movimiento_inventario_service.dart';
import '../../models/movimiento_inventario_model.dart';

class RegistrarEntradaProductoDialog extends StatefulWidget {
  final ProductoModel producto;

  const RegistrarEntradaProductoDialog({super.key, required this.producto});

  @override
  State<RegistrarEntradaProductoDialog> createState() =>
      _RegistrarEntradaProductoDialogState();
}

class _RegistrarEntradaProductoDialogState
    extends State<RegistrarEntradaProductoDialog> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController(text: "Compra");

  bool _guardando = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _registrarEntrada() async {
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;

    final motivo = _motivoController.text.trim();

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa una cantidad válida mayor a 0.")),
      );
      return;
    }

    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa el motivo de la entrada.")),
      );
      return;
    }

    if (widget.producto.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El producto no tiene un ID válido.")),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final movimientoService = context.read<MovimientoInventarioService>();

      final stockAnterior = widget.producto.stock;

      await movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime.now(),
          tipo: "ENTRADA",
          nombreItem: widget.producto.nombre,
          emoji: widget.producto.emoji,
          unidad: "unidad",
          referenciaId: null,
          insumoId: null,
          productoId: widget.producto.id,
          cantidad: cantidad.toDouble(),
          signo: 1,
          observacion: "$motivo - Stock anterior: $stockAnterior",
        ),
      );

      await movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime.now(),
          tipo: "ENTRADA",
          nombreItem: widget.producto.nombre,
          emoji: widget.producto.emoji,
          unidad: "unidad",
          referenciaId: null,
          insumoId: null,
          productoId: widget.producto.id,
          cantidad: cantidad.toDouble(),
          signo: 1,
          observacion: "$motivo - Stock anterior: $stockAnterior",
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Entrada registrada: +$cantidad ${widget.producto.nombre}",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo registrar la entrada: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Icon(Icons.move_to_inbox, color: Color(0xff0A2E6E)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Registrar entrada",
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
                        Text("Stock actual: ${widget.producto.stock} und"),
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
                labelText: "Cantidad",
                hintText: "Ejemplo: 24",
                prefixIcon: const Icon(Icons.add_box),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: _motivoController,
              decoration: InputDecoration(
                labelText: "Motivo",
                hintText: "Ejemplo: Compra",
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
          label: const Text("Cancelar"),
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
          label: Text(_guardando ? "Guardando..." : "Registrar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A2E6E),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
