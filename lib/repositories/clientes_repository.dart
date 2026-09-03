import '../database/app_database.dart';
import '../mappers/cliente_mapper.dart';
import '../models/cliente.dart';

class ClientesRepository {
  final AppDatabase database;

  ClientesRepository(this.database);

  Future<void> guardarCliente(ClienteModel cliente) async {
    final companion = ClienteMapper.toCompanion(cliente);

    await database.clientesDao.guardarCliente(companion);
  }

  Future<List<ClienteModel>> obtenerClientes() async {
    final clientes = await database.clientesDao.obtenerClientes();

    return clientes.map(ClienteMapper.fromDatabase).toList();
  }

  Future<List<ClienteModel>> buscarClientes(String texto) async {
    final clientes = await database.clientesDao.buscarClientes(texto);

    return clientes.map(ClienteMapper.fromDatabase).toList();
  }

  Future<ClienteModel?> buscarPorDni(String dni) async {
    final cliente = await database.clientesDao.buscarPorDni(dni);

    if (cliente == null) return null;

    return ClienteMapper.fromDatabase(cliente);
  }

  Future<ClienteModel?> buscarPorTelefono(String telefono) async {
    final cliente = await database.clientesDao.buscarPorTelefono(telefono);

    if (cliente == null) return null;

    return ClienteMapper.fromDatabase(cliente);
  }

  Future<void> actualizarCliente(ClienteModel cliente) async {
    final clienteDb = ClienteMapper.toDatabase(cliente);

    await database.clientesDao.actualizarCliente(clienteDb);
  }

  Future<void> eliminarCliente(String id) async {
    await database.clientesDao.eliminarCliente(int.parse(id));
  }
}
