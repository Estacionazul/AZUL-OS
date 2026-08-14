import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/cliente.dart';

class ClienteMapper {
  /// SQLite -> Modelo
  static ClienteModel fromDatabase(Cliente cliente) {
    return ClienteModel(
      id: cliente.id.toString(),
      nombre: cliente.nombre,
      dni: cliente.dni,
      ruc: cliente.ruc,
      telefono: cliente.telefono ?? '',
      correo: cliente.correo,
      direccion: cliente.direccion,
      fechaRegistro: cliente.fechaRegistro,
      ultimaVisita: cliente.ultimaVisita,
      totalGastado: cliente.totalGastado,
      cantidadCompras: cliente.cantidadCompras,
      observaciones: cliente.observaciones,

      // Estos por ahora siguen siendo lógica de negocio
      esVip: false,
      puntos: 0,
    );
  }

  /// Modelo -> Companion (INSERT)
  static ClientesCompanion toCompanion(ClienteModel cliente) {
    return ClientesCompanion(
      nombre: Value(cliente.nombre),
      dni: Value(cliente.dni),
      ruc: Value(cliente.ruc),
      telefono: Value(cliente.telefono),
      correo: Value(cliente.correo),
      direccion: Value(cliente.direccion),
      observaciones: Value(cliente.observaciones),
    );
  }

  /// Modelo -> SQLite (UPDATE)
  static Cliente toDatabase(ClienteModel cliente) {
    return Cliente(
      id: int.parse(cliente.id),
      nombre: cliente.nombre,
      dni: cliente.dni,
      ruc: cliente.ruc,
      telefono: cliente.telefono,
      correo: cliente.correo,
      direccion: cliente.direccion,
      fechaRegistro:
      cliente.fechaRegistro ?? DateTime.now(),
      ultimaVisita: cliente.ultimaVisita,
      totalGastado: cliente.totalGastado,
      cantidadCompras: cliente.cantidadCompras,
      observaciones: cliente.observaciones,
    );
  }
}