import 'package:drift/drift.dart';

import '../database/app_database.dart';

class SnacksSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      // ==========================================================
      // SNACKS
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'SNK001',
        nombre: 'Croissant',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🥐'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK002',
        nombre: 'Triple mixto',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 8.00,
        emoji: const Value('🥪'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK003',
        nombre: 'Croissant de jamón y queso',
        categoriaId: categoriaId,
        costo: 6.00,
        precioVenta: 8.00,
        emoji: const Value('🥐'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK004',
        nombre: 'Croissant de pollo',
        categoriaId: categoriaId,
        costo: 6.80,
        precioVenta: 10.00,
        emoji: const Value('🥐'),
      ),

      // ==========================================================
      // EMPANADAS
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'SNK005',
        nombre: 'Empanada de carne',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 6.00,
        emoji: const Value('🥟'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK006',
        nombre: 'Empanada de pollo',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 6.00,
        emoji: const Value('🥟'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK007',
        nombre: 'Empanada mixta',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 6.00,
        emoji: const Value('🥟'),
      ),

      // ==========================================================
      // SÁNDWICHES
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'SNK008',
        nombre: 'Sándwich de chorizo',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 7.00,
        emoji: const Value('🥖'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK009',
        nombre: 'Sándwich de pollo',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 7.00,
        emoji: const Value('🥖'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK010',
        nombre: 'Sándwich de filete de pechuga',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 10.00,
        emoji: const Value('🥖'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}