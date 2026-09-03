import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../repositories/clientes_repository.dart';

class ClientesService extends ChangeNotifier {
  final ClientesRepository repository;

  ClientesService(this.repository);

  Future<void> agregarCliente(ClienteModel cliente) async {
    await repository.guardarCliente(cliente);
    notifyListeners();
  }

  Future<void> actualizarCliente(ClienteModel cliente) async {
    await repository.actualizarCliente(cliente);
    notifyListeners();
  }

  Future<void> eliminarCliente(String id) async {
    await repository.eliminarCliente(id);
    notifyListeners();
  }

  Future<List<ClienteModel>> obtenerClientes() async {
    return await repository.obtenerClientes();
  }

  Future<List<ClienteModel>> buscarPorNombre(String texto) async {
    return await repository.buscarClientes(texto);
  }

  Future<ClienteModel?> buscarPorTelefono(String telefono) async {
    return await repository.buscarPorTelefono(telefono);
  }
}
