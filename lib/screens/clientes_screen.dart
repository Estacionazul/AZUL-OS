import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cliente.dart';
import '../services/clientes_service.dart';
import '../widgets/dialogs/cliente_dialog.dart';
import '../widgets/dialogs/cliente_detalle_dialog.dart';
import '../widgets/module_header.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<ClienteModel> clientes = [];

  final TextEditingController _buscarController = TextEditingController();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarClientes() async {
    final lista = await context.read<ClientesService>().obtenerClientes();

    if (!mounted) return;

    setState(() {
      clientes = lista;
      cargando = false;
    });
  }

  Future<void> buscarClientes(String texto) async {
    debugPrint("Buscando: $texto");

    if (texto.trim().isEmpty) {
      await cargarClientes();
      return;
    }

    final lista = await context.read<ClientesService>().buscarPorNombre(texto);

    debugPrint("Clientes encontrados: ${lista.length}");

    for (final c in lista) {
      debugPrint(c.nombre);
    }

    if (!mounted) return;

    setState(() {
      clientes = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleHeader(
              icon: Icons.people_alt_rounded,
              title: 'Clientes',
              subtitle: 'Gestiona tus clientes y su información',
              trailing: FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => const ClienteDialog(),
                  );

                  await cargarClientes();
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo cliente'),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: _buscarController,
              onChanged: buscarClientes,
              decoration: InputDecoration(
                hintText: "Buscar por nombre, teléfono o DNI...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Builder(
                  builder: (_) {
                    if (cargando) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (clientes.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "No hay clientes registrados",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Presiona 'Nuevo cliente' para comenzar."),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: clientes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cliente = clientes[index];

                        return Card(
                          elevation: 1,
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              cliente.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cliente.telefono.isNotEmpty)
                                  Text("📱 ${cliente.telefono}"),
                                if (cliente.dni != null)
                                  Text("DNI: ${cliente.dni}"),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                switch (value) {
                                  case "detalle":
                                    await showDialog(
                                      context: context,
                                      builder: (_) => ClienteDetalleDialog(
                                        cliente: cliente,

                                        onEditar: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (_) =>
                                                ClienteDialog(cliente: cliente),
                                          );

                                          await cargarClientes();
                                        },

                                        onEliminar: () async {
                                          final confirmar = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                "Eliminar cliente",
                                              ),
                                              content: Text(
                                                "¿Deseas eliminar a '${cliente.nombre}'?\n\nEsta acción no se puede deshacer.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text("Cancelar"),
                                                ),
                                                FilledButton(
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text("Eliminar"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmar == true) {
                                            await context
                                                .read<ClientesService>()
                                                .eliminarCliente(cliente.id);

                                            await cargarClientes();

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Cliente eliminado correctamente",
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    );

                                    break;

                                  case "editar":
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ClienteDialog(cliente: cliente),
                                    );

                                    await cargarClientes();
                                    break;

                                  case "eliminar":
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: const Text("Eliminar cliente"),
                                          content: Text(
                                            "¿Deseas eliminar a '${cliente.nombre}'?\n\nEsta acción no se puede deshacer.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancelar"),
                                            ),
                                            FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text("Eliminar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmar == true) {
                                      await context
                                          .read<ClientesService>()
                                          .eliminarCliente(cliente.id);

                                      await cargarClientes();

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Cliente eliminado correctamente",
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    break;
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "detalle",
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined),
                                      SizedBox(width: 10),
                                      Text("Ver detalle"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "editar",
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 10),
                                      Text("Editar"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "eliminar",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Eliminar",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
