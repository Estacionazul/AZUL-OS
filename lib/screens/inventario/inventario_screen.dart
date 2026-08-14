import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/dashboard_stat_card.dart';
import '../../models/insumo_model.dart';
import '../../services/insumo_service.dart';
import '../../widgets/dialogs/nuevo_insumo_dialog.dart';
import 'kardex_screen.dart';

class InventarioScreen extends StatelessWidget {
const InventarioScreen({super.key});

@override
Widget build(BuildContext context) {
final insumoService = context.watch<InsumoService>();
final insumos = insumoService.insumos;

final totalInsumos = insumos.length;

final stockBajo = insumos.where(
(i) =>
i.stock > 0 &&
i.stock <= i.stockMinimo,
).length;

final agotados = insumos.where(
(i) => i.stock <= 0,
).length;

return Scaffold(
backgroundColor: const Color(0xffF5F7FA),
appBar: AppBar(
title: const Text("INVENTARIO"),
centerTitle: true,
backgroundColor: const Color(0xff0A2E6E),
),
floatingActionButton: FloatingActionButton.extended(
backgroundColor: const Color(0xff0A2E6E),
icon: const Icon(
Icons.add,
color: Colors.white,
),
label: const Text(
"Nuevo Insumo",
style: TextStyle(
color: Colors.white,
),
),
onPressed: () async {
await showDialog(
context: context,
builder: (_) => const NuevoInsumoDialog(),
);
},
),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [

Row(
children: [

DashboardStatCard(
icon: Icons.inventory_2,
titulo: "Total",
valor: totalInsumos.toString(),
color: Colors.blue,
),

const SizedBox(width: 12),

DashboardStatCard(
icon: Icons.warning_amber_rounded,
titulo: "Stock Bajo",
valor: stockBajo.toString(),
color: Colors.orange,
),

const SizedBox(width: 12),

DashboardStatCard(
icon: Icons.cancel,
titulo: "Agotados",
valor: agotados.toString(),
color: Colors.red,
),

],
),

const SizedBox(height: 20),

AppSearchField(
hintText: "Buscar insumo...",
onChanged: (texto) {
insumoService.buscarInsumos(texto);
},
),

const SizedBox(height: 20),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.receipt_long),
      label: const Text("Ver Kardex"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0A2E6E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const KardexScreen(),
          ),
        );
      },
    ),
  ),

  const SizedBox(height: 20),

Expanded(
child: insumos.isEmpty
? const AppEmptyState(
icon: Icons.inventory_2_outlined,
titulo: "No hay insumos",
mensaje:
"Presiona 'Nuevo Insumo' para comenzar.",
)
: ListView.builder(
itemCount: insumos.length,
itemBuilder: (context, index) {
final insumo = insumos[index];

return Card(
elevation: 2,
margin: const EdgeInsets.only(
bottom: 12,
),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(14),
),
child: ListTile(
contentPadding:
const EdgeInsets.all(16),
leading: CircleAvatar(
radius: 28,
backgroundColor:
const Color(0xffEAF1FF),
child: Text(
insumo.emoji,
style: const TextStyle(
fontSize: 24,
),
),
),
title: Text(
insumo.nombre,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 17,
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
"Código: ${insumo.codigo}",
),
const SizedBox(height: 4),
Text(
"Stock: ${insumo.stock} ${insumo.unidadMedida}",
),
const SizedBox(height: 4),
Text(
"Costo: S/ ${insumo.costoCompra.toStringAsFixed(2)}",
),
const SizedBox(height: 8),

Builder(
builder: (_) {
if (insumo.stock <= 0) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color:
Colors.red.shade100,
borderRadius:
BorderRadius.circular(
20),
),
child: const Text(
"🔴 Agotado",
style: TextStyle(
color:
Colors.red,
fontWeight:
FontWeight.bold,
),
),
);
}

if (insumo.stock <=
insumo.stockMinimo) {
return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color: Colors.orange
.shade100,
borderRadius:
BorderRadius.circular(
20),
),
child: const Text(
"🟠 Stock Bajo",
style: TextStyle(
color:
Colors.orange,
fontWeight:
FontWeight.bold,
),
),
);
}

return Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 5,
),
decoration:
BoxDecoration(
color:
Colors.green.shade100,
borderRadius:
BorderRadius.circular(
20),
),
child: const Text(
"🟢 Stock Normal",
style: TextStyle(
color:
Colors.green,
fontWeight:
FontWeight.bold,
),
),
);
},
),
],
),
),
  trailing: PopupMenuButton<String>(
    onSelected: (value) async {
      switch (value) {
        case 'editar':
          await showDialog(
            context: context,
            builder: (_) => NuevoInsumoDialog(
              insumo: insumo,
            ),
          );
          break;

        case 'eliminar':
          final confirmar =
          await showDialog<bool>(
            context: context,
            builder: (_) => AppConfirmDialog(
              titulo: "Eliminar insumo",
              mensaje:
              "¿Deseas eliminar '${insumo.nombre}'?",
              textoConfirmar: "Eliminar",
              colorConfirmar: Colors.red,
            ),
          );

          if (confirmar == true &&
              insumo.id != null) {
            await insumoService.eliminar(
              insumo.id!,
            );
          }
          break;
      }
    },
    itemBuilder: (_) => const [
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
            Text(
              "Eliminar",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
},
),
),
],
),
),
);
}
}