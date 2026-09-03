import 'package:flutter/material.dart';

class PagoCliente extends StatefulWidget {
  final TextEditingController controller;
  final double total;
  final String metodoPago;

  const PagoCliente({
    super.key,
    required this.controller,
    required this.total,
    required this.metodoPago,
  });

  @override
  State<PagoCliente> createState() => _PagoClienteState();
}

class _PagoClienteState extends State<PagoCliente> {
  double get montoIngresado {
    return double.tryParse(widget.controller.text.replaceAll(",", ".")) ?? 0;
  }

  double get vuelto {
    final valor = montoIngresado - widget.total;
    return valor > 0 ? valor : 0;
  }

  bool get pagoCompleto {
    return montoIngresado >= widget.total;
  }

  void agregarMonto(double monto) {
    widget.controller.text = monto.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      setState(() {});
    });
  }

  Widget botonRapido(double monto) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            agregarMonto(monto);
          },
          child: Text("S/ ${monto.toInt()}"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.metodoPago != "Efectivo") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Icon(Icons.qr_code_2, size: 90, color: Color(0xff0A2E6E)),
            const SizedBox(height: 15),
            Text(
              "Pago mediante ${widget.metodoPago}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Aquí mostraremos el QR oficial de Estación Azul.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cliente paga",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: widget.controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: "S/. ",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            botonRapido(20),
            botonRapido(50),
            botonRapido(100),
            botonRapido(200),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              agregarMonto(widget.total);
            },
            icon: const Icon(Icons.check),
            label: const Text("Monto exacto"),
          ),
        ),

        const SizedBox(height: 25),

        Center(
          child: Column(
            children: [
              Text(
                pagoCompleto ? "VUELTO" : "FALTA",
                style: TextStyle(
                  fontSize: 18,
                  color: pagoCompleto ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "S/. ${(pagoCompleto ? vuelto : widget.total - montoIngresado).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: pagoCompleto ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
