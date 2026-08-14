import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/recetas_service.dart';
import '../../services/produccion_service.dart';

class ProduccionScreen extends StatefulWidget {
  const ProduccionScreen({super.key});

  @override
  State<ProduccionScreen> createState() =>
      _ProduccionScreenState();
}

class _ProduccionScreenState
    extends State<ProduccionScreen> {
  final Map<int, TextEditingController>
  _cantidadControllers = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RecetasService>().cargarRecetas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecetasService>(
      builder: (context, service, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Producción"),
          ),

          body: service.recetas.isEmpty
              ? const Center(
            child: Text(
              "No existen recetas registradas.",
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: service.recetas.length,
            itemBuilder: (context, index) {
              final receta =
              service.recetas[index];
              final controller =
              _cantidadControllers.putIfAbsent(
                receta.id!,
                    () => TextEditingController(text: "1"),
              );

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.local_cafe,
                    ),
                  ),
                  title: Text(receta.nombre),
                  subtitle: Text(
                    "Producto ID: ${receta.productoId}",
                  ),
                  trailing: SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.end,
                      children: [

                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: controller,
                            keyboardType:
                            TextInputType.number,
                            decoration:
                            const InputDecoration(
                              labelText: "Cant.",
                              isDense: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        ElevatedButton.icon(
                          onPressed: () async {

                            final cantidad =
                            double.tryParse(controller.text);

                            if (cantidad == null || cantidad <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Cantidad inválida",
                                  ),
                                ),
                              );
                              return;
                            }

                            final serviceProduccion =
                            context.read<ProduccionService>();

                            final resultado =
                            await serviceProduccion.producir(
                              receta: receta,
                              cantidad: cantidad,
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultado),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.factory,
                          ),
                          label: const Text(
                            "Producir",
                          ),
                        ),
                      ],
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