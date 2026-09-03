import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cobro_service.dart';
import '../dialogs/finalizar_venta_dialog.dart';
import '../../services/carrito_service.dart';

class PosCheckoutButton extends StatelessWidget {
  const PosCheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.point_of_sale),
        label: const Text("COBRAR"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => FinalizarVentaDialog(
              total: context.read<CarritoService>().total,
              onConfirmar: (metodoPago) async {
                final cobro = context.read<CobroService>();

                try {
                  await cobro.cobrar(metodoPago: metodoPago);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Venta realizada correctamente."),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  final mensaje = e.toString().replaceFirst('Bad state: ', '');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(mensaje),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
