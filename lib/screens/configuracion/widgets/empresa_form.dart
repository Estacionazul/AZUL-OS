import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/empresa_model.dart';
import '../../../services/empresa_service.dart';

class EmpresaForm extends StatefulWidget {
  const EmpresaForm({super.key});

  @override
  State<EmpresaForm> createState() => _EmpresaFormState();
}

class _EmpresaFormState extends State<EmpresaForm> {
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _instagramController = TextEditingController();

  EmpresaModel? _empresa;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarEmpresa();
    });
  }

  Future<void> _cargarEmpresa() async {
    print("===== INICIANDO CARGA =====");

    final empresaService = context.read<EmpresaService>();

    final empresa = await empresaService.obtenerEmpresa();

    print("===== EMPRESA OBTENIDA =====");
    print("Nombre: ${empresa.nombre}");
    print("RUC: ${empresa.ruc}");
    print("Dirección: ${empresa.direccion}");
    print("Teléfono: ${empresa.telefono}");
    print("Instagram: ${empresa.instagram}");

    _empresa = empresa;

    _nombreController.text = empresa.nombre;
    _rucController.text = empresa.ruc;
    _direccionController.text = empresa.direccion;
    _telefonoController.text = empresa.telefono;
    _instagramController.text = empresa.instagram;

    print("===== CONTROLLERS =====");
    print(_nombreController.text);
    print(_rucController.text);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _guardarEmpresa() async {
    if (_empresa == null) return;

    final empresaActualizada = EmpresaModel(
      id: _empresa!.id,
      nombre: _nombreController.text.trim(),
      ruc: _rucController.text.trim(),
      direccion: _direccionController.text.trim(),
      telefono: _telefonoController.text.trim(),
      instagram: _instagramController.text.trim(),
      logo: _empresa!.logo,
      tipoContribuyente: _empresa!.tipoContribuyente,
      serieBoleta: _empresa!.serieBoleta,
      serieFactura: _empresa!.serieFactura,
      correlativoBoleta: _empresa!.correlativoBoleta,
      correlativoFactura: _empresa!.correlativoFactura,
      igv: _empresa!.igv,
      moneda: _empresa!.moneda,
      impresora: _empresa!.impresora,
    );

    await context.read<EmpresaService>().actualizar(empresaActualizada);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Configuración guardada correctamente"),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CAFETERÍA ESTACIÓN AZUL",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25),
        _campo(
          controller: _nombreController,
          label: "Nombre Comercial",
          icon: Icons.store,
        ),
        _campo(
          controller: _rucController,
          label: "RUC",
          icon: Icons.badge,
        ),
        _campo(
          controller: _direccionController,
          label: "Dirección",
          icon: Icons.location_on,
        ),
        _campo(
          controller: _telefonoController,
          label: "Teléfono",
          icon: Icons.phone,
        ),
        _campo(
          controller: _instagramController,
          label: "Instagram",
          icon: Icons.camera_alt,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _guardarEmpresa,
            icon: const Icon(Icons.save),
            label: const Text("Guardar Cambios"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0A2E6E),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}