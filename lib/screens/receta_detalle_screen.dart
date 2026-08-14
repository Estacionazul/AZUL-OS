import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/receta_model.dart';
import '../services/producto_service.dart';
import '../services/receta_detalle_service.dart';

import '../widgets/dialogs/agregar_ingrediente_dialog.dart';
import '../services/insumo_service.dart';

class RecetaDetalleScreen extends StatefulWidget {
  final RecetaModel receta;

  const RecetaDetalleScreen({
    super.key,
    required this.receta,
  });

  @override
  State<RecetaDetalleScreen> createState() =>
      _RecetaDetalleScreenState();
}

class _RecetaDetalleScreenState
    extends State<RecetaDetalleScreen> {

@override
void initState() {
super.initState();

Future.microtask(() {
context.read<RecetaDetalleService>().cargarIngredientes(
widget.receta.id!,
);
});
}

@override
Widget build(BuildContext context) {
final producto = context
.watch<ProductoService>()
.obtenerProducto(widget.receta.productoId);

return Consumer<RecetaDetalleService>(
builder: (context, service, child) {
return Scaffold(
appBar: AppBar(
title: Text(widget.receta.nombre),
),

body: Padding(
padding: const EdgeInsets.all(16),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
child: ListTile(
leading: const CircleAvatar(
child: Icon(Icons.coffee),
),

title: Text(
producto?.nombre ??
widget.receta.nombre,
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

subtitle: Text(
"Ingredientes: ${service.cantidadIngredientes}",
),
),
),

const SizedBox(height: 20),

const Text(
"Ingredientes",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 12),

Expanded(
child: service.ingredientes.isEmpty
? const Center(
child: Text(
"Esta receta aún no tiene ingredientes.",
),
)
: _buildIngredientes(service),
),
],
),
),

  floatingActionButton: FloatingActionButton.extended(
    onPressed: () async {
      await showDialog(
        context: context,
        builder: (_) => AgregarIngredienteDialog(
          receta: widget.receta,
        ),
      );

      if (!mounted) return;

      await context.read<RecetaDetalleService>().cargarIngredientes(
        widget.receta.id!,
      );
    },
    icon: const Icon(Icons.add),
    label: const Text("Agregar ingrediente"),
  ),
);
},
);
}

Widget _buildIngredientes(
    RecetaDetalleService service,
    ) {
  return ListView.separated(
    itemCount: service.ingredientes.length,
    separatorBuilder: (_, __) =>
    const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final ingrediente =
      service.ingredientes[index];

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
            Colors.orange.shade100,
            child: const Icon(
              Icons.inventory_2,
              color: Colors.orange,
            ),
          ),
          title: FutureBuilder(
            future: context
                .read<InsumoService>()
                .obtenerPorId(ingrediente.insumoId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Cargando...");
              }

              final insumo = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${insumo.emoji} ${insumo.nombre}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    insumo.codigo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
          subtitle: Text(
            "${ingrediente.cantidad} ${ingrediente.unidad}",
          ),
trailing: Row(
mainAxisSize: MainAxisSize.min,
  children: [

    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
      tooltip: "Editar",
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (_) => AgregarIngredienteDialog(
            receta: widget.receta,
            ingrediente: ingrediente,
          ),
        );

        if (!mounted) return;

        await service.cargarIngredientes(
          widget.receta.id!,
        );
      },
    ),

    IconButton(
icon: const Icon(
Icons.delete,
color: Colors.red,
),
tooltip: "Eliminar",
onPressed: () async {
final confirmar = await showDialog<bool>(
context: context,
builder: (_) => AlertDialog(
title: const Text("Eliminar ingrediente"),
content: const Text(
"¿Deseas eliminar este ingrediente?",
),
actions: [
TextButton(
onPressed: () =>
Navigator.pop(context, false),
child: const Text("Cancelar"),
),
ElevatedButton(
onPressed: () =>
Navigator.pop(context, true),
child: const Text("Eliminar"),
),
],
),
);

if (confirmar == true) {
await service.eliminarIngrediente(
ingrediente,
);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Ingrediente eliminado correctamente.",
),
),
);
}
},
),
],
),
),
);
},
);
}
}