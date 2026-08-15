import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dao/productos_dao.dart';
import 'dao/insumos_dao.dart';
import 'dao/recetas_dao.dart';
import 'dao/receta_detalle_dao.dart';

import 'tables/productos_table.dart';
import 'tables/categorias_table.dart';
import 'tables/insumos_table.dart';
import 'tables/recetas_table.dart';
import 'tables/receta_detalle_table.dart';

import 'tables/ventas_table.dart';
import 'tables/detalle_ventas_table.dart';
import 'tables/clientes_table.dart';
import 'tables/movimientos_inventario_table.dart';
import 'tables/empresa_table.dart';
import 'tables/cajas_table.dart';
import 'tables/movimientos_caja_table.dart';

import 'dao/ventas_dao.dart';
import 'dao/clientes_dao.dart';
import 'dao/movimientos_inventario_dao.dart';
import 'dao/empresa_dao.dart';
import 'dao/cajas_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Productos,
    Categorias,
    Insumos,
    Recetas,
    RecetaDetalle,
    Ventas,
    DetalleVentas,
    Clientes,
    MovimientosInventario,
    Empresa,
    Cajas,
    MovimientosCaja,
  ],
  daos: [
    ProductosDao,
    InsumosDao,
    RecetasDao,
    RecetaDetalleDao,
    VentasDao,
    ClientesDao,
    MovimientosInventarioDao,
    EmpresaDao,
    CajasDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 11) {
        await m.createTable(cajas);
        await m.createTable(movimientosCaja);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(directory.path, 'azul_os.db'),
    );

    // SOLO PARA DESARROLLO
    // if (await file.exists()) {
    //   await file.delete();
    // }

    return NativeDatabase(file);
  });
}