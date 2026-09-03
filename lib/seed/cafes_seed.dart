import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CafesSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      ProductosCompanion.insert(
        codigo: 'CAF001',
        nombre: 'Espresso',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 8.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF002',
        nombre: 'Doble Espresso',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 11.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF003',
        nombre: 'Americano',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 8.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF004',
        nombre: 'Capuccino',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 10.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF005',
        nombre: 'Latte',
        categoriaId: categoriaId,
        costo: 4.80,
        precioVenta: 10.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF006',
        nombre: 'Mocaccino',
        categoriaId: categoriaId,
        costo: 5.20,
        precioVenta: 11.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF007',
        nombre: 'Flat White',
        categoriaId: categoriaId,
        costo: 4.80,
        precioVenta: 11.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF008',
        nombre: 'Cortado',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 9.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF009',
        nombre: 'Chocolate Caliente',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 8.00,
        emoji: const Value('🍫'),
      ),

      ProductosCompanion.insert(
        codigo: 'INF001',
        nombre: 'Infusiones',
        categoriaId: categoriaId,
        costo: 1.40,
        precioVenta: 4.50,
        emoji: const Value('🍵'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}
