import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/movimiento_inventario_service.dart';

class KardexScreen extends StatefulWidget {
  const KardexScreen({super.key});

  @override
  State<KardexScreen> createState() => _KardexScreenState();
}

class _KardexScreenState extends State<KardexScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<MovimientoInventarioService>().cargarMovimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovimientoInventarioService>(
      builder: (context, service, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Kardex"),
          ),
          body: service.movimientos.isEmpty
              ? const Center(
            child: Text("No existen movimientos."),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.movimientos.length,
            itemBuilder: (context, index) {
              final movimiento = service.movimientos[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: movimiento.signo > 0
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Text(
                      movimiento.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    movimiento.nombreItem,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movimiento.tipo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movimiento.observacion ?? "",
                      ),
                    ],
                  ),
                  trailing: Text(
                    "${movimiento.signo > 0 ? "+" : "-"}${movimiento.cantidad} ${movimiento.unidad}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: movimiento.signo > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}