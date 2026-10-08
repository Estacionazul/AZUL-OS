import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/dashboard_stat_card.dart';
import '../../services/insumo_service.dart';
import '../../services/producto_service.dart';
import '../../services/disponibilidad_producto_service.dart';
import '../../core/security/autorizacion_ceo_dialog.dart';
import '../../widgets/dialogs/nuevo_insumo_dialog.dart';
import '../../widgets/dialogs/registrar_entrada_producto_dialog.dart';
import '../../widgets/dialogs/ajustar_stock_producto_dialog.dart';
import '../../widgets/dialogs/registrar_entrada_insumo_dialog.dart';
import '../../widgets/dialogs/ajustar_stock_insumo_dialog.dart';
import '../../widgets/module_header.dart';
import 'kardex_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _busqueda = '';
  String _filtroStock = 'todos';

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

      // ==========================================================
      // NUEVO INSUMO
      // ==========================================================
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

      // ==========================================================
      // CONTENIDO
      // ==========================================================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // ENCABEZADO DEL MÓDULO
            // ========================================================
            const ModuleHeader(
              icon: Icons.inventory_2_outlined,
              title: 'Inventario',
              subtitle: 'Gestiona el stock y los movimientos de inventario',
            ),

            const SizedBox(height: 20),

            // ========================================================
            // ESTADÍSTICAS
            // ========================================================
            FutureBuilder<List<int>>(
              future: _calcularEstadisticas(
                insumosFiltrados,
                productosFiltrados,
                disponibilidadService,
              ),
              builder: (context, snapshot) {
                final estadisticas = snapshot.data ?? [0, 0, 0];

                final total = estadisticas[0];
                final stockBajo = estadisticas[1];
                final agotados = estadisticas[2];

                return Row(
                  children: [
                    Expanded(
                      child: _StatCardFiltro(
                        seleccionado: _filtroStock == 'todos',
                        onTap: () {
                          setState(() {
                            _filtroStock = 'todos';
                          });
                        },
                        child: DashboardStatCard(
                          icon: Icons.inventory_2,
                          titulo: "Total",
                          valor: total.toString(),
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCardFiltro(
                        seleccionado: _filtroStock == 'bajo',
                        onTap: () {
                          setState(() {
                            _filtroStock = 'bajo';
                          });
                        },
                        child: DashboardStatCard(
                          icon: Icons.warning_amber_rounded,
                          titulo: "Stock Bajo",
                          valor: stockBajo.toString(),
                          color: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _StatCardFiltro(
                        seleccionado: _filtroStock == 'agotados',
                        onTap: () {
                          setState(() {
                            _filtroStock = 'agotados';
                          });
                        },
                        child: DashboardStatCard(
                          icon: Icons.cancel,
                          titulo: "Agotados",
                          valor: agotados.toString(),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // ========================================================
            // BUSCADOR
            // ========================================================
            AppSearchField(
              hintText: "Buscar producto o insumo...",
              onChanged: buscar,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  _filtroStock == 'todos'
                      ? Icons.inventory_2_outlined
                      : _filtroStock == 'bajo'
                          ? Icons.warning_amber_rounded
                          : Icons.cancel_outlined,
                  size: 18,
                  color: const Color(0xff0A2E6E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _filtroStock == 'todos'
                        ? 'Mostrando todos los productos e insumos'
                        : _filtroStock == 'bajo'
                            ? 'Mostrando productos e insumos con stock bajo'
                            : 'Mostrando productos e insumos agotados',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xff475569),
                    ),
                  ),
                ),
                if (_filtroStock != 'todos')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _filtroStock = 'todos';
                      });
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Ver todos'),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ========================================================
            // KARDEX
            // ========================================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text("Ver Kardex"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0A2E6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

            // ========================================================
            // LISTA
            // ========================================================
            Expanded(
              child: insumosFiltrados.isEmpty &&
                  productosFiltrados.isEmpty
                  ? const AppEmptyState(
                icon: Icons.inventory_2_outlined,
                titulo: "No hay productos ni insumos",
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
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "INSUMOS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0A2E6E),
                        ),
                      ),
                    ),

                    ...insumosFiltrados.where((insumo) {
                      if (_filtroStock == 'agotados') {
                        return insumo.stock <= 0;
                      }
                      if (_filtroStock == 'bajo') {
                        return insumo.stock > 0 &&
                            insumo.stock <= insumo.stockMinimo;
                      }
                      return true;
                    }).map((insumo) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                              style:
                              const TextStyle(fontSize: 24),
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
                                const Text("Tipo: Insumo"),

                                const SizedBox(height: 4),

                                Text(
                                  "Código: ${insumo.codigo}",
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Stock: ${insumo.stock} ${insumo.unidadMedida}",
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Stock mínimo: ${insumo.stockMinimo} ${insumo.unidadMedida}",
                                ),

                                const SizedBox(height: 8),

                                _EstadoStock(
                                  stock: insumo.stock,
                                  stockMinimo:
                                  insumo.stockMinimo,
                                ),
                              ],
                            ),
                          ),

                          // ==============================================
                          // ACCIONES DE STOCK DEL INSUMO
                          // ==============================================
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Registrar entrada',
                                icon: const Icon(
                                  Icons.move_to_inbox,
                                  color: Color(0xff0A2E6E),
                                ),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) =>
                                        RegistrarEntradaInsumoDialog(
                                      insumo: insumo,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Ajustar stock',
                                icon: const Icon(
                                  Icons.tune,
                                  color: Color(0xff0A2E6E),
                                ),
                                onPressed: () async {
                                  final autorizado =
                                      await AutorizacionCeoDialog.verificar(
                                    context,
                                  );

                                  if (!autorizado || !context.mounted) {
                                    return;
                                  }

                                  await showDialog(
                                    context: context,
                                    builder: (_) =>
                                        AjustarStockInsumoDialog(
                                      insumo: insumo,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  // ==================================
                  // PRODUCTOS
                  // ==================================
                  if (productosFiltrados.isNotEmpty) ...[
                    const SizedBox(height: 8),

                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "PRODUCTOS",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0A2E6E),
                        ),
                      ),
                    ),

                    ...productosFiltrados.map((producto) {
                      return FutureBuilder<int>(
                        future: disponibilidadService
                            .calcularDisponibilidad(producto),
                        builder: (context, snapshot) {
                          final stock = snapshot.data ?? 0;

                          if (_filtroStock == 'agotados' && stock > 0) {
                            return const SizedBox.shrink();
                          }

                          if (_filtroStock == 'bajo' &&
                              (stock <= 0 || stock > producto.stockMinimo)) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            elevation: 2,
                            margin:
                            const EdgeInsets.only(bottom: 12),
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
                                  producto.emoji,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),

                              title: Text(
                                producto.nombre,
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
                                      producto.tipoInventario ==
                                          'receta'
                                          ? "Tipo: Producto preparado"
                                          : "Tipo: Producto",
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Código: ${producto.codigo}",
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Categoría: ${_nombreCategoria(producto.categoriaId)}",
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      snapshot.connectionState ==
                                          ConnectionState.waiting
                                          ? "Stock: Calculando..."
                                          : "Stock: $stock und",
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "Stock mínimo: ${producto.stockMinimo} und",
                                    ),

                                    const SizedBox(height: 8),

                                    _EstadoStock(
                                      stock: stock,
                                      stockMinimo:
                                      producto.stockMinimo,
                                    ),
                                  ],
                                ),
                              ),

                              // ==============================================
                              // ACCIONES DE STOCK DEL PRODUCTO FÍSICO
                              //
                              // Los productos por receta no modifican stock
                              // directamente: su inventario depende de insumos.
                              // ==============================================
                              trailing: producto.tipoInventario == 'producto'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Registrar entrada',
                                          icon: const Icon(
                                            Icons.move_to_inbox,
                                            color: Color(0xff0A2E6E),
                                          ),
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  RegistrarEntradaProductoDialog(
                                                producto: producto,
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          tooltip: 'Ajustar stock',
                                          icon: const Icon(
                                            Icons.tune,
                                            color: Color(0xff0A2E6E),
                                          ),
                                          onPressed: () async {
                                            final autorizado =
                                                await AutorizacionCeoDialog.verificar(
                                              context,
                                            );

                                            if (!autorizado ||
                                                !context.mounted) {
                                              return;
                                            }

                                            await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  AjustarStockProductoDialog(
                                                producto: producto,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    }),
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
      final stock = await service.calcularDisponibilidad(producto);

      if (stock <= 0) {
        agotados++;
      } else if (stock <= producto.stockMinimo) {
        stockBajo++;
      }
    }

    return [total, stockBajo, agotados];
  }

  String _nombreCategoria(int id) {
    switch (id) {
      case 1:
        return "Cafés";
      case 2:
        return "Jugos Naturales";
      case 3:
        return "Bebidas Frías";
      case 4:
        return "Snacks";
      case 5:
        return "Hamburguesas";
      case 6:
        return "Postres";
      case 7:
        return "Combos";
      case 9:
        return "Gaseosas y Aguas";
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
          borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
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

class _StatCardFiltro extends StatelessWidget {
  final bool seleccionado;
  final VoidCallback onTap;
  final Widget child;

  const _StatCardFiltro({
    required this.seleccionado,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado
              ? const Color(0xff0A2E6E)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
