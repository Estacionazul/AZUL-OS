import 'package:flutter/material.dart';

import '../models/venta.dart' as model;
import '../database/app_database.dart';
import '../repositories/ventas_repository.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  late final AppDatabase _database;
  late final VentasRepository _repository;

  List<model.Venta> _ventas = [];

  bool _cargando = true;

  String _periodo = 'Hoy';

  @override
  void initState() {
    super.initState();

    _database = AppDatabase();
    _repository = VentasRepository(_database);

    _cargarReportes();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  // ==========================================================
  // CARGAR REPORTES
  // ==========================================================

  Future<void> _cargarReportes() async {
    setState(() {
      _cargando = true;
    });

    try {
      final ventas = await _repository.obtenerVentas();

      if (!mounted) return;

      setState(() {
        _ventas = ventas;
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
            'No se pudieron cargar los reportes: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // VENTAS FILTRADAS
  // ==========================================================

  List<model.Venta> get _ventasFiltradas {
    final ahora = DateTime.now();

    switch (_periodo) {
      case 'Hoy':
        return _ventas.where((venta) {
          return venta.fecha.year == ahora.year &&
              venta.fecha.month == ahora.month &&
              venta.fecha.day == ahora.day;
        }).toList();

      case '7 días':
        final inicio = DateTime(
          ahora.year,
          ahora.month,
          ahora.day,
        ).subtract(
          const Duration(days: 6),
        );

        return _ventas.where((venta) {
          return !venta.fecha.isBefore(inicio);
        }).toList();

      case 'Este mes':
        return _ventas.where((venta) {
          return venta.fecha.year == ahora.year &&
              venta.fecha.month == ahora.month;
        }).toList();

      case 'Todo':
        return List<model.Venta>.from(_ventas);

      default:
        return List<model.Venta>.from(_ventas);
    }
  }

  // ==========================================================
  // TOTALES
  // ==========================================================

  double get _totalVendido {
    return _ventasFiltradas.fold<double>(
      0,
          (total, venta) => total + venta.total,
    );
  }

  double get _totalDescuentos {
    return _ventasFiltradas.fold<double>(
      0,
          (total, venta) => total + venta.descuento,
    );
  }

  int get _cantidadVentas {
    return _ventasFiltradas.length;
  }

  int get _cantidadClientes {
    final clientes = <String>{};

    for (final venta in _ventasFiltradas) {
      final nombre = venta.nombreCliente?.trim();

      if (nombre != null && nombre.isNotEmpty) {
        clientes.add(nombre);
      }
    }

    return clientes.length;
  }

  // ==========================================================
  // TOTAL POR MÉTODO DE PAGO
  // ==========================================================

  double _totalPorMetodo(String metodo) {
    return _ventasFiltradas
        .where(
          (venta) =>
      venta.metodoPago.toLowerCase() ==
          metodo.toLowerCase(),
    )
        .fold<double>(
      0,
          (total, venta) => total + venta.total,
    );
  }

  // ==========================================================
  // FORMATO MONEDA
  // ==========================================================

  String _moneda(double valor) {
    return 'S/ ${valor.toStringAsFixed(2)}';
  }

  // ==========================================================
  // FORMATO FECHA
  // ==========================================================

  String _fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _hora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          _encabezado(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarReportes,
              child: ListView(
                padding: const EdgeInsets.all(28),
                children: [
                  _filtros(),

                  const SizedBox(height: 24),

                  _resumen(),

                  const SizedBox(height: 24),

                  _pagos(),

                  const SizedBox(height: 24),

                  _clientes(),

                  const SizedBox(height: 24),

                  _tablaVentas(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ENCABEZADO
  // ==========================================================

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        28,
        24,
        28,
        20,
      ),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(
            Icons.bar_chart_rounded,
            size: 34,
            color: Color(0xFF174D7A),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reportes',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Resumen y análisis de las ventas de Estación Azul',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargarReportes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTROS
  // ==========================================================

  Widget _filtros() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF174D7A),
            ),

            const SizedBox(width: 12),

            const Text(
              'Periodo:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 14),

            DropdownButton<String>(
              value: _periodo,
              items: const [
                DropdownMenuItem(
                  value: 'Hoy',
                  child: Text('Hoy'),
                ),
                DropdownMenuItem(
                  value: '7 días',
                  child: Text('Últimos 7 días'),
                ),
                DropdownMenuItem(
                  value: 'Este mes',
                  child: Text('Este mes'),
                ),
                DropdownMenuItem(
                  value: 'Todo',
                  child: Text('Todo'),
                ),
              ],
              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  _periodo = valor;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RESUMEN
  // ==========================================================

  Widget _resumen() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,

      // Altura fija para evitar overflow vertical
      // en las tarjetas del resumen.
      mainAxisExtent: 100,

      children: [
        _tarjetaResumen(
          titulo: 'Ventas',
          valor: _moneda(_totalVendido),
          icono: Icons.attach_money_rounded,
        ),

        _tarjetaResumen(
          titulo: 'Cantidad de ventas',
          valor: '$_cantidadVentas',
          icono: Icons.receipt_long_rounded,
        ),

        _tarjetaResumen(
          titulo: 'Clientes',
          valor: '$_cantidadClientes',
          icono: Icons.people_alt_outlined,
        ),

        _tarjetaResumen(
          titulo: 'Descuentos',
          valor: _moneda(_totalDescuentos),
          icono: Icons.local_offer_outlined,
        ),
      ],
    );
  }

  Widget _tarjetaResumen({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: const Color(0xFF174D7A),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MÉTODOS DE PAGO
  // ==========================================================

  Widget _pagos() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: Color(0xFF174D7A),
                ),
                SizedBox(width: 10),
                Text(
                  'Ventas por método de pago',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _pago(
                    'Efectivo',
                    _totalPorMetodo('Efectivo'),
                    Icons.payments,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pago(
                    'Yape',
                    _totalPorMetodo('Yape'),
                    Icons.phone_android,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pago(
                    'Plin',
                    _totalPorMetodo('Plin'),
                    Icons.phone_iphone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pago(
                    'Tarjeta',
                    _totalPorMetodo('Tarjeta'),
                    Icons.credit_card,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pago(
                    'Transferencia',
                    _totalPorMetodo('Transferencia'),
                    Icons.account_balance,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pago(
      String nombre,
      double total,
      IconData icono,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: const Color(0xFF174D7A),
          ),

          const SizedBox(height: 10),

          Text(
            nombre,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _moneda(total),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CLIENTES
  // ==========================================================

  Widget _clientes() {
    final mapa = <String, double>{};

    for (final venta in _ventasFiltradas) {
      final nombre = venta.nombreCliente?.trim();

      if (nombre == null || nombre.isEmpty) {
        continue;
      }

      mapa[nombre] =
          (mapa[nombre] ?? 0) + venta.total;
    }

    final clientes = mapa.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      );

    final topClientes =
    clientes.take(5).toList();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: Color(0xFF174D7A),
                ),
                SizedBox(width: 10),
                Text(
                  'Clientes con mayor consumo',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (topClientes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'No hay ventas asociadas a clientes en este periodo.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...topClientes.asMap().entries.map(
                    (entrada) {
                  final posicion =
                      entrada.key + 1;
                  final cliente =
                      entrada.value;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('$posicion'),
                    ),
                    title: Text(cliente.key),
                    trailing: Text(
                      _moneda(cliente.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TABLA DE VENTAS
  // ==========================================================

  Widget _tablaVentas() {
    final ventas = _ventasFiltradas;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF174D7A),
                ),
                SizedBox(width: 10),
                Text(
                  'Detalle de ventas',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (ventas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(25),
                child: Center(
                  child: Text(
                    'No hay ventas para el periodo seleccionado.',
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
                  columns: const [
                    DataColumn(
                      label: Text('Fecha'),
                    ),
                    DataColumn(
                      label: Text('Hora'),
                    ),
                    DataColumn(
                      label: Text('Venta'),
                    ),
                    DataColumn(
                      label: Text('Cliente'),
                    ),
                    DataColumn(
                      label: Text('Documento'),
                    ),
                    DataColumn(
                      label: Text('Pago'),
                    ),
                    DataColumn(
                      label: Text('Subtotal'),
                    ),
                    DataColumn(
                      label: Text('Descuento'),
                    ),
                    DataColumn(
                      label: Text('Total'),
                    ),
                  ],
                  rows: ventas.map((venta) {
                    final cliente =
                    venta.nombreCliente?.trim();

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            _fecha(venta.fecha),
                          ),
                        ),

                        DataCell(
                          Text(
                            _hora(venta.fecha),
                          ),
                        ),

                        DataCell(
                          Text(
                            venta.numero,
                          ),
                        ),

                        DataCell(
                          Text(
                            cliente == null || cliente.isEmpty
                                ? 'Sin cliente'
                                : cliente,
                          ),
                        ),

                        DataCell(
                          Text(
                            venta.tipoDocumento,
                          ),
                        ),

                        DataCell(
                          Text(
                            venta.metodoPago,
                          ),
                        ),

                        DataCell(
                          Text(
                            _moneda(venta.subtotal),
                          ),
                        ),

                        DataCell(
                          Text(
                            _moneda(venta.descuento),
                          ),
                        ),

                        DataCell(
                          Text(
                            _moneda(venta.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}