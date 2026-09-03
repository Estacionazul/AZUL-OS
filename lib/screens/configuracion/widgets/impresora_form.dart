import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/empresa_model.dart';
import '../../../services/empresa_service.dart';
import '../../../printer/windows_printer_adapter.dart';

class ImpresoraForm extends StatefulWidget {
  const ImpresoraForm({super.key});

  @override
  State<ImpresoraForm> createState() => _ImpresoraFormState();
}

class _ImpresoraFormState extends State<ImpresoraForm> {
  EmpresaModel? _empresa;

  String? _impresoraSeleccionada;

  List<String> _impresoras = [];

  bool _cargando = true;
  bool _detectando = false;
  bool _guardando = false;
  bool _conectada = false;

  late final WindowsPrinterAdapter _printerAdapter;

  @override
  void initState() {
    super.initState();

    _printerAdapter = WindowsPrinterAdapter();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarConfiguracion();
    });
  }

  // ============================================================
  // CARGAR CONFIGURACIÓN
  // ============================================================

  Future<void> _cargarConfiguracion() async {
    print('===== CARGANDO CONFIGURACIÓN DE IMPRESORA =====');

    final empresaService = context.read<EmpresaService>();

    final empresa = await empresaService.obtenerEmpresa();

    if (!mounted) {
      return;
    }

    setState(() {
      _empresa = empresa;

      _impresoraSeleccionada = empresa.impresora.isNotEmpty
          ? empresa.impresora
          : null;

      _cargando = false;
    });

    print('Impresora guardada: ${empresa.impresora}');

    // Detectamos las impresoras disponibles.
    await _detectarImpresoras();
  }

  // ============================================================
  // DETECTAR IMPRESORAS
  // ============================================================

  Future<void> _detectarImpresoras() async {
    if (!Platform.isWindows) {
      print('===== DETECCIÓN WINDOWS OMITIDA =====');
      return;
    }

    if (mounted) {
      setState(() {
        _detectando = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔎 Buscando impresoras...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      print('======================================');
      print('===== DETECTANDO IMPRESORAS WINDOWS =====');
      print('======================================');

      final impresorasDetectadas = await _printerAdapter.discoverPrinters();

      print('Impresoras detectadas originalmente:');
      print(impresorasDetectadas);

      // Eliminamos duplicados.
      final impresorasUnicas = impresorasDetectadas.toSet().toList();

      print('Impresoras únicas:');
      print(impresorasUnicas);

      if (!mounted) {
        return;
      }

      setState(() {
        _impresoras = impresorasUnicas;
      });

      // --------------------------------------------------------
      // NO SE ENCONTRARON IMPRESORAS
      // --------------------------------------------------------

      if (_impresoras.isEmpty) {
        print('===== NO SE ENCONTRARON IMPRESORAS =====');

        setState(() {
          _impresoraSeleccionada = null;
          _conectada = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ No se encontraron impresoras en Windows.'),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // MOSTRAR IMPRESORAS EN CONSOLA
      // --------------------------------------------------------

      print(
        '===== SE ENCONTRARON '
        '${_impresoras.length} IMPRESORA(S) =====',
      );

      for (final impresora in _impresoras) {
        print('🖨️ $impresora');
      }

      // --------------------------------------------------------
      // CONSERVAR IMPRESORA GUARDADA
      // --------------------------------------------------------

      if (_impresoraSeleccionada != null &&
          _impresoras.contains(_impresoraSeleccionada)) {
        print(
          '✅ Impresora guardada encontrada: '
          '$_impresoraSeleccionada',
        );
      }
      // --------------------------------------------------------
      // BUSCAR HL200B_000
      // --------------------------------------------------------
      else if (_impresoras.contains('HL200B_000')) {
        setState(() {
          _impresoraSeleccionada = 'HL200B_000';
        });

        print('✅ HL200B_000 detectada automáticamente.');
      }
      // --------------------------------------------------------
      // SI NO ESTÁ HL200B_000
      // --------------------------------------------------------
      else {
        setState(() {
          _impresoraSeleccionada = _impresoras.first;
        });

        print('ℹ️ HL200B_000 no fue encontrada.');

        print('Se seleccionó: ${_impresoras.first}');
      }

      // --------------------------------------------------------
      // COMPROBAR CONEXIÓN
      // --------------------------------------------------------

      if (_impresoraSeleccionada != null) {
        await _seleccionarImpresoraInternamente(_impresoraSeleccionada!);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Se encontraron '
            '${_impresoras.length} impresora(s).',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('===== ERROR DETECTANDO IMPRESORAS =====');
      print(e);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error detectando impresoras: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _detectando = false;
        });
      }
    }
  }

  // ============================================================
  // SELECCIONAR IMPRESORA
  // ============================================================

  Future<void> _seleccionarImpresoraInternamente(String nombre) async {
    try {
      await _printerAdapter.selectPrinter(nombre);

      final conectada = await _printerAdapter.isConnected();

      if (!mounted) {
        return;
      }

      setState(() {
        _impresoraSeleccionada = nombre;
        _conectada = conectada;
      });

      print('===== IMPRESORA SELECCIONADA =====');
      print('Nombre: $nombre');
      print('Conectada: $conectada');
    } catch (e) {
      print('===== ERROR SELECCIONANDO IMPRESORA =====');
      print(e);

      if (!mounted) {
        return;
      }

      setState(() {
        _conectada = false;
      });
    }
  }

  // ============================================================
  // GUARDAR IMPRESORA
  // ============================================================

  Future<void> _guardarImpresora() async {
    if (_empresa == null ||
        _impresoraSeleccionada == null ||
        _impresoraSeleccionada!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una impresora antes de guardar.'),
        ),
      );

      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final empresaService = context.read<EmpresaService>();

      final empresaActualizada = EmpresaModel(
        id: _empresa!.id,
        nombre: _empresa!.nombre,
        ruc: _empresa!.ruc,
        direccion: _empresa!.direccion,
        telefono: _empresa!.telefono,
        instagram: _empresa!.instagram,
        logo: _empresa!.logo,
        serieBoleta: _empresa!.serieBoleta,
        serieFactura: _empresa!.serieFactura,
        correlativoBoleta: _empresa!.correlativoBoleta,
        correlativoFactura: _empresa!.correlativoFactura,
        igv: _empresa!.igv,
        moneda: _empresa!.moneda,
        tipoContribuyente: _empresa!.tipoContribuyente,
        impresora: _impresoraSeleccionada!,
      );

      await empresaService.actualizar(empresaActualizada);

      if (!mounted) {
        return;
      }

      setState(() {
        _empresa = empresaActualizada;
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impresora guardada correctamente')),
      );

      print('===== IMPRESORA GUARDADA =====');
      print(_impresoraSeleccionada);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la impresora: $e')),
      );

      print('===== ERROR GUARDANDO IMPRESORA =====');
      print(e);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _printerAdapter.disconnect();
    super.dispose();
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // TÍTULO
            // --------------------------------------------------
            const Row(
              children: [
                Icon(Icons.print, color: Color(0xff0A2E6E)),
                SizedBox(width: 10),
                Text(
                  'Impresora',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Impresora predeterminada',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // --------------------------------------------------
            // LISTA DE IMPRESORAS
            // --------------------------------------------------
            if (_cargando)
              const LinearProgressIndicator()
            else if (_impresoras.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 10),
                    Expanded(child: Text('No se encontraron impresoras.')),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _impresoraSeleccionada,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.print),
                  labelText: 'Impresora',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _impresoras
                    .map(
                      (impresora) => DropdownMenuItem<String>(
                        value: impresora,
                        child: Text(impresora),
                      ),
                    )
                    .toList(),
                onChanged: _detectando
                    ? null
                    : (valor) async {
                        if (valor == null) {
                          return;
                        }

                        await _seleccionarImpresoraInternamente(valor);
                      },
              ),

            const SizedBox(height: 15),

            // --------------------------------------------------
            // ESTADO
            // --------------------------------------------------
            Row(
              children: [
                Icon(
                  _conectada ? Icons.check_circle : Icons.info_outline,
                  size: 20,
                  color: _conectada ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _conectada
                      ? 'Impresora disponible'
                      : 'Impresora no conectada',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _conectada ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // DETECTAR
            // --------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _detectando ? null : _detectarImpresoras,
                icon: _detectando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _detectando ? 'Detectando...' : 'Detectar impresoras',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // GUARDAR
            // --------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarImpresora,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_guardando ? 'Guardando...' : 'Guardar Impresora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0A2E6E),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
