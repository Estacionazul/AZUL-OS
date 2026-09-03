import 'package:drift/drift.dart';

import '../database/app_database.dart';

class PostresSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      ProductosCompanion.insert(
        codigo: 'POS001',
        nombre: 'Cheesecake',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 8.00,
        emoji: const Value('🍰'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS002',
        nombre: 'Brownie',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 6.00,
        emoji: const Value('🍫'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS003',
        nombre: 'Flan',
        categoriaId: categoriaId,
        costo: 1.80,
        precioVenta: 3.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS004',
        nombre: 'Gelatina',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS005',
        nombre: 'Flan + Gelatina',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 4.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS006',
        nombre: 'Alfajor',
        categoriaId: categoriaId,
        costo: 2.00,
        precioVenta: 4.00,
        emoji: const Value('🍪'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS007',
        nombre: 'Cupcake',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 6.00,
        emoji: const Value('🧁'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS008',
        nombre: 'Muffin',
        categoriaId: categoriaId,
        costo: 3.20,
        precioVenta: 6.00,
        emoji: const Value('🧁'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS009',
        nombre: 'Galletas',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 4.00,
        emoji: const Value('🍪'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}
