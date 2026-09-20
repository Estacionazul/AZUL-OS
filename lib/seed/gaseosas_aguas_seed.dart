import 'package:drift/drift.dart';

import '../database/app_database.dart';

class GaseosasAguasSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productos = await db.select(db.productos).get();

    if (productos.any((p) => p.categoriaId == categoriaId)) {
      return;
    }

    final lista = <ProductosCompanion>[
      // ==========================================================
      // GASEOSAS - VIDRIO 350 ML
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA001',
        nombre: 'Coca-Cola 350 ml Vidrio',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA002',
        nombre: 'Inca Kola 350 ml Vidrio',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA003',
        nombre: 'Sprite 350 ml Vidrio',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA004',
        nombre: 'Fanta 350 ml Vidrio',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.00,
        emoji: const Value('🥤'),
      ),

      // ==========================================================
      // GASEOSAS - 500 ML
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA005',
        nombre: 'Coca-Cola 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA006',
        nombre: 'Coca-Cola Zero 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA007',
        nombre: 'Inca Kola 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA008',
        nombre: 'Inca Kola Zero 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA009',
        nombre: 'Sprite 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA010',
        nombre: 'Fanta Naranja 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA011',
        nombre: 'Fanta Roja 500 ml',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 4.00,
        emoji: const Value('🥤'),
      ),

      // ==========================================================
      // GASEOSA - GORDITA 700 ML
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA012',
        nombre: 'Inca Kola Gordita 700 ml Vidrio',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 5.00,
        emoji: const Value('🥤'),
      ),

      // ==========================================================
      // AGUAS - SAN MATEO
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA013',
        nombre: 'San Mateo Sin Gas Personal',
        categoriaId: categoriaId,
        costo: 1.20,
        precioVenta: 3.00,
        emoji: const Value('💧'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA014',
        nombre: 'San Mateo Con Gas Personal',
        categoriaId: categoriaId,
        costo: 1.20,
        precioVenta: 3.00,
        emoji: const Value('💧'),
      ),

      // ==========================================================
      // AGUAS - CIELO
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA015',
        nombre: 'Cielo Personal',
        categoriaId: categoriaId,
        costo: 0.70,
        precioVenta: 2.00,
        emoji: const Value('💧'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA016',
        nombre: 'Cielo 1 L',
        categoriaId: categoriaId,
        costo: 1.50,
        precioVenta: 3.50,
        emoji: const Value('💧'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA017',
        nombre: 'Cielo 2.5 L',
        categoriaId: categoriaId,
        costo: 2.40,
        precioVenta: 4.00,
        emoji: const Value('💧'),
      ),

      // ==========================================================
      // OTRAS BEBIDAS
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'GA018',
        nombre: 'Sporade',
        categoriaId: categoriaId,
        costo: 1.20,
        precioVenta: 2.50,
        emoji: const Value('🥤'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA019',
        nombre: 'Frugos Cajita',
        categoriaId: categoriaId,
        costo: 1.20,
        precioVenta: 2.50,
        emoji: const Value('🧃'),
      ),

      ProductosCompanion.insert(
        codigo: 'GA020',
        nombre: 'Frugos Botella',
        categoriaId: categoriaId,
        costo: 2.10,
        precioVenta: 3.00,
        emoji: const Value('🧃'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}