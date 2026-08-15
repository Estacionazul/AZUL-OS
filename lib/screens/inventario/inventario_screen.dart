import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/dashboard_stat_card.dart';
import '../../services/insumo_service.dart';
import '../../services/producto_service.dart';
import '../../services/disponibilidad_producto_service.dart';
import '../../widgets/dialogs/nuevo_insumo_dialog.dart';
import 'kardex_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final insumoService = context.watch<InsumoService>();
    final productoService = context.watch<ProductoService>();
    final disponibilidadService =
    context.read<DisponibilidadProductoService>();

    final insumos = insumoService.insumos;
    final productos = productoService.todosProductos;

    void buscar(String texto) {
      setState(() {
        _busqueda = texto.toLowerCase().trim();
      });

      insumoService.buscarInsumos(texto);
      productoService.buscarProductos(texto);
    }

    final insumosFiltrados = insumos.where((insumo) {
      if (_busqueda.isEmpty) return true;

      return insumo.nombre.toLowerCase().contains(_busqueda) ||
          insumo.codigo.toLowerCase().contains(_busqueda);
    }).toList();

    final productosFiltrados = productos.where((producto) {
      if (_busqueda.isEmpty) return true;

      return producto.nombre.toLowerCase().contains(_busqueda) ||
          producto.codigo.toLowerCase().contains(_busqueda);
    }).toList();

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

            // ==========================================
            // ESTADÍSTICAS
            // ==========================================

            FutureBuilder<List<int>>(
              future: _calcularEstadisticas(
                insumosFiltrados,
                productosFiltrados,
                disponibilidadService,
              ),
              builder: (context, snapshot) {
                final estadisticas =
                    snapshot.data ?? [0, 0, 0];

                final total = estadisticas[0];
                final stockBajo = estadisticas[1];
                final agotados = estadisticas[2];

                return Row(
                  children: [

                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.inventory_2,
                        titulo: "Total",
                        valor: total.toString(),
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.warning_amber_rounded,
                        titulo: "Stock Bajo",
                        valor: stockBajo.toString(),
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.cancel,
                        titulo: "Agotados",
                        valor: agotados.toString(),
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // ==========================================
            // BUSCADOR
            // ==========================================

            AppSearchField(
              hintText: "Buscar producto o insumo...",
              onChanged: buscar,
            ),

            const SizedBox(height: 20),

            // ==========================================
            // KARDEX
            // ==========================================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.receipt_long,
                ),
                label: const Text(
                  "Ver Kardex",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff0A2E6E),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const KardexScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // LISTA
            // ==========================================

            Expanded(
              child:
              insumosFiltrados.isEmpty &&
                  productosFiltrados.isEmpty
                  ? const AppEmptyState(
                icon:
                Icons.inventory_2_outlined,
                titulo:
                "No hay productos ni insumos",
                mensaje:
                "Agrega productos o insumos para comenzar.",
              )
                  : ListView(
                children: [

                  // ==================================
                  // INSUMOS
                  // ==================================

                  if (insumosFiltrados.isNotEmpty) ...[
                    const Padding(
                      padding:
                      EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Text(
                        "INSUMOS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xff0A2E6E),
                        ),
                      ),
                    ),

                    ...insumosFiltrados.map(
                          (insumo) {
                        return Card(
                          elevation: 2,
                          margin:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.all(
                              16,
                            ),

                            leading:
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                              const Color(
                                0xffEAF1FF,
                              ),
                              child: Text(
                                insumo.emoji,
                                style:
                                const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),

                            title: Text(
                              insumo.nombre,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            subtitle: Padding(
                              padding:
                              const EdgeInsets.only(
                                top: 8,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [

                                  const Text(
                                    "Tipo: Insumo",
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "Código: ${insumo.codigo}",
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "Stock: ${insumo.stock} ${insumo.unidadMedida}",
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    "Stock mínimo: ${insumo.stockMinimo} ${insumo.unidadMedida}",
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  _EstadoStock(
                                    stock:
                                    insumo.stock,
                                    stockMinimo:
                                    insumo.stockMinimo,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // ==================================
                  // PRODUCTOS
                  // ==================================

                  if (productosFiltrados.isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),

                    const Padding(
                      padding:
                      EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Text(
                        "PRODUCTOS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xff0A2E6E),
                        ),
                      ),
                    ),

                    ...productosFiltrados.map(
                          (producto) {
                        return FutureBuilder<int>(
                          future:
                          disponibilidadService
                              .calcularDisponibilidad(
                            producto,
                          ),
                          builder:
                              (context, snapshot) {
                            final stock =
                                snapshot.data ?? 0;

                            return Card(
                              elevation: 2,
                              margin:
                              const EdgeInsets.only(
                                bottom: 12,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                              child: ListTile(
                                contentPadding:
                                const EdgeInsets.all(
                                  16,
                                ),

                                leading:
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                  const Color(
                                    0xffEAF1FF,
                                  ),
                                  child: Text(
                                    producto.emoji,
                                    style:
                                    const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),

                                title: Text(
                                  producto.nombre,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [

                                      Text(
                                        producto.tipoInventario ==
                                            'receta'
                                            ? "Tipo: Producto preparado"
                                            : "Tipo: Producto",
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        "Código: ${producto.codigo}",
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        "Categoría: ${_nombreCategoria(producto.categoriaId)}",
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        snapshot.connectionState ==
                                            ConnectionState
                                                .waiting
                                            ? "Stock: Calculando..."
                                            : "Stock: $stock und",
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        "Stock mínimo: ${producto.stockMinimo} und",
                                      ),

                                      const SizedBox(
                                        height: 8,
                                      ),

                                      _EstadoStock(
                                        stock: stock,
                                        stockMinimo:
                                        producto
                                            .stockMinimo,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<int>> _calcularEstadisticas(
      List<dynamic> insumos,
      List<dynamic> productos,
      DisponibilidadProductoService service,
      ) async {
    int total = insumos.length + productos.length;
    int stockBajo = 0;
    int agotados = 0;

    for (final insumo in insumos) {
      if (insumo.stock <= 0) {
        agotados++;
      } else if (insumo.stock <= insumo.stockMinimo) {
        stockBajo++;
      }
    }

    for (final producto in productos) {
      final stock =
      await service.calcularDisponibilidad(producto);

      if (stock <= 0) {
        agotados++;
      } else if (stock <= producto.stockMinimo) {
        stockBajo++;
      }
    }

    return [
      total,
      stockBajo,
      agotados,
    ];
  }

  String _nombreCategoria(int id) {
    switch (id) {
      case 1:
        return "Cafés";
      case 2:
        return "Jugos";
      case 3:
        return "Snacks";
      case 4:
        return "Postres";
      case 5:
        return "Bebidas";
      default:
        return "General";
    }
  }
}

// ======================================================
// ESTADO DEL STOCK
// ======================================================

class _EstadoStock extends StatelessWidget {
  final num stock;
  final num stockMinimo;

  const _EstadoStock({
    required this.stock,
    required this.stockMinimo,
  });

  @override
  Widget build(BuildContext context) {
    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: const Text(
          "🔴 Agotado",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (stock <= stockMinimo) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: const Text(
          "🟠 Stock Bajo",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: const Text(
        "🟢 Stock Normal",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}