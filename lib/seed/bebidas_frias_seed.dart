import 'package:drift/drift.dart';

import '../database/app_database.dart';

class BebidasFriasSeed {
  static Future<void> cargar(
      AppDatabase db,
      int categoriaId,
      ) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      ProductosCompanion.insert(
        codigo: 'BEB001',
        nombre: 'Limonada Clásica',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🍋'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB002',
        nombre: 'Limonada Frozen',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 8.00,
        emoji: const Value('🧊'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB003',
        nombre: 'Chicha Morada',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 5.00,
        emoji: const Value('🟣'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB004',
        nombre: 'Maracuyá',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🥭'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB005',
        nombre: 'Maracuyá Frozen',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 8.00,
        emoji: const Value('🧊'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB006',
        nombre: 'Agua Mineral',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('💧'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB007',
        nombre: 'Coca-Cola',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB008',
        nombre: 'Inca Kola',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB009',
        nombre: 'Sprite',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB010',
        nombre: 'Fanta',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}