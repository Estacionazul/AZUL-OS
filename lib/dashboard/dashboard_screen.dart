import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/app_card.dart';

import '../models/dashboard_resumen.dart';
import '../models/venta.dart';
import '../repositories/ventas_repository.dart';

import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/quick_action_card.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardScreen({
    super.key,
    this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _cargando = true;

  DashboardResumen? _resumen;

  List<Venta> _ultimasVentas = [];

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  // ==========================================================
  // CARGAR DASHBOARD
  // ==========================================================

  Future<void> _cargarDashboard() async {
    final repository = context.read<VentasRepository>();

    try {
      final resumen =
      await repository.obtenerResumenDashboard();

      final ventas =
      await repository.obtenerVentas();

      ventas.sort(
            (a, b) => b.fecha.compareTo(a.fecha),
      );

      if (!mounted) return;

      setState(() {
        _resumen = resumen;
        _ultimasVentas = ventas.take(8).toList();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cargar el Dashboard: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // FORMATO DE HORA
  // ==========================================================

  String _hora(DateTime fecha) {
    final hora =
    fecha.hour.toString().padLeft(2, '0');

    final minuto =
    fecha.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  // ==========================================================
  // CLIENTE
  // ==========================================================

  String _cliente(Venta venta) {
    final nombre =
    venta.nombreCliente?.trim();

    if (nombre != null && nombre.isNotEmpty) {
      return nombre;
    }

    return 'Cliente General';
  }

  // ==========================================================
  // FORMATO MONEDA
  // ==========================================================

  String _moneda(double valor) {
    return 'S/ ${valor.toStringAsFixed(2)}';
  }

  // ==========================================================
  // DETALLE DE VENTA
  // ==========================================================

  Future<void> _mostrarDetalleVenta(Venta venta) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Color(0xFF174D7A),
              ),
              const SizedBox(width: 10),
              Text(
                'Venta ${venta.numero}',
              ),
            ],
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ============================================
                  // INFORMACIÓN GENERAL
                  // ============================================

                  _detalleFila(
                    'Fecha',
                    '${venta.fecha.day.toString().padLeft(2, '0')}/'
                        '${venta.fecha.month.toString().padLeft(2, '0')}/'
                        '${venta.fecha.year}',
                  ),

                  _detalleFila(
                    'Hora',
                    _hora(venta.fecha),
                  ),

                  _detalleFila(
                    'Cliente',
                    _cliente(venta),
                  ),

                  _detalleFila(
                    'Documento',
                    venta.tipoDocumento,
                  ),

                  _detalleFila(
                    'Método de pago',
                    venta.metodoPago,
                  ),

                  const Divider(height: 28),

                  // ============================================
                  // PRODUCTOS
                  // ============================================

                  const Text(
                    'Productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (venta.items.isEmpty)
                    const Text(
                      'No hay productos registrados.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  else
                    ...venta.items.map(
                          (item) {
                        final personalizaciones = <Widget>[];

                        if (item.tamano != null &&
                            item.tamano!.trim().isNotEmpty) {
                          personalizaciones.add(
                            Text(
                              'Tamaño: ${item.tamano}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (item.tipoLeche != null &&
                            item.tipoLeche!.trim().isNotEmpty) {
                          personalizaciones.add(
                            Text(
                              'Leche: ${item.tipoLeche}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (item.endulzante != null &&
                            item.endulzante!.trim().isNotEmpty) {
                          personalizaciones.add(
                            Text(
                              'Endulzante: ${item.endulzante}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (item.infusion != null &&
                            item.infusion!.trim().isNotEmpty) {
                          personalizaciones.add(
                            Text(
                              'Infusión: ${item.infusion}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (item.extraShot) {
                          personalizaciones.add(
                            const Text(
                              'Extra shot: Sí',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        if (item.observaciones != null &&
                            item.observaciones!.trim().isNotEmpty) {
                          personalizaciones.add(
                            Text(
                              'Observación: ${item.observaciones}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 14,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      '${item.cantidad} x '
                                          '${_moneda(item.precioUnitario)}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),

                                    if (personalizaciones.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      ...personalizaciones.map(
                                            (detalle) => Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: detalle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              Text(
                                _moneda(item.subtotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const Divider(height: 28),

                  // ============================================
                  // TOTALES
                  // ============================================

                  _detalleFila(
                    'Subtotal',
                    _moneda(venta.subtotal),
                  ),

                  _detalleFila(
                    'Descuento',
                    _moneda(venta.descuento),
                  ),

                  _detalleFila(
                    'IGV',
                    _moneda(venta.igv),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFE8F1F8),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _moneda(venta.total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Color(0xFF174D7A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (venta.observaciones != null &&
                      venta.observaciones!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 20),

                    const Text(
                      'Observaciones',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      venta.observaciones!.trim(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detalleFila(
      String titulo,
      String valor,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final resumen = _resumen!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // KPIs
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          icon: Icons.today,
                          titulo: 'Ventas Hoy',
                          valor:
                          'S/ ${resumen.ventasHoy.toStringAsFixed(2)}',
                          color: AppColors.success,
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.calendar_month,
                          titulo: 'Ventas del Mes',
                          valor:
                          'S/ ${resumen.ventasMes.toStringAsFixed(2)}',
                          color: AppColors.info,
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.receipt_long,
                          titulo: 'Tickets Hoy',
                          valor:
                          resumen.ticketsHoy.toString(),
                          color: Colors.brown,
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.people,
                          titulo: 'Clientes Hoy',
                          valor:
                          resumen.clientesHoy.toString(),
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.md,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          icon:
                          Icons.receipt_long_outlined,
                          titulo: 'Tickets del Mes',
                          valor:
                          resumen.ticketsMes.toString(),
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: KpiCard(
                          icon: Icons.people_outline,
                          titulo: 'Clientes del Mes',
                          valor:
                          resumen.clientesMes.toString(),
                          color: AppColors.info,
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      const Expanded(
                        child: SizedBox(),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      const Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ==================================================
                  // ACCIONES RÁPIDAS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.local_cafe,
                          titulo: 'Cafetería',
                          color: Colors.brown,
                          onTap: () => widget.onNavigate?.call(1),
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.inventory_2,
                          titulo: 'Inventario',
                          color: Colors.indigo,
                          onTap: () => widget.onNavigate?.call(3),
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.people,
                          titulo: 'Clientes',
                          color: AppColors.info,
                          onTap: () => widget.onNavigate?.call(7),
                        ),
                      ),

                      const SizedBox(
                        width: AppSpacing.md,
                      ),

                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.bar_chart,
                          titulo: 'Reportes',
                          color: AppColors.success,
                          onTap: () => widget.onNavigate?.call(9),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // ==================================================
                  // ÚLTIMAS VENTAS
                  // ==================================================

                  AppCard(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                color:
                                Color(0xFF174D7A),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      'Últimas ventas',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Movimientos registrados recientemente',
                                      style: TextStyle(
                                        color:
                                        Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TextButton.icon(
                                onPressed: () => widget.onNavigate?.call(9),
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Ver todas',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          if (_ultimasVentas.isEmpty)
                            const Padding(
                              padding:
                              EdgeInsets.all(25),
                              child: Center(
                                child: Text(
                                  'Todavía no hay ventas registradas.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              scrollDirection:
                              Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 34,
                                columns: const [
                                  DataColumn(
                                    label:
                                    Text('Hora'),
                                  ),
                                  DataColumn(
                                    label:
                                    Text('Venta'),
                                  ),
                                  DataColumn(
                                    label:
                                    Text('Cliente'),
                                  ),
                                  DataColumn(
                                    label:
                                    Text('Pago'),
                                  ),
                                  DataColumn(
                                    label:
                                    Text('Total'),
                                  ),
                                ],
                                rows:
                                _ultimasVentas
                                    .map(
                                      (venta) {
                                        return DataRow(
                                          onSelectChanged: (_) {
                                            _mostrarDetalleVenta(venta);
                                          },
                                          cells: [
                                        DataCell(
                                          Text(
                                            _hora(
                                              venta
                                                  .fecha,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            venta
                                                .numero,
                                            style:
                                            const TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _cliente(
                                              venta,
                                            ),
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            venta
                                                .metodoPago,
                                          ),
                                        ),

                                        DataCell(
                                          Text(
                                            _moneda(
                                              venta
                                                  .total,
                                            ),
                                            style:
                                            const TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}