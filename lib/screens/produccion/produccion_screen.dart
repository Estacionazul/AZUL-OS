import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/recetas_service.dart';
import '../../services/produccion_service.dart';
import '../../widgets/module_header.dart';

class ProduccionScreen extends StatefulWidget {
  const ProduccionScreen({super.key});

  @override
  State<ProduccionScreen> createState() => _ProduccionScreenState();
}

class _ProduccionScreenState extends State<ProduccionScreen> {
  final Map<int, TextEditingController> _cantidadControllers = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RecetasService>().cargarRecetas();
    });
  }

  @override
  void dispose() {
    for (final controller in _cantidadControllers.values) {
      controller.dispose();
    }

    _cantidadControllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecetasService>(
      builder: (context, service, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F7FA),

          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================================================
                // ENCABEZADO DEL MÓDULO
                // ========================================================
                const ModuleHeader(
                  icon: Icons.factory_outlined,
                  title: 'Producción',
                  subtitle: 'Gestiona la producción y el consumo de insumos',
                ),

                const SizedBox(height: 20),

                // ========================================================
                // CONTENIDO DE PRODUCCIÓN
                // ========================================================
                Expanded(
                  child: service.recetas.isEmpty
                      ? const Center(
                    child: Text(
                      "No existen recetas registradas.",
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: service.recetas.length,
                    itemBuilder: (context, index) {
                      final receta = service.recetas[index];

                      final controller =
                      _cantidadControllers.putIfAbsent(
                        receta.id!,
                            () => TextEditingController(text: "1"),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),

                          // ==================================================
                          // ICONO
                          // ==================================================
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xffEAF1FF),
                            child: Icon(
                              Icons.local_cafe,
                              color: Color(0xff0A2E6E),
                            ),
                          ),

                          // ==================================================
                          // RECETA
                          // ==================================================
                          title: Text(
                            receta.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Producto ID: ${receta.productoId}",
                            ),
                          ),

                          // ==================================================
                          // CANTIDAD + PRODUCIR
                          // ==================================================
                          trailing: SizedBox(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                                    double.tryParse(
                                      controller.text,
                                    );

                                    if (cantidad == null ||
                                        cantidad <= 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Cantidad inválida",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final serviceProduccion =
                                    context.read<
                                        ProduccionService>();

                                    final resultado =
                                    await serviceProduccion.producir(
                                      receta: receta,
                                      cantidad: cantidad,
                                    );

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(resultado),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.factory),
                                  label: const Text("Producir"),
                                ),
                              ],
                            ),
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
      },
    );
  }
}