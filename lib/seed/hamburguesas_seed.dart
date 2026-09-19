import 'package:drift/drift.dart';

import '../database/app_database.dart';

class HamburguesasSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      ProductosCompanion.insert(
        codigo: 'HAM001',
        nombre: 'Hamburguesa clásica',
        categoriaId: categoriaId,
        costo: 4.20,
        precioVenta: 9.00,
        emoji: const Value('🍔'),
      ),

      ProductosCompanion.insert(
        codigo: 'HAM002',
        nombre: 'Hamburguesa con queso',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 10.00,
        emoji: const Value('🍔'),
      ),

      ProductosCompanion.insert(
        codigo: 'HAM003',
        nombre: 'Hamburguesa Royal',
        categoriaId: categoriaId,
        costo: 6.20,
        precioVenta: 12.00,
        emoji: const Value('👑'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}