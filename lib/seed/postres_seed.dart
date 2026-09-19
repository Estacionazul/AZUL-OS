import 'package:drift/drift.dart';

import '../database/app_database.dart';

class PostresSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      // ==========================================================
      // POSTRES
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'POS001',
        nombre: 'Gelatina',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS002',
        nombre: 'Flan',
        categoriaId: categoriaId,
        costo: 1.80,
        precioVenta: 3.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS003',
        nombre: 'Gelatina con flan',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 4.00,
        emoji: const Value('🍮'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS004',
        nombre: 'Queque de naranja',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 5.00,
        emoji: const Value('🍰'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS005',
        nombre: 'Pastel de acelga',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 7.00,
        emoji: const Value('🥧'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS006',
        nombre: 'Pie de manzana',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 7.00,
        emoji: const Value('🥧'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS007',
        nombre: 'Cheesecake de maracuyá',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 8.00,
        emoji: const Value('🍰'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS008',
        nombre: 'Pie de limón',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 8.00,
        emoji: const Value('🥧'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS009',
        nombre: 'Carrot cake',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 8.00,
        emoji: const Value('🍰'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS010',
        nombre: 'Cheesecake de fresa',
        categoriaId: categoriaId,
        costo: 5.80,
        precioVenta: 9.00,
        emoji: const Value('🍰'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS011',
        nombre: 'Ensalada de frutas',
        categoriaId: categoriaId,
        costo: 6.00,
        precioVenta: 10.00,
        emoji: const Value('🍓'),
      ),

      // ==========================================================
      // GALLETAS
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'POS012',
        nombre: 'Galletas de avena',
        categoriaId: categoriaId,
        costo: 2.00,
        precioVenta: 5.00,
        emoji: const Value('🍪'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS013',
        nombre: 'Galletas de choco chips',
        categoriaId: categoriaId,
        costo: 2.20,
        precioVenta: 5.00,
        emoji: const Value('🍪'),
      ),

      // ==========================================================
      // WAFFLES
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'POS014',
        nombre: 'Waffle clásico',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 8.00,
        emoji: const Value('🧇'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS015',
        nombre: 'Waffle con caramelo o miel',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 10.00,
        emoji: const Value('🧇'),
      ),

      ProductosCompanion.insert(
        codigo: 'POS016',
        nombre: 'Waffle especial Estación Azul',
        categoriaId: categoriaId,
        costo: 6.50,
        precioVenta: 13.00,
        emoji: const Value('🧇'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}