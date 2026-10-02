import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../facturacion/models/comprobante_electronico.dart';
import '../../../facturacion/repositories/comprobantes_electronicos_repository.dart';

class ComprobantesElectronicosScreen extends StatefulWidget {
  const ComprobantesElectronicosScreen({super.key});

  @override
  State<ComprobantesElectronicosScreen> createState() =>
      _ComprobantesElectronicosScreenState();
}

class _ComprobantesElectronicosScreenState
    extends State<ComprobantesElectronicosScreen> {
  static const azul = Color(0xff0A2E6E);
  static const fondo = Color(0xffF5F7FA);

  final _busqueda = TextEditingController();
  List<ComprobanteElectronico> _items = [];
  List<ComprobanteElectronico> _filtrados = [];
  String _tipo = 'Todos';
  String _estado = 'Todos';
  DateTime? _fechaFiltro;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(_filtrar);
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final repo = context.read<ComprobantesElectronicosRepository>();
      final rows = await repo.obtenerTodos();
      if (!mounted) return;
      _items = rows.map(_mapear).toList();
      _cargando = false;
      _filtrar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = e.toString();
      });
    }
  }

  ComprobanteElectronico _mapear(dynamic x) {
    return ComprobanteElectronico(
      id: x.id,
      ventaId: x.ventaId,
      tipo: _tipoDesde(x.tipo?.toString()),
      serie: x.serie?.toString() ?? '',
      numero: x.numero is int
          ? x.numero as int
          : int.tryParse(x.numero?.toString() ?? '') ?? 0,
      fechaEmision: x.fechaEmision is DateTime
          ? x.fechaEmision as DateTime
          : DateTime.now(),
      dni: x.dni?.toString(),
      ruc: x.ruc?.toString(),
      nombreCliente: x.nombreCliente?.toString(),
      razonSocial: x.razonSocial?.toString(),
      direccionFiscal: x.direccionFiscal?.toString(),
      subtotal: _num(x.subtotal),
      igv: _num(x.igv),
      total: _num(x.total),
      metodoPago: x.metodoPago?.toString() ?? '-',
      estado: _estadoDesde(x.estado?.toString()),
      codigoRespuestaSunat: x.codigoRespuestaSunat?.toString(),
      mensajeRespuestaSunat: x.mensajeRespuestaSunat?.toString(),
      fechaEnvioSunat: x.fechaEnvioSunat is DateTime
          ? x.fechaEnvioSunat as DateTime
          : null,
      fechaRespuestaSunat: x.fechaRespuestaSunat is DateTime
          ? x.fechaRespuestaSunat as DateTime
          : null,
    );
  }

  double _num(dynamic x) =>
      x is num ? x.toDouble() : double.tryParse(x?.toString() ?? '') ?? 0;

  TipoComprobanteElectronico _tipoDesde(String? x) {
    switch ((x ?? '').toLowerCase()) {
      case 'boleta':
        return TipoComprobanteElectronico.boleta;
      case 'factura':
        return TipoComprobanteElectronico.factura;
      case 'notacredito':
      case 'nota_credito':
        return TipoComprobanteElectronico.notaCredito;
      default:
        return TipoComprobanteElectronico.notaVenta;
    }
  }

  EstadoComprobanteElectronico _estadoDesde(String? x) {
    switch ((x ?? '').toLowerCase()) {
      case 'generado':
        return EstadoComprobanteElectronico.generado;
      case 'enviado':
        return EstadoComprobanteElectronico.enviado;
      case 'aceptado':
        return EstadoComprobanteElectronico.aceptado;
      case 'rechazado':
        return EstadoComprobanteElectronico.rechazado;
      case 'dadodebaja':
      case 'dado_de_baja':
        return EstadoComprobanteElectronico.dadoDeBaja;
      case 'anulado':
        return EstadoComprobanteElectronico.anulado;
      default:
        return EstadoComprobanteElectronico.pendiente;
    }
  }

  String _tipoNombre(TipoComprobanteElectronico x) {
    switch (x) {
      case TipoComprobanteElectronico.notaVenta:
        return 'Nota de venta';
      case TipoComprobanteElectronico.boleta:
        return 'Boleta';
      case TipoComprobanteElectronico.factura:
        return 'Factura';
      case TipoComprobanteElectronico.notaCredito:
        return 'Nota de crédito';
    }
  }

  String _estadoNombre(EstadoComprobanteElectronico x) {
    switch (x) {
      case EstadoComprobanteElectronico.pendiente:
        return 'Pendiente';
      case EstadoComprobanteElectronico.generado:
        return 'Generado';
      case EstadoComprobanteElectronico.enviado:
        return 'Enviado';
      case EstadoComprobanteElectronico.aceptado:
        return 'Aceptado';
      case EstadoComprobanteElectronico.rechazado:
        return 'Rechazado';
      case EstadoComprobanteElectronico.dadoDeBaja:
        return 'Dado de baja';
      case EstadoComprobanteElectronico.anulado:
        return 'Anulado';
    }
  }

  Color _color(EstadoComprobanteElectronico x) {
    switch (x) {
      case EstadoComprobanteElectronico.aceptado:
        return Colors.green;
      case EstadoComprobanteElectronico.rechazado:
      case EstadoComprobanteElectronico.anulado:
        return Colors.red;
      case EstadoComprobanteElectronico.enviado:
        return Colors.orange;
      case EstadoComprobanteElectronico.generado:
        return Colors.blue;
      case EstadoComprobanteElectronico.dadoDeBaja:
        return Colors.deepOrange;
      case EstadoComprobanteElectronico.pendiente:
        return Colors.grey;
    }
  }

  String _fecha(DateTime x) =>
      x.day.toString().padLeft(2, '0') +
      '/' +
      x.month.toString().padLeft(2, '0') +
      '/' +
      x.year.toString();

  String _importe(double x) => 'S/ ' + x.toStringAsFixed(2);

  void _filtrar() {
    if (!mounted) return;
    final q = _busqueda.text.trim().toLowerCase();
    final list = _items.where((x) {
      final tipoOk = _tipo == 'Todos' || _tipoNombre(x.tipo) == _tipo;
      final estadoOk =
          _estado == 'Todos' || _estadoNombre(x.estado) == _estado;
      final fechaOk = _fechaFiltro == null ||
          (x.fechaEmision.year == _fechaFiltro!.year &&
              x.fechaEmision.month == _fechaFiltro!.month &&
              x.fechaEmision.day == _fechaFiltro!.day);
      final cliente = (x.nombreCliente ?? '') +
          ' ' +
          (x.razonSocial ?? '') +
          ' ' +
          (x.dni ?? '') +
          ' ' +
          (x.ruc ?? '');
      final textoOk = q.isEmpty ||
          x.numeroCompleto.toLowerCase().contains(q) ||
          cliente.toLowerCase().contains(q);
      return tipoOk && estadoOk && fechaOk && textoOk;
    }).toList();
    list.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));
    setState(() => _filtrados = list);
  }

  Future<void> _elegirFecha() async {
    final x = await showDatePicker(
      context: context,
      initialDate: _fechaFiltro ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Filtrar por fecha',
    );
    if (x == null) return;
    setState(() => _fechaFiltro = x);
    _filtrar();
  }

  void _limpiar() {
    _busqueda.clear();
    setState(() {
      _tipo = 'Todos';
      _estado = 'Todos';
      _fechaFiltro = null;
    });
    _filtrar();
  }

  void _detalle(ComprobanteElectronico x) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(x.numeroCompleto),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dato('Tipo', _tipoNombre(x.tipo)),
                _dato('Fecha', _fecha(x.fechaEmision)),
                _dato('Cliente', x.nombreCliente ?? x.razonSocial ?? '-'),
                _dato('DNI', x.dni ?? '-'),
                _dato('RUC', x.ruc ?? '-'),
                _dato('Forma de pago', x.metodoPago),
                const Divider(height: 24),
                _dato('Subtotal', _importe(x.subtotal)),
                _dato('IGV', _importe(x.igv)),
                _dato('TOTAL', _importe(x.total), fuerte: true),
                const Divider(height: 24),
                _dato('Estado', _estadoNombre(x.estado)),
                _dato('Código SUNAT', x.codigoRespuestaSunat ?? '-'),
                _dato('Respuesta SUNAT', x.mensajeRespuestaSunat ?? '-'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  Widget _dato(String a, String b, {bool fuerte = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 135,
              child: Text(a, style: TextStyle(color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Text(
                b,
                style: TextStyle(
                  fontWeight: fuerte ? FontWeight.bold : FontWeight.w500,
                  color: fuerte ? azul : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 185,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: options
            .map((x) => DropdownMenuItem(value: x, child: Text(x)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _filtrados.fold<double>(0, (s, x) => s + x.total);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('COMPROBANTES ELECTRÓNICOS'),
        centerTitle: true,
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historial de comprobantes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Consulta las boletas y facturas registradas en AZUL OS.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _busqueda,
                        decoration: const InputDecoration(
                          labelText: 'Buscar número, DNI, RUC o cliente',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _dropdown('Tipo', _tipo, const [
                            'Todos',
                            'Nota de venta',
                            'Boleta',
                            'Factura',
                            'Nota de crédito',
                          ], (v) {
                            if (v == null) return;
                            setState(() => _tipo = v);
                            _filtrar();
                          }),
                          _dropdown('Estado', _estado, const [
                            'Todos',
                            'Pendiente',
                            'Generado',
                            'Enviado',
                            'Aceptado',
                            'Rechazado',
                            'Dado de baja',
                            'Anulado',
                          ], (v) {
                            if (v == null) return;
                            setState(() => _estado = v);
                            _filtrar();
                          }),
                          OutlinedButton.icon(
                            onPressed: _elegirFecha,
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: Text(
                                _fechaFiltro == null ? 'Fecha' : _fechaFiltro!._format()),
                          ),
                          OutlinedButton.icon(
                            onPressed: _limpiar,
                            icon: const Icon(Icons.filter_alt_off_rounded),
                            label: const Text('Limpiar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_cargando)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text('Error al consultar comprobantes:\n' + _error!),
                  ),
                )
              else if (_items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text('Todavía no hay comprobantes registrados.'),
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Text(
                      _filtrados.length.toString() + ' comprobante(s)',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: ' + _importe(total),
                      style: const TextStyle(
                        color: azul,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._filtrados.map(_tarjeta),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(ComprobanteElectronico x) {
    final color = _color(x.estado);
    final cliente = x.nombreCliente ??
        x.razonSocial ??
        (x.dni != null ? 'DNI ' + x.dni! : 'Sin documento');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _detalle(x),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: azul, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      x.numeroCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: azul,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tipoNombre(x.tipo) + ' · ' + _fecha(x.fechaEmision),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cliente,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _importe(x.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _estadoNombre(x.estado),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DateTime {
  String _format() =>
      day.toString().padLeft(2, '0') +
      '/' +
      month.toString().padLeft(2, '0') +
      '/' +
      year.toString();
}
