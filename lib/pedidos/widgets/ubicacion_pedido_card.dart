import 'package:flutter/material.dart';

import '../models/estado_pedido.dart';
import '../models/pedido_abierto.dart';
import '../models/ubicacion_pedido.dart';

class UbicacionPedidoCard extends StatelessWidget {
  final UbicacionPedido ubicacion;
  final PedidoAbierto? pedido;
  final VoidCallback onTap;

  const UbicacionPedidoCard({
    super.key,
    required this.ubicacion,
    required this.pedido,
    required this.onTap,
  });

  bool get ocupada => pedido != null;

  bool get esperandoCuenta => pedido?.estado == EstadoPedido.esperandoCuenta;

  IconData get icono {
    if (ubicacion.esMesa) {
      return Icons.table_restaurant_rounded;
    }

    return Icons.local_bar_rounded;
  }

  Color get colorEstado {
    if (esperandoCuenta) {
      return Colors.orange;
    }

    if (ocupada) {
      return const Color(0xFF1565C0);
    }

    return Colors.green;
  }

  String get textoEstado {
    if (esperandoCuenta) {
      return 'ESPERANDO CUENTA';
    }

    if (ocupada) {
      return 'OCUPADA';
    }

    return 'LIBRE';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ocupada
                  ? colorEstado.withValues(alpha: 0.45)
                  : Colors.grey.shade200,
              width: ocupada ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icono, color: colorEstado, size: 27),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        textoEstado,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  ubicacion.nombre,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                if (ocupada) ...[
                  Text(
                    '${pedido!.cantidadItems} producto(s)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'S/. ${pedido!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ] else
                  Text(
                    'Lista para recibir pedido',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                const Spacer(),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      ocupada
                          ? Icons.receipt_long_rounded
                          : Icons.add_circle_outline_rounded,
                    ),
                    label: Text(ocupada ? 'Ver pedido' : 'Abrir pedido'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
