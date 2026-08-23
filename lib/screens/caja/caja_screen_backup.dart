import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;

import '../../database/app_database.dart';
import '../../repositories/cajas_repository.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  late final AppDatabase _database;
  late final CajasRepository _repository;

  Caja? _cajaActual;
  List<MovimientosCajaData> _movimientos = [];

  bool _cargando = true;

  @override
  void initState() {
    super.initState();

    _database = AppDatabase();
    _repository = CajasRepository(_database);

    _cargarCaja();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  // ==========================================================
  // CARGAR CAJA
  // ==========================================================

  Future<void> _cargarCaja() async {
    setState(() {
      _cargando = true;
    });

    final caja = await _repository.obtenerAbierta();

    List<MovimientosCajaData> movimientos = [];

    if (caja != null) {
      movimientos = await _repository.obtenerMovimientos(caja.id);
    }

    if (!mounted) return;

    setState(() {
      _cajaActual = caja;
      _movimientos = movimientos;
      _cargando = false;
    });
  }

  // ==========================================================
  // ABRIR CAJA
  // ==========================================================

  Future<void> _abrirCaja() async {
    final controlador = TextEditingController();

    final monto = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_open),
              SizedBox(width: 10),
              Text('Abrir caja'),
            ],
          ),
          content: TextField(
            controller: controlador,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Monto inicial',
              prefixText: 'S/ ',
              border: OutlineInputBorder(),
              helperText: 'Ingresa el efectivo con el que inicia la caja.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final valor = double.tryParse(
                  controlador.text.replaceAll(',', '.'),
                );

                if (valor == null || valor < 0) {
                  return;
                }

                Navigator.pop(context, valor);
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Abrir caja'),
            ),
          ],
        );
      },
    );

    controlador.dispose();

    if (monto == null) return;

    await _repository.abrir(
      montoInicial: monto,
    );

    await _cargarCaja();
  }

  // ==========================================================
  // CERRAR CAJA
  // ==========================================================

  Future<void> _cerrarCaja() async {
    final caja = _cajaActual;

    if (caja == null) return;

    final saldoEsperado = _saldoEsperado();

    final controlador = TextEditingController();

    // ----------------------------------------------------------
    // PRIMERA VENTANA: INGRESAR DINERO CONTADO
    // ----------------------------------------------------------

    final monto = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock),
              SizedBox(width: 10),
              Text('Cerrar caja'),
            ],
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de cierre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                _FilaCierre(
                  titulo: 'Monto inicial',
                  valor: caja.montoInicial,
                ),

                const SizedBox(height: 10),

                _FilaCierre(
                  titulo: 'Movimientos de efectivo',
                  valor: _totalMovimientos(),
                ),

                const Divider(height: 28),

                _FilaCierre(
                  titulo: 'SALDO ESPERADO',
                  valor: saldoEsperado,
                  destacado: true,
                ),

                const SizedBox(height: 22),

                TextField(
                  controller: controlador,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto contado físicamente',
                    prefixText: 'S/ ',
                    border: OutlineInputBorder(),
                    helperText:
                    'Cuenta únicamente el dinero físico de la caja.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final valor = double.tryParse(
                  controlador.text.replaceAll(',', '.'),
                );

                if (valor == null || valor < 0) {
                  return;
                }

                Navigator.pop(context, valor);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    controlador.dispose();

    if (monto == null) return;

    // ----------------------------------------------------------
    // CALCULAR DIFERENCIA
    // ----------------------------------------------------------

    final diferencia = monto - saldoEsperado;

    String titulo;
    String mensaje;
    IconData icono;

    if (diferencia.abs() < 0.01) {
      titulo = 'Caja cuadrada';
      mensaje =
      'El dinero contado coincide exactamente con el saldo esperado.';
      icono = Icons.check_circle;
    } else if (diferencia > 0) {
      titulo = 'Sobrante de caja';
      mensaje =
      'Hay más dinero físico del esperado.';
      icono = Icons.trending_up;
    } else {
      titulo = 'Faltante de caja';
      mensaje =
      'Hay menos dinero físico del esperado.';
      icono = Icons.warning;
    }

    // ----------------------------------------------------------
    // SEGUNDA VENTANA: CONFIRMAR CIERRE
    // ----------------------------------------------------------

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icono),
              const SizedBox(width: 10),
              Expanded(
                child: Text(titulo),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilaCierre(
                  titulo: 'Saldo esperado',
                  valor: saldoEsperado,
                ),

                const SizedBox(height: 10),

                _FilaCierre(
                  titulo: 'Monto contado',
                  valor: monto,
                ),

                const Divider(height: 28),

                _FilaCierre(
                  titulo: 'Diferencia',
                  valor: diferencia,
                  mostrarSigno: true,
                  destacado: true,
                ),

                const SizedBox(height: 18),

                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                const Text(
                  '¿Deseas cerrar definitivamente esta caja?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.lock),
              label: const Text('Cerrar caja'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    // ----------------------------------------------------------
    // GUARDAR CIERRE
    // ----------------------------------------------------------

    final cajaCerrada = caja.copyWith(
      fechaCierre: Value(DateTime.now()),
      montoCierre: Value(monto),
      estado: 'CERRADA',
    );

    await _repository.actualizar(cajaCerrada);

    await _cargarCaja();
  }

  // ==========================================================
  // MOVIMIENTOS QUE AFECTAN EL EFECTIVO
  // ==========================================================

  double _totalMovimientos() {
    double total = 0;

    for (final movimiento in _movimientos) {
      // --------------------------------------------------------
      // VENTA
      // --------------------------------------------------------
      //
      // Una venta solamente afecta Caja si fue pagada en efectivo.
      //
      if (movimiento.tipo == 'VENTA') {
        final metodo = movimiento.metodoPago
            ?.trim()
            .toLowerCase();

        if (metodo == 'efectivo') {
          total += movimiento.monto;
        }

        continue;
      }

      // --------------------------------------------------------
      // INGRESO
      // --------------------------------------------------------
      //
      // Los ingresos manuales representan entrada de efectivo.
      //
      if (movimiento.tipo == 'INGRESO') {
        total += movimiento.monto;
        continue;
      }

      // --------------------------------------------------------
      // EGRESO
      // --------------------------------------------------------
      //
      // Los egresos manuales representan salida de efectivo.
      //
      if (movimiento.tipo == 'EGRESO') {
        total -= movimiento.monto;
        continue;
      }

      // --------------------------------------------------------
      // OTROS TIPOS
      // --------------------------------------------------------
      //
      // APERTURA, CIERRE u otros movimientos no modifican
      // el efectivo esperado.
      //
    }

    return total;
  }

  // ==========================================================
  // SALDO ESPERADO
  // ==========================================================

  double _saldoEsperado() {
    if (_cajaActual == null) {
      return 0;
    }

    return _cajaActual!.montoInicial + _totalMovimientos();
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

    final caja = _cajaActual;

    // ========================================================
    // NO HAY CAJA ABIERTA
    // ========================================================

    if (caja == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.point_of_sale,
              size: 64,
            ),

            const SizedBox(height: 16),

            const Text(
              'No hay una caja abierta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Abre una caja para comenzar a registrar movimientos.',
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _abrirCaja,
              icon: const Icon(Icons.lock_open),
              label: const Text('Abrir caja'),
            ),
          ],
        ),
      );
    }

    // ========================================================
    // CAJA ABIERTA
    // ========================================================

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // ENCABEZADO
          // ----------------------------------------------------

          Row(
            children: [
              const Icon(
                Icons.point_of_sale,
                size: 32,
              ),

              const SizedBox(width: 12),

              const Text(
                'Caja',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: _cerrarCaja,
                icon: const Icon(Icons.lock),
                label: const Text('Cerrar caja'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ----------------------------------------------------
          // RESUMEN
          // ----------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _ResumenCard(
                  titulo: 'Monto inicial',
                  valor: caja.montoInicial,
                  icono: Icons.account_balance_wallet,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _ResumenCard(
                  titulo: 'Movimientos',
                  valor: _totalMovimientos(),
                  icono: Icons.swap_vert,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _ResumenCard(
                  titulo: 'Saldo esperado',
                  valor: _saldoEsperado(),
                  icono: Icons.calculate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ----------------------------------------------------
          // TÍTULO MOVIMIENTOS
          // ----------------------------------------------------

          const Text(
            'Movimientos de caja',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // LISTA
          // ----------------------------------------------------

          Expanded(
            child: _movimientos.isEmpty
                ? const Center(
              child: Text(
                'Todavía no hay movimientos registrados.',
              ),
            )
                : ListView.separated(
              itemCount: _movimientos.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (context, index) {
                final movimiento = _movimientos[index];

                final esEgreso =
                    movimiento.tipo == 'EGRESO';

                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      esEgreso
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                    ),
                  ),

                  title: Text(
                    movimiento.concepto,
                  ),

                  subtitle: Text(
                    '${movimiento.tipo}'
                        '${movimiento.metodoPago != null ? ' • ${movimiento.metodoPago}' : ''}',
                  ),

                  trailing: Text(
                    '${esEgreso ? '-' : '+'} '
                        'S/ ${movimiento.monto.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILA DEL RESUMEN DE CIERRE
// ============================================================

class _FilaCierre extends StatelessWidget {
  final String titulo;
  final double valor;
  final bool mostrarSigno;
  final bool destacado;

  const _FilaCierre({
    required this.titulo,
    required this.valor,
    this.mostrarSigno = false,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    String signo = '';

    if (mostrarSigno && valor > 0) {
      signo = '+ ';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontWeight:
            destacado ? FontWeight.bold : FontWeight.normal,
            fontSize: destacado ? 16 : 14,
          ),
        ),

        Text(
          '${signo}S/ ${valor.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight:
            destacado ? FontWeight.bold : FontWeight.bold,
            fontSize: destacado ? 18 : 16,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TARJETA DE RESUMEN
// ============================================================

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final double valor;
  final IconData icono;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icono,
              size: 32,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'S/ ${valor.toStringAsFixed(2)}',
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
}