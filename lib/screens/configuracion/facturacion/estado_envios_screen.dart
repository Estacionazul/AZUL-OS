import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../facturacion/models/comprobante_electronico.dart';
import '../../../facturacion/repositories/comprobantes_electronicos_repository.dart';

class EstadoEnviosScreen extends StatefulWidget {
  const EstadoEnviosScreen({super.key});
  @override
  State<EstadoEnviosScreen> createState() => _EstadoEnviosScreenState();
}

class _EstadoEnviosScreenState extends State<EstadoEnviosScreen> {
  static const azul = Color(0xff0A2E6E);
  static const fondo = Color(0xffF5F7FA);
  List<ComprobanteElectronico> _items = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final repo = context.read<ComprobantesElectronicosRepository>();
      final rows = await repo.obtenerTodos();
      if (!mounted) return;
      _items = rows.map(_mapear).where((x) => x.requiereSunat).toList();
      _items.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));
      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  ComprobanteElectronico _mapear(dynamic x) => ComprobanteElectronico(
    id: x.id, ventaId: x.ventaId, tipo: _tipoDesde(x.tipo?.toString()),
    serie: x.serie?.toString() ?? '',
    numero: x.numero is int ? x.numero as int : int.tryParse(x.numero?.toString() ?? '') ?? 0,
    fechaEmision: x.fechaEmision is DateTime ? x.fechaEmision as DateTime : DateTime.now(),
    dni: x.dni?.toString(), ruc: x.ruc?.toString(),
    nombreCliente: x.nombreCliente?.toString(), razonSocial: x.razonSocial?.toString(),
    direccionFiscal: x.direccionFiscal?.toString(),
    subtotal: _num(x.subtotal), igv: _num(x.igv), total: _num(x.total),
    metodoPago: x.metodoPago?.toString() ?? '-', estado: _estadoDesde(x.estado?.toString()),
    codigoRespuestaSunat: x.codigoRespuestaSunat?.toString(),
    mensajeRespuestaSunat: x.mensajeRespuestaSunat?.toString(),
    fechaEnvioSunat: x.fechaEnvioSunat is DateTime ? x.fechaEnvioSunat as DateTime : null,
    fechaRespuestaSunat: x.fechaRespuestaSunat is DateTime ? x.fechaRespuestaSunat as DateTime : null,
  );

  double _num(dynamic x) => x is num ? x.toDouble() : double.tryParse(x?.toString() ?? '') ?? 0;

  TipoComprobanteElectronico _tipoDesde(String? x) {
    switch ((x ?? '').trim().toLowerCase()) {
      case 'boleta': return TipoComprobanteElectronico.boleta;
      case 'factura': return TipoComprobanteElectronico.factura;
      case 'notacredito':
      case 'nota_credito': return TipoComprobanteElectronico.notaCredito;
      default: return TipoComprobanteElectronico.notaVenta;
    }
  }

  EstadoComprobanteElectronico _estadoDesde(String? x) {
    switch ((x ?? '').trim().toLowerCase()) {
      case 'generado': return EstadoComprobanteElectronico.generado;
      case 'enviado': return EstadoComprobanteElectronico.enviado;
      case 'aceptado': return EstadoComprobanteElectronico.aceptado;
      case 'rechazado': return EstadoComprobanteElectronico.rechazado;
      case 'dadodebaja':
      case 'dado_de_baja': return EstadoComprobanteElectronico.dadoDeBaja;
      case 'anulado': return EstadoComprobanteElectronico.anulado;
      default: return EstadoComprobanteElectronico.pendiente;
    }
  }

  String _estadoNombre(EstadoComprobanteElectronico x) {
    switch (x) {
      case EstadoComprobanteElectronico.pendiente: return 'Pendiente';
      case EstadoComprobanteElectronico.generado: return 'Generado';
      case EstadoComprobanteElectronico.enviado: return 'Enviado';
      case EstadoComprobanteElectronico.aceptado: return 'Aceptado';
      case EstadoComprobanteElectronico.rechazado: return 'Rechazado';
      case EstadoComprobanteElectronico.dadoDeBaja: return 'Dado de baja';
      case EstadoComprobanteElectronico.anulado: return 'Anulado';
    }
  }

  Color _color(EstadoComprobanteElectronico x) {
    switch (x) {
      case EstadoComprobanteElectronico.aceptado: return Colors.green;
      case EstadoComprobanteElectronico.rechazado:
      case EstadoComprobanteElectronico.anulado: return Colors.red;
      case EstadoComprobanteElectronico.enviado: return Colors.orange;
      case EstadoComprobanteElectronico.generado: return Colors.blue;
      case EstadoComprobanteElectronico.dadoDeBaja: return Colors.deepOrange;
      case EstadoComprobanteElectronico.pendiente: return Colors.grey;
    }
  }

  String _fecha(DateTime x) => '${x.day.toString().padLeft(2, '0')}/${x.month.toString().padLeft(2, '0')}/${x.year}';
  String _importe(double x) => 'S/ ${x.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final visibles = _filtro == 'Todos' ? _items : _items.where((x) => _estadoNombre(x.estado) == _filtro).toList();
    final pendientes = _items.where((x) => x.estado == EstadoComprobanteElectronico.pendiente || x.estado == EstadoComprobanteElectronico.generado).length;
    final enviados = _items.where((x) => x.estado == EstadoComprobanteElectronico.enviado).length;
    final aceptados = _items.where((x) => x.estado == EstadoComprobanteElectronico.aceptado).length;
    final rechazados = _items.where((x) => x.estado == EstadoComprobanteElectronico.rechazado).length;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(title: const Text('ESTADO DE ENVÍOS'), centerTitle: true, backgroundColor: azul, foregroundColor: Colors.white),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Control de comunicaciones SUNAT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: azul)),
            const SizedBox(height: 6),
            Text('Consulta el estado de los comprobantes que requieren comunicación con SUNAT.', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 18),
            if (!_cargando && _error == null) Wrap(spacing: 10, runSpacing: 10, children: [
              _resumen('Pendientes', pendientes, Colors.grey),
              _resumen('Enviados', enviados, Colors.orange),
              _resumen('Aceptados', aceptados, Colors.green),
              _resumen('Rechazados', rechazados, Colors.red),
            ]),
            const SizedBox(height: 18),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
              initialValue: _filtro,
              decoration: const InputDecoration(labelText: 'Filtrar por estado', border: OutlineInputBorder()),
              items: const ['Todos','Pendiente','Generado','Enviado','Aceptado','Rechazado','Dado de baja','Anulado'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (x) { if (x != null) setState(() => _filtro = x); },
            ))),
            const SizedBox(height: 18),
            if (_cargando) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(18), child: Text('No se pudieron cargar los envíos.\n\n$_error')))
            else if (_items.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(28), child: Center(child: Text('No hay comprobantes electrónicos registrados que requieran SUNAT.'))))
            else ...[
              Text(visibles.length.toString() + ' comprobante(s)', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...visibles.map(_tarjeta),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _resumen(String titulo, int cantidad, Color color) => Container(
    width: 150, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(cantidad.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 3), Text(titulo, style: TextStyle(color: Colors.grey.shade700)),
    ]),
  );

  Widget _tarjeta(ComprobanteElectronico x) {
    final color = _color(x.estado);
    final cliente = x.nombreCliente ?? x.razonSocial ?? (x.dni != null ? 'DNI ' + x.dni! : 'Sin documento');
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Icon(x.estado == EstadoComprobanteElectronico.aceptado ? Icons.check_circle_rounded : x.estado == EstadoComprobanteElectronico.rechazado ? Icons.cancel_rounded : Icons.sync_rounded, color: color, size: 30),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(x.numeroCompleto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: azul)),
        const SizedBox(height: 4),
        Text(_fecha(x.fechaEmision), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(cliente, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (x.mensajeRespuestaSunat != null) Text(x.mensajeRespuestaSunat!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ])),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_importe(x.total), style: const TextStyle(fontWeight: FontWeight.bold, color: azul)),
        const SizedBox(height: 6),
        Text(_estadoNombre(x.estado), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    ])));
  }
}