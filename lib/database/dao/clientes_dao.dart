import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/clientes_table.dart';

part 'clientes_dao.g.dart';

@DriftAccessor(tables: [Clientes])
class ClientesDao extends DatabaseAccessor<AppDatabase>
    with _$ClientesDaoMixin {
  ClientesDao(AppDatabase db) : super(db);

  //=========================================================
  // GUARDAR CLIENTE
  //=========================================================

  Future<int> guardarCliente(ClientesCompanion cliente) {
    return into(clientes).insert(cliente);
  }

  //=========================================================
  // OBTENER TODOS
  //=========================================================

  Future<List<Cliente>> obtenerClientes() {
    return (select(
      clientes,
    )..orderBy([(t) => OrderingTerm.asc(t.nombre)])).get();
  }

  //=========================================================
  // BUSCAR POR NOMBRE
  //=========================================================

  Future<List<Cliente>> buscarClientes(String texto) {
    return (select(clientes)
          ..where((t) => t.nombre.like('%$texto%'))
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  //=========================================================
  // BUSCAR POR DNI
  //=========================================================

  Future<Cliente?> buscarPorDni(String dni) {
    return (select(
      clientes,
    )..where((t) => t.dni.equals(dni))).getSingleOrNull();
  }

  //=========================================================
  // BUSCAR POR TELÉFONO
  //=========================================================

  Future<Cliente?> buscarPorTelefono(String telefono) {
    return (select(
      clientes,
    )..where((t) => t.telefono.equals(telefono))).getSingleOrNull();
  }

  //=========================================================
  // ACTUALIZAR
  //=========================================================

  Future<bool> actualizarCliente(Cliente cliente) {
    return update(clientes).replace(cliente);
  }

  //=========================================================
  // ELIMINAR
  //=========================================================

  Future<int> eliminarCliente(int id) {
    return (delete(clientes)..where((t) => t.id.equals(id))).go();
  }
}
