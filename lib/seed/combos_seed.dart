import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CombosSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      ProductosCompanion.insert(
        codigo: 'COM001',
        nombre: 'Desayuno Azul',
        categoriaId: categoriaId,
        costo: 10.00,
        precioVenta: 15.00,
        emoji: const Value('🌅'),
      ),

      ProductosCompanion.insert(
        codigo: 'COM002',
        nombre: 'Combo Fresco',
        categoriaId: categoriaId,
        costo: 8.50,
        precioVenta: 13.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'COM003',
        nombre: 'Combo Tradición',
        categoriaId: categoriaId,
        costo: 7.00,
        precioVenta: 11.50,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'COM004',
        nombre: 'Café Premium',
        categoriaId: categoriaId,
        costo: 11.50,
        precioVenta: 17.00,
        emoji: const Value('🤎'),
      ),

      ProductosCompanion.insert(
        codigo: 'COM005',
        nombre: 'Combo Express',
        categoriaId: categoriaId,
        costo: 7.00,
        precioVenta: 11.00,
        emoji: const Value('🍔'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}
