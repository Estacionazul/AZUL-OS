import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/app_search_field.dart';
import '../core/widgets/dashboard_stat_card.dart';
import '../services/recetas_service.dart';
import '../screens/receta_detalle_screen.dart';
import '../widgets/dialogs/nueva_receta_dialog.dart';

class RecetasScreen extends StatefulWidget {
  const RecetasScreen({super.key});

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
final TextEditingController _buscarController =
TextEditingController();

@override
void initState() {
super.initState();

Future.microtask(() {
context.read<RecetasService>().cargarRecetas();
});
}

@override
void dispose() {
_buscarController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Consumer<RecetasService>(
builder: (context, service, child) {
return Scaffold(
appBar: AppBar(
title: const Text("Recetas"),
),
floatingActionButton: FloatingActionButton.extended(
onPressed: () {
showDialog(
context: context,
builder: (_) => const NuevaRecetaDialog(),
);
},
icon: const Icon(Icons.add),
label: const Text("Nueva receta"),
),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Row(
children: [
Expanded(
child: DashboardStatCard(
icon: Icons.restaurant_menu,
titulo: "Total",
valor:
service.totalRecetas.toString(),
color: Colors.blue,
),
),
const SizedBox(width: 12),
Expanded(
child: DashboardStatCard(
icon: Icons.check_circle,
titulo: "Activas",
valor: service.recetasActivas
.toString(),
color: Colors.green,
),
),
const SizedBox(width: 12),
Expanded(
child: DashboardStatCard(
icon: Icons.cancel,
titulo: "Inactivas",
valor: service.recetasInactivas
.toString(),
color: Colors.red,
),
),
],
),

const SizedBox(height: 20),

AppSearchField(
controller: _buscarController,
hintText: "Buscar receta...",
onChanged: service.buscarRecetas,
),

const SizedBox(height: 20),

Expanded(
child: service.recetas.isEmpty
? const Center(
child: Text(
"No hay recetas registradas.",
style: TextStyle(
fontSize: 16,
),
),
)
: _buildListaRecetas(service),
),
],
),
),
);
},
);
}
Widget _buildListaRecetas(
RecetasService service,
) {
return ListView.separated(
itemCount: service.recetas.length,
separatorBuilder: (_, __) =>
const SizedBox(height: 12),
itemBuilder: (context, index) {
final receta = service.recetas[index];

return Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
child: ListTile(
contentPadding:
const EdgeInsets.symmetric(
horizontal: 18,
vertical: 12,
),
leading: CircleAvatar(
radius: 24,
backgroundColor:
Colors.orange.shade100,
child: const Icon(
Icons.restaurant_menu,
color: Colors.orange,
),
),
title: Text(
receta.nombre,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
subtitle: Padding(
padding:
const EdgeInsets.only(top: 8),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
"Producto ID: ${receta.productoId}",
),
const SizedBox(height: 8),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration: BoxDecoration(
color: receta.activo
? Colors.green
.shade100
: Colors.red.shade100,
borderRadius:
BorderRadius.circular(
20),
),
child: Text(
receta.activo
? "🟢 Activa"
: "🔴 Inactiva",
style:
const TextStyle(
fontWeight:
FontWeight.w600,
),
),
),
],
),
),
trailing: PopupMenuButton<String>(
onSelected: (value) {
switch (value) {
  case 'ingredientes':
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetaDetalleScreen(
          receta: receta,
        ),
      ),
    );
    break;

case 'editar':
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'La edición de recetas será habilitada en el siguiente sprint.',
),
),
);
break;

case 'eliminar':
_confirmarEliminar(
receta.id!,
);
break;
}
},
  itemBuilder: (_) => const [
    PopupMenuItem(
      value: 'ingredientes',
      child: Row(
        children: [
          Icon(Icons.restaurant),
          SizedBox(width: 8),
          Text("Ingredientes"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'editar',
      child: Row(
        children: [
          Icon(Icons.edit),
          SizedBox(width: 8),
          Text("Editar"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'eliminar',
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
          ),
          SizedBox(width: 8),
          Text("Eliminar"),
        ],
      ),
    ),
  ],
),
),
);
},
);
}
Future<void> _confirmarEliminar(int id) async {
final confirmar = await showDialog<bool>(
context: context,
builder: (_) => AlertDialog(
title: const Text('Eliminar receta'),
content: const Text(
'¿Deseas eliminar esta receta?',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context, false),
child: const Text('Cancelar'),
),
FilledButton(
onPressed: () => Navigator.pop(context, true),
child: const Text('Eliminar'),
),
],
),
);

if (confirmar == true && mounted) {
await context
.read<RecetasService>()
.eliminarReceta(id);
}
}
}