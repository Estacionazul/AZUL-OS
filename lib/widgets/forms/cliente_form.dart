import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../services/clientes_service.dart';

class ClienteForm extends StatefulWidget {
  final ClienteModel? cliente;

  const ClienteForm({
    super.key,
    this.cliente,
  });

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();

  bool get esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();

    if (widget.cliente != null) {
      _nombreController.text = widget.cliente!.nombre;
      _dniController.text = widget.cliente!.dni ?? '';
      _telefonoController.text = widget.cliente!.telefono;
      _correoController.text = widget.cliente!.correo ?? '';
      _direccionController.text = widget.cliente!.direccion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final cliente = ClienteModel(
      id: esEdicion ? widget.cliente!.id : '0',
      nombre: _nombreController.text.trim(),
      dni: _dniController.text.trim().isEmpty
          ? null
          : _dniController.text.trim(),
      ruc: esEdicion ? widget.cliente!.ruc : null,
      telefono: _telefonoController.text.trim(),
      correo: _correoController.text.trim().isEmpty
          ? null
          : _correoController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty
          ? null
          : _direccionController.text.trim(),
      fechaRegistro:
      esEdicion ? widget.cliente!.fechaRegistro : DateTime.now(),
      ultimaVisita:
      esEdicion ? widget.cliente!.ultimaVisita : null,
      totalGastado:
      esEdicion ? widget.cliente!.totalGastado : 0,
      cantidadCompras:
      esEdicion ? widget.cliente!.cantidadCompras : 0,
      observaciones:
      esEdicion ? widget.cliente!.observaciones : null,
      esVip: esEdicion ? widget.cliente!.esVip : false,
      puntos: esEdicion ? widget.cliente!.puntos : 0,
    );

    final service = context.read<ClientesService>();

    if (esEdicion) {
      await service.actualizarCliente(cliente);
    } else {
      await service.agregarCliente(cliente);
    }

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esEdicion
              ? 'Cliente actualizado correctamente'
              : 'Cliente guardado correctamente',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre *',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingrese el nombre del cliente';
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _dniController,
            decoration: const InputDecoration(
              labelText: 'DNI',
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _correoController,
            decoration: const InputDecoration(
              labelText: 'Correo',
            ),
          ),

          const SizedBox(height: 15),

          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección',
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: guardarCliente,
              icon: const Icon(Icons.save),
              label: Text(
                esEdicion
                    ? 'Actualizar cliente'
                    : 'Guardar cliente',
              ),
            ),
          ),
        ],
      ),
    );
  }
}