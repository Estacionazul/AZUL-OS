import 'package:drift/drift.dart';

import '../database/app_database.dart';

class BebidasFriasSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      // ==========================================================
      // ICED & FRAPPÉ - 8 OZ
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'BEB001',
        nombre: 'Iced Coffee',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 9.00,
        emoji: const Value('🧋'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB002',
        nombre: 'Iced Mocca',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 10.00,
        emoji: const Value('🧋'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB003',
        nombre: 'Iced Caramel',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 10.00,
        emoji: const Value('🧋'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB004',
        nombre: 'Frappé de café',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 9.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB005',
        nombre: 'Frappé de chocolate',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 10.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB006',
        nombre: 'Frappé de caramelo',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 11.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB007',
        nombre: 'Frappé de mocaccino',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 11.00,
        emoji: const Value('🥤'),
      ),

      // ==========================================================
      // REFRESCOS NATURALES
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'BEB008',
        nombre: 'Maracuyá',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🥭'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB009',
        nombre: 'Limonada',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🍋'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB010',
        nombre: 'Chicha morada',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 5.00,
        emoji: const Value('🟣'),
      ),

      // ==========================================================
      // FROZEN
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'BEB011',
        nombre: 'Maracuyá frozen',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 8.00,
        emoji: const Value('🧊'),
      ),

      ProductosCompanion.insert(
        codigo: 'BEB012',
        nombre: 'Limonada frozen',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 8.00,
        emoji: const Value('🧊'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}