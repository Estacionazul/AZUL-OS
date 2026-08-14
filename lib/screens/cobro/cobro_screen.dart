import 'package:flutter/material.dart';

import 'widgets/panel_pago.dart';
import 'widgets/panel_cliente.dart';

class CobroScreen extends StatelessWidget {
  final double total;

  const CobroScreen({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final totalFinal = total;
    final subtotal = totalFinal / 1.18;
    final igv = totalFinal - subtotal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0A2E6E),
        foregroundColor: Colors.white,
        title: const Text("Cobrar Venta"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PANEL IZQUIERDO
            Expanded(
              flex: 2,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Resumen",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      fila("Subtotal", subtotal),

                      const SizedBox(height: 15),

                      fila("IGV (18%)", igv),

                      const Divider(height: 40),

                      fila(
                        "TOTAL",
                        totalFinal,
                        grande: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              flex: 3,
              child: Column(
                children: [

                  Expanded(
                    flex: 2,
                    child: PanelPago(
                      total: totalFinal,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Expanded(
                    child: PanelCliente(),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fila(
      String titulo,
      double monto, {
        bool grande = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(
          titulo,
          style: TextStyle(
            fontSize: grande ? 24 : 18,
            fontWeight:
            grande ? FontWeight.bold : FontWeight.w500,
          ),
        ),

        Text(
          "S/. ${monto.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: grande ? 28 : 20,
            fontWeight: FontWeight.bold,
            color: grande ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}