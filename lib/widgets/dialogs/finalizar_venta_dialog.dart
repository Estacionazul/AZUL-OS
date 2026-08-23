import 'package:provider/provider.dart';

import '../../services/venta_service.dart';
import 'package:flutter/material.dart';

import 'widgets/datos_cliente.dart';
import 'widgets/metodo_pago.dart';
import 'widgets/pago_cliente.dart';
import 'widgets/resumen_pago.dart';

class FinalizarVentaDialog extends StatefulWidget {
  final double total;

  final Function(String metodoPago) onConfirmar;

  const FinalizarVentaDialog({
    super.key,
    required this.total,
    required this.onConfirmar,
  });

  @override
  State<FinalizarVentaDialog> createState() =>
      _FinalizarVentaDialogState();
}

class _FinalizarVentaDialogState
    extends State<FinalizarVentaDialog> {
  String _metodoPago = "Efectivo";
  String _tipoDocumento = "Nota de Venta";

  final TextEditingController _montoController =
  TextEditingController();

  final TextEditingController _dniController =
  TextEditingController();

  final TextEditingController _nombreController =
  TextEditingController();

  final TextEditingController _rucController =
  TextEditingController();

  final TextEditingController _razonSocialController =
  TextEditingController();

  final TextEditingController _direccionController =
  TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _dniController.dispose();
    _nombreController.dispose();
    _rucController.dispose();
    _razonSocialController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalFinal = widget.total;
    final subtotal = totalFinal / 1.18;
    final igv = totalFinal - subtotal;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.point_of_sale,
                    color: Color(0xff0A2E6E),
                    size: 34,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Finalizar Venta",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              ResumenPago(
                subtotal: subtotal,
                igv: igv,
                total: totalFinal,
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 0,
                color: const Color(0xffF7F9FC),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tipo de documento",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: "Nota de Venta",
                            icon: Icon(Icons.note_alt_outlined),
                            label: Text("Nota"),
                          ),
                          ButtonSegment(
                            value: "Boleta",
                            icon: Icon(Icons.receipt),
                            label: Text("Boleta"),
                          ),
                          ButtonSegment(
                            value: "Factura",
                            icon: Icon(Icons.business),
                            label: Text("Factura"),
                          ),
                        ],
                        selected: {_tipoDocumento},
                        onSelectionChanged: (valor) {
                          setState(() {
                            _tipoDocumento = valor.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              DatosCliente(
                tipoDocumento: _tipoDocumento,
                dniController: _dniController,
                nombreController: _nombreController,
                rucController: _rucController,
                razonSocialController: _razonSocialController,
                direccionController: _direccionController,
              ),

              const SizedBox(height: 25),

              MetodoPago(
                metodoSeleccionado: _metodoPago,
                onChanged: (metodo) {
                  setState(() {
                    _metodoPago = metodo;
                  });
                },
              ),

              const SizedBox(height: 25),

              PagoCliente(
                controller: _montoController,
                total: totalFinal,
                metodoPago: _metodoPago,
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final ventaService = context.read<VentaService>();

                        ventaService.cambiarDocumento(_tipoDocumento);

                        ventaService.actualizarDatosCliente(
                          nombreCliente: _nombreController.text.trim(),
                          dni: _dniController.text.trim(),
                          ruc: _rucController.text.trim(),
                          razonSocial: _razonSocialController.text.trim(),
                          direccionFiscal: _direccionController.text.trim(),
                        );
                        debugPrint("========== DATOS CLIENTE ANTES DE COBRAR ==========");
                        debugPrint("TIPO: $_tipoDocumento");
                        debugPrint("DNI: ${_dniController.text.trim()}");
                        debugPrint("NOMBRE: ${_nombreController.text.trim()}");
                        debugPrint("RUC: ${_rucController.text.trim()}");
                        debugPrint("RAZON SOCIAL: ${_razonSocialController.text.trim()}");
                        debugPrint("DIRECCION: ${_direccionController.text.trim()}");

                        debugPrint("========== DATOS EN VENTA SERVICE ==========");
                        debugPrint("TIPO: ${ventaService.venta.tipoDocumento}");
                        debugPrint("DNI: ${ventaService.venta.dni}");
                        debugPrint("NOMBRE: ${ventaService.venta.clienteNombre}");
                        debugPrint("RUC: ${ventaService.venta.ruc}");
                        debugPrint("RAZON SOCIAL: ${ventaService.venta.razonSocial}");
                        debugPrint("DIRECCION: ${ventaService.venta.direccionFiscal}");
                        debugPrint("Documento: $_tipoDocumento");
                        debugPrint("DNI: ${_dniController.text}");
                        debugPrint("Nombre: ${_nombreController.text}");
                        debugPrint("RUC: ${_rucController.text}");
                        debugPrint("Razón Social: ${_razonSocialController.text}");
                        debugPrint("Dirección: ${_direccionController.text}");

                        Navigator.pop(context);

                        widget.onConfirmar(_metodoPago);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Confirmar Venta"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A2E6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                      ),
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