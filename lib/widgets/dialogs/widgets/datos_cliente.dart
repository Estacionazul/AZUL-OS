import 'package:flutter/material.dart';

class DatosCliente extends StatelessWidget {
  final String tipoDocumento;

  final TextEditingController dniController;
  final TextEditingController nombreController;
  final TextEditingController rucController;
  final TextEditingController razonSocialController;
  final TextEditingController direccionController;

  const DatosCliente({
    super.key,
    required this.tipoDocumento,
    required this.dniController,
    required this.nombreController,
    required this.rucController,
    required this.razonSocialController,
    required this.direccionController,
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
                  Icons.person_outline,
                  color: Color(0xff0A2E6E),
                ),
                SizedBox(width: 8),
                Text(
                  "Datos del Cliente",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0A2E6E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================================
            // NOTA DE VENTA
            // ==========================================
            if (tipoDocumento == "Nota de Venta") ...[
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre del Cliente",
                  hintText: "Opcional",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            // ==========================================
            // BOLETA
            // ==========================================
            if (tipoDocumento == "Boleta") ...[
              TextField(
                controller: dniController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "DNI",
                  hintText: "Opcional",
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre del Cliente",
                  hintText: "Opcional",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            // ==========================================
            // FACTURA
            // ==========================================
            if (tipoDocumento == "Factura") ...[
              TextField(
                controller: rucController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "RUC",
                  hintText: "Ingrese el RUC",
                  prefixIcon: const Icon(Icons.apartment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: razonSocialController,
                decoration: InputDecoration(
                  labelText: "Razón Social",
                  hintText: "Ingrese la razón social",
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: direccionController,
                decoration: InputDecoration(
                  labelText: "Dirección Fiscal",
                  hintText: "Ingrese la dirección",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}