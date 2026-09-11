import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../facturacion/repositories/comprobantes_electronicos_repository.dart';
import '../../../facturacion/repositories/resumenes_diarios_repository.dart';

class ResumenesDiariosScreen extends StatefulWidget {
  const ResumenesDiariosScreen({super.key});

  @override
  State<ResumenesDiariosScreen> createState() =>
      _ResumenesDiariosScreenState();
}

class _ResumenesDiariosScreenState extends State<ResumenesDiariosScreen> {
  static const Color azul = Color(0xff0A2E6E);
  static const Color fondo = Color(0xffF5F7FA);

  DateTime _fechaSeleccionada = DateTime.now();
  bool _cargando = false;
  String? _error;
  List<dynamic> _resumenes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarResumenes();
    });
  }

  Future<void> _cargarResumenes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final repository =
          context.read<ResumenesDiariosRepository>();

      final resultados =
          await repository.obtenerPorFecha(_fechaSeleccionada);

      if (!mounted) return;

      setState(() {
        _resumenes = resultados;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Selecciona la fecha del resumen',
    );

    if (fecha == null) return;

    setState(() {
      _fechaSeleccionada = fecha;
    });

    await _cargarResumenes();
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _formatearImporte(dynamic valor) {
    final numero = valor is num
        ? valor.toDouble()
        : double.tryParse(valor?.toString() ?? '') ?? 0;

    return 'S/ ${numero.toStringAsFixed(2)}';
  }

  Color _colorEstado(String estado) {
    switch (estado.trim().toLowerCase()) {
      case 'aceptado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'enviado':
        return Colors.orange;
      case 'generado':
        return Colors.blue;
      case 'pendiente':
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.trim().toLowerCase()) {
      case 'aceptado':
        return Icons.check_circle_rounded;
      case 'rechazado':
        return Icons.cancel_rounded;
      case 'enviado':
        return Icons.cloud_upload_rounded;
      case 'generado':
        return Icons.description_rounded;
      case 'pendiente':
      default:
        return Icons.schedule_rounded;
    }
  }

  Future<List<dynamic>> _obtenerComprobantes(dynamic resumen) async {
    final resumenRepository =
        context.read<ResumenesDiariosRepository>();

    final comprobantesRepository =
        context.read<ComprobantesElectronicosRepository>();

    final detalles = await resumenRepository
        .obtenerDetallesPorResumenDiario(resumen.id);

    final comprobantes = <dynamic>[];

    for (final detalle in detalles) {
      final comprobante = await comprobantesRepository
          .obtenerPorId(detalle.comprobanteElectronicoId);

      if (comprobante != null) {
        comprobantes.add(comprobante);
      }
    }

    return comprobantes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('RESÚMENES DIARIOS SUNAT'),
        centerTitle: true,
        backgroundColor: azul,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarResumenes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(),
              const SizedBox(height: 20),
              _selectorFecha(),
              const SizedBox(height: 20),
              _contenido(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Control de resúmenes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: azul,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Consulta el estado real de los resúmenes diarios enviados a SUNAT.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _selectorFecha() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _seleccionarFecha,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffE8F0F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: azul,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de referencia',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatearFecha(_fechaSeleccionada),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: azul,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_calendar_rounded,
                color: azul,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No se pudieron consultar los resúmenes.\n\n$_error',
                  style: const TextStyle(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_resumenes.isEmpty) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 52,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No hay resúmenes para esta fecha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecciona otra fecha para consultar el historial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_resumenes.length} resumen${_resumenes.length == 1 ? '' : 'es'} encontrado${_resumenes.length == 1 ? '' : 's'}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._resumenes.map(_tarjetaResumen),
      ],
    );
  }

  Widget _tarjetaResumen(dynamic resumen) {
    final estado = resumen.estado.toString();
    final colorEstado = _colorEstado(estado);

    final fecha = resumen.fechaReferencia as DateTime;
    final fechaId = _formatearFecha(fecha).replaceAll('/', '');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xffE8F0F8),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: azul,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'RC-$fechaId-${resumen.correlativo}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
            ),
            _estadoChip(
              estado,
              colorEstado,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            resumen.nombreArchivo?.toString() ?? '-',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        children: [
          const Divider(),
          _dato(
            Icons.confirmation_number_outlined,
            'ID interno',
            resumen.id.toString(),
          ),
          _dato(
            Icons.cloud_outlined,
            'Ticket SUNAT',
            resumen.ticketSunat?.toString() ?? 'No enviado',
          ),
          _dato(
            Icons.verified_outlined,
            'Código SUNAT',
            resumen.codigoRespuestaSunat?.toString() ?? '-',
          ),
          if (resumen.mensajeRespuestaSunat != null &&
              resumen.mensajeRespuestaSunat
                  .toString()
                  .trim()
                  .isNotEmpty)
            _dato(
              Icons.message_outlined,
              'Respuesta SUNAT',
              resumen.mensajeRespuestaSunat.toString(),
            ),
          const SizedBox(height: 8),
          _comprobantesIncluidos(resumen),
        ],
      ),
    );
  }

  Widget _comprobantesIncluidos(dynamic resumen) {
    return FutureBuilder<List<dynamic>>(
      future: _obtenerComprobantes(resumen),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            elevation: 0,
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No se pudieron cargar los comprobantes: '
                      '${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final comprobantes = snapshot.data ?? [];

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xffE2E8F0),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 20,
                    color: azul,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Comprobantes incluidos (${comprobantes.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: azul,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (comprobantes.isEmpty)
                Text(
                  'Este resumen no tiene comprobantes registrados.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                )
              else
                ...List.generate(
                  comprobantes.length,
                  (index) => _comprobanteItem(
                    comprobantes[index],
                    index + 1,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _comprobanteItem(
    dynamic comprobante,
    int posicion,
  ) {
    final documento =
        '${comprobante.serie}-${comprobante.numero.toString().padLeft(8, '0')}';

    final identificacion = comprobante.dni?.toString().trim().isNotEmpty == true
        ? 'DNI ${comprobante.dni}'
        : comprobante.ruc?.toString().trim().isNotEmpty == true
            ? 'RUC ${comprobante.ruc}'
            : 'Sin documento';

    return Container(
      margin: EdgeInsets.only(
        bottom: posicion == 1 ? 8 : 0,
        top: posicion == 1 ? 0 : 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffE8F0F8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              posicion.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: azul,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  identificacion,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatearImporte(comprobante.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: azul,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoChip(String estado, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconoEstado(estado),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            estado.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}