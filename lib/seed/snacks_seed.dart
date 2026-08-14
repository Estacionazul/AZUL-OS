import 'package:drift/drift.dart';

import '../database/app_database.dart';

class SnacksSeed {
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
        codigo: 'SNK001',
        nombre: 'Sándwich Mixto',
        categoriaId: categoriaId,
        costo: 5.50,
        precioVenta: 8.00,
        emoji: const Value('🥪'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK002',
        nombre: 'Triple',
        categoriaId: categoriaId,
        costo: 6.50,
        precioVenta: 8.00,
        emoji: const Value('🥪'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK003',
        nombre: 'Croissant Jamón y Queso',
        categoriaId: categoriaId,
        costo: 6.00,
        precioVenta: 8.00,
        emoji: const Value('🥐'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK004',
        nombre: 'Croissant de Pollo',
        categoriaId: categoriaId,
        costo: 6.80,
        precioVenta: 9.00,
        emoji: const Value('🥐'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK005',
        nombre: 'Sándwich de Pollo',
        categoriaId: categoriaId,
        costo: 3.20,
        precioVenta: 5.00,
        emoji: const Value('🥖'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK006',
        nombre: 'Empanada de Carne',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 5.00,
        emoji: const Value('🥟'),
      ),

      ProductosCompanion.insert(
        codigo: 'SNK007',
        nombre: 'Empanada de Pollo',
        categoriaId: categoriaId,
        costo: 2.80,
        precioVenta: 5.00,
        emoji: const Value('🥟'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}