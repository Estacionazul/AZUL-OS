import 'package:flutter/material.dart';

class MetodoPago extends StatelessWidget {
  final String metodoSeleccionado;
  final ValueChanged<String> onChanged;

  const MetodoPago({
    super.key,
    required this.metodoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Método de pago",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _tarjeta(
              icono: Icons.payments,
              emoji: "💵",
              titulo: "Efectivo",
            ),

            _tarjeta(
              icono: Icons.qr_code,
              emoji: "📱",
              titulo: "Yape",
            ),

            _tarjeta(
              icono: Icons.qr_code_2,
              emoji: "💙",
              titulo: "Plin",
            ),

            _tarjeta(
              icono: Icons.credit_card,
              emoji: "💳",
              titulo: "Tarjeta",
            ),

            _tarjeta(
              icono: Icons.account_balance,
              emoji: "🏦",
              titulo: "Transferencia",
            ),
          ],
        ),
      ],
    );
  }

  Widget _tarjeta({
    required IconData icono,
    required String emoji,
    required String titulo,
  }) {
    final seleccionado = metodoSeleccionado == titulo;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onChanged(titulo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 145,
        height: 115,
        decoration: BoxDecoration(
          color: seleccionado
              ? const Color(0xff0A2E6E)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado
                ? const Color(0xff0A2E6E)
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 8),

            Icon(
              icono,
              size: 30,
              color: seleccionado
                  ? Colors.white
                  : const Color(0xff0A2E6E),
            ),

            const SizedBox(height: 8),

            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: seleccionado
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}