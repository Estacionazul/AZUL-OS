import 'package:flutter/material.dart';

class DatosCliente extends StatefulWidget {
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
  State<DatosCliente> createState() => _DatosClienteState();
}

class _DatosClienteState extends State<DatosCliente> {
  String _tipoClienteBoleta = "Sin documento";

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xffF7F9FC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: Color(0xff0A2E6E)),
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
            if (widget.tipoDocumento == "Nota de Venta") ...[
              TextField(
                controller: widget.nombreController,
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
            if (widget.tipoDocumento == "Boleta") ...[
              const Text(
                "Tipo de documento",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _tipoClienteBoleta,
                decoration: InputDecoration(
                  labelText: "Documento del cliente",
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "DNI",
                    child: Text("DNI"),
                  ),
                  DropdownMenuItem(
                    value: "RUC",
                    child: Text("RUC"),
                  ),
                  DropdownMenuItem(
                    value: "Sin documento",
                    child: Text("Sin documento"),
                  ),
                ],
                onChanged: (valor) {
                  if (valor == null) return;

                  setState(() {
                    _tipoClienteBoleta = valor;

                    if (valor == "DNI") {
                      widget.rucController.clear();
                    } else if (valor == "RUC") {
                      widget.dniController.clear();
                    } else {
                      widget.dniController.clear();
                      widget.rucController.clear();
                    }
                  });
                },
              ),

              if (_tipoClienteBoleta == "DNI") ...[
                const SizedBox(height: 15),

                TextField(
                  controller: widget.dniController,
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
              ],

              if (_tipoClienteBoleta == "RUC") ...[
                const SizedBox(height: 15),

                TextField(
                  controller: widget.rucController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "RUC",
                    hintText: "Opcional",
                    prefixIcon: const Icon(Icons.apartment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 15),

              TextField(
                controller: widget.nombreController,
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
            if (widget.tipoDocumento == "Factura") ...[
              TextField(
                controller: widget.rucController,
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
                controller: widget.razonSocialController,
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
                controller: widget.direccionController,
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
