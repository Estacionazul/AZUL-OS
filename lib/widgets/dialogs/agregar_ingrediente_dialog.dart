import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insumo_model.dart';
import '../../models/receta_detalle_model.dart';
import '../../models/receta_model.dart';

import '../../services/insumo_service.dart';
import '../../services/receta_detalle_service.dart';

class AgregarIngredienteDialog extends StatefulWidget {
  final RecetaModel receta;
  final RecetaDetalleModel? ingrediente;

  const AgregarIngredienteDialog({
    super.key,
    required this.receta,
    this.ingrediente,
  });

  @override
  State<AgregarIngredienteDialog> createState() =>
      _AgregarIngredienteDialogState();
}

class _AgregarIngredienteDialogState extends State<AgregarIngredienteDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cantidadController = TextEditingController();

  InsumoModel? _insumoSeleccionado;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final insumoService = context.read<InsumoService>();

      await insumoService.obtenerTodos();

      if (!mounted) return;

      if (widget.ingrediente != null) {
        _cantidadController.text = widget.ingrediente!.cantidad.toString();

        _insumoSeleccionado = insumoService.insumos.firstWhere(
          (i) => i.id == widget.ingrediente!.insumoId,
        );

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InsumoService>(
      builder: (context, insumoService, child) {
        final insumos = insumoService.insumos;

        debugPrint("INSUMOS ENCONTRADOS: ${insumos.length}");

        for (final i in insumos) {
          debugPrint("${i.id} - ${i.nombre}");
        }

        return AlertDialog(
          title: Text(
            widget.ingrediente == null
                ? "Agregar ingrediente"
                : "Editar ingrediente",
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<InsumoModel>(
                      value: _insumoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: "Insumo",
                        border: OutlineInputBorder(),
                      ),
                      items: insumos.map((insumo) {
                        return DropdownMenuItem(
                          value: insumo,
                          child: Text("${insumo.emoji} ${insumo.nombre}"),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return "Seleccione un insumo";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _insumoSeleccionado = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cantidadController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Cantidad",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Ingrese la cantidad";
                        }

                        final numero = double.tryParse(value);

                        if (numero == null || numero <= 0) {
                          return "Cantidad inválida";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _insumoSeleccionado == null
                            ? "Unidad: -"
                            : "Unidad: ${_insumoSeleccionado!.unidadMedida}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _guardando ? null : () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_insumoSeleccionado == null) return;

    setState(() {
      _guardando = true;
    });

    try {
      final detalle = RecetaDetalleModel(
        id: widget.ingrediente?.id,
        recetaId: widget.receta.id!,
        insumoId: _insumoSeleccionado!.id!,
        cantidad: double.parse(_cantidadController.text),
        unidad: _insumoSeleccionado!.unidadMedida,
        orden: widget.ingrediente?.orden ?? 0,
      );

      final service = context.read<RecetaDetalleService>();

      if (widget.ingrediente == null) {
        await service.agregarIngrediente(detalle);
      } else {
        await service.editarIngrediente(detalle);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }
}
