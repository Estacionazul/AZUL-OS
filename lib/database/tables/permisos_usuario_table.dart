import 'package:drift/drift.dart';

import 'usuarios_table.dart';

class PermisosUsuario extends Table {
  // ==========================================================
  // ID
  // ==========================================================

  IntColumn get id => integer().autoIncrement()();

  // ==========================================================
  // USUARIO
  // ==========================================================

  IntColumn get usuarioId =>
      integer().references(Usuarios, #id)();

  // ==========================================================
  // MODULO
  // ==========================================================

  TextColumn get modulo => text()();

  // ==========================================================
  // PERMISO
  // ==========================================================

  BoolColumn get permitido =>
      boolean().withDefault(
        const Constant(false),
      )();
}
