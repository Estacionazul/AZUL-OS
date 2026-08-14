import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/insumo_model.dart';
import '../../services/insumo_service.dart';

class NuevoInsumoDialog extends StatefulWidget {
  final InsumoModel? insumo;

  const NuevoInsumoDialog({
    super.key,
    this.insumo,
  });

  @override
  State<NuevoInsumoDialog> createState() => _NuevoInsumoDialogState();
}

class _NuevoInsumoDialogState extends State<NuevoInsumoDialog> {
final _formKey = GlobalKey<FormState>();

final _codigoController = TextEditingController();
final _nombreController = TextEditingController();
final _stockController = TextEditingController(text: "0");
final _stockMinimoController = TextEditingController(text: "0");
final _costoController = TextEditingController(text: "0");

String _unidad = "g";
String _emoji = "☕";

bool _guardando = false;

@override
void initState() {
super.initState();

if (widget.insumo != null) {
final insumo = widget.insumo!;

_codigoController.text = insumo.codigo;
_nombreController.text = insumo.nombre;
_stockController.text = insumo.stock.toString();
_stockMinimoController.text = insumo.stockMinimo.toString();
_costoController.text = insumo.costoCompra.toString();

_unidad = insumo.unidadMedida;
_emoji = insumo.emoji;
}
}

Future<void> _guardar() async {
if (!_formKey.currentState!.validate()) {
return;
}

setState(() {
_guardando = true;
});

final insumo = InsumoModel(
id: widget.insumo?.id,
codigo: _codigoController.text.trim(),
nombre: _nombreController.text.trim(),
descripcion: widget.insumo?.descripcion ?? '',
categoriaId: widget.insumo?.categoriaId ?? 1,
unidadMedida: _unidad,
stock: double.tryParse(_stockController.text) ?? 0,
stockMinimo:
double.tryParse(_stockMinimoController.text) ?? 0,
costoCompra:
double.tryParse(_costoController.text) ?? 0,
proveedorId: widget.insumo?.proveedorId,
emoji: _emoji,
imagen: widget.insumo?.imagen ?? '',
activo: widget.insumo?.activo ?? true,
);

if (widget.insumo == null) {
await context.read<InsumoService>().agregar(insumo);
} else {
await context.read<InsumoService>().actualizar(insumo);
}

if (!mounted) return;

Navigator.pop(context, true);
}

@override
Widget build(BuildContext context) {
return AlertDialog(
title: Text(
widget.insumo == null
? "Nuevo Insumo"
: "Editar Insumo",
),
content: SizedBox(
width: 420,
child: Form(
key: _formKey,
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: _codigoController,
decoration: const InputDecoration(
labelText: "Código",
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Ingrese el código";
}
return null;
},
),

const SizedBox(height: 16),

TextFormField(
controller: _nombreController,
decoration: const InputDecoration(
labelText: "Nombre del insumo",
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Ingrese el nombre";
}
return null;
},
),

const SizedBox(height: 16),

DropdownButtonFormField<String>(
value: _unidad,
decoration: const InputDecoration(
labelText: "Unidad",
),
items: const [
DropdownMenuItem(
value: "g",
child: Text("Gramos"),
),
DropdownMenuItem(
value: "ml",
child: Text("Mililitros"),
),
DropdownMenuItem(
value: "unidad",
child: Text("Unidad"),
),
],
onChanged: (value) {
setState(() {
_unidad = value!;
});
},
),

const SizedBox(height: 16),

TextFormField(
controller: _stockController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "Stock",
),
),

const SizedBox(height: 16),

TextFormField(
controller: _stockMinimoController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "Stock mínimo",
),
),

const SizedBox(height: 16),

TextFormField(
controller: _costoController,
keyboardType:
const TextInputType.numberWithOptions(
decimal: true,
),
decoration: const InputDecoration(
labelText: "Costo de compra",
),
),

const SizedBox(height: 20),

DropdownButtonFormField<String>(
value: _emoji,
decoration: const InputDecoration(
labelText: "Emoji",
),
items: const [
DropdownMenuItem(
value: "☕",
child: Text("☕ Café"),
),
DropdownMenuItem(
value: "🥛",
child: Text("🥛 Lácteo"),
),
DropdownMenuItem(
value: "🥤",
child: Text("🥤 Bebida"),
),
DropdownMenuItem(
value: "🍞",
child: Text("🍞 Pan"),
),
DropdownMenuItem(
value: "🍫",
child: Text("🍫 Chocolate"),
),
DropdownMenuItem(
value: "🧂",
child: Text("🧂 Insumo"),
),
],
onChanged: (value) {
setState(() {
_emoji = value!;
});
},
),
],
),
),
),
),
  actions: [
    TextButton(
      onPressed: _guardando
          ? null
          : () => Navigator.pop(context),
      child: const Text("Cancelar"),
    ),
    ElevatedButton(
      onPressed: _guardando ? null : _guardar,
      child: _guardando
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : Text(
        widget.insumo == null
            ? "Guardar"
            : "Actualizar",
      ),
    ),
  ],
);
}

@override
void dispose() {
  _codigoController.dispose();
  _nombreController.dispose();
  _stockController.dispose();
  _stockMinimoController.dispose();
  _costoController.dispose();
  super.dispose();
}
}