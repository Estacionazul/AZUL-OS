import 'package:flutter/material.dart';

class ResumenPago extends StatelessWidget {
  final double subtotal;
  final double igv;
  final double total;

  const ResumenPago({
    super.key,
    required this.subtotal,
    required this.igv,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xffF7F9FC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Color(0xff0A2E6E),
                ),
                SizedBox(width: 8),
                Text(
                  "Resumen de Pago",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0A2E6E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Tipo de documento",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [

                Chip(
                  avatar: Icon(Icons.note_alt_outlined),
                  label: Text("Nota de Venta"),
                ),

                Chip(
                  avatar: Icon(Icons.receipt),
                  label: Text("Boleta"),
                ),

                Chip(
                  avatar: Icon(Icons.business),
                  label: Text("Factura"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _fila("Subtotal", subtotal),

            const SizedBox(height: 12),

            _fila("IGV (18%)", igv),

            const Divider(height: 30),

            _fila(
              "TOTAL",
              total,
              grande: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(
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
            fontSize: grande ? 20 : 16,
            fontWeight:
            grande ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          "S/. ${monto.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: grande ? 26 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}