import 'package:flutter/material.dart';

import '../../../services/venta_service.dart';

class PanelPago extends StatefulWidget {
  final double total;

  const PanelPago({
    super.key,
    required this.total,
  });

  @override
  State<PanelPago> createState() => _PanelPagoState();
}

class _PanelPagoState extends State<PanelPago> {
  String metodo = "Efectivo";

  final ventaService = VentaService.instance;

  final TextEditingController controller =
  TextEditingController();

  double get montoPagado {
    return double.tryParse(
      controller.text.replaceAll(",", "."),
    ) ??
        0;
  }

  double get vuelto {
    final v = montoPagado - widget.total;
    return v > 0 ? v : 0;
  }

  bool get pagoCompleto {
    return montoPagado >= widget.total;
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            const Text(
              "Cobro",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            RadioListTile(
              value: "Efectivo",
              groupValue: metodo,
              onChanged: (v) {
                setState(() {
                  metodo = v.toString();

                  ventaService.registrarPago(
                    efectivo: widget.total,
                    yape: 0,
                    plin: 0,
                    tarjeta: 0,
                  );
                });
              },
              title: const Text("💵 Efectivo"),
            ),

            RadioListTile(
              value: "Yape",
              groupValue: metodo,
              onChanged: (v) {
                setState(() {
                  metodo = v.toString();

                  ventaService.registrarPago(
                    efectivo: 0,
                    yape: widget.total,
                    plin: 0,
                    tarjeta: 0,
                  );
                });
              },
              title: const Text("📱 Yape"),
            ),

            RadioListTile(
              value: "Plin",
              groupValue: metodo,
              onChanged: (v) {
                setState(() {
                  metodo = v.toString();

                  ventaService.registrarPago(
                    efectivo: 0,
                    yape: 0,
                    plin: widget.total,
                    tarjeta: 0,
                  );
                });
              },
              title: const Text("💙 Plin"),
            ),

            RadioListTile(
              value: "Tarjeta",
              groupValue: metodo,
              onChanged: (v) {
                setState(() {
                  metodo = v.toString();

                  ventaService.registrarPago(
                    efectivo: 0,
                    yape: 0,
                    plin: 0,
                    tarjeta: widget.total,
                  );
                });
              },
              title: const Text("💳 Tarjeta"),
            ),

            const Divider(height: 40),

            if (metodo == "Efectivo") ...[
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Cliente paga",
                  prefixText: "S/. ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                pagoCompleto
                    ? "Vuelto: S/. ${vuelto.toStringAsFixed(2)}"
                    : "Pago insuficiente",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: pagoCompleto
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],

            if (metodo != "Efectivo") ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Aquí aparecerá el QR y la información para pagar con $metodo.",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}