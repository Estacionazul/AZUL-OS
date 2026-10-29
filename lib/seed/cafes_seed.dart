import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CafesSeed {
  static Future<void> cargar(AppDatabase db, int categoriaId) async {
    final productosExistentes = await db.select(db.productos).get();
    final codigosExistentes = productosExistentes.map((p) => p.codigo).toSet();

    final lista = <ProductosCompanion>[
      // ==========================================================
      // CAFÉS Y BEBIDAS CALIENTES - 8 OZ
      // ==========================================================

      ProductosCompanion.insert(
        codigo: 'CAF001',
        nombre: 'Espresso',
        categoriaId: categoriaId,
        costo: 2.50,
        precioVenta: 6.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF002',
        nombre: 'Espresso doble',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 8.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF003',
        nombre: 'Americano',
        categoriaId: categoriaId,
        costo: 3.00,
        precioVenta: 7.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF004',
        nombre: 'Café con leche',
        categoriaId: categoriaId,
        costo: 4.00,
        precioVenta: 8.50,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF005',
        nombre: 'Cappuccino',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 10.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF006',
        nombre: 'Latte',
        categoriaId: categoriaId,
        costo: 4.80,
        precioVenta: 10.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF007',
        nombre: 'Latte caramelo',
        categoriaId: categoriaId,
        costo: 5.20,
        precioVenta: 11.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF008',
        nombre: 'Mocaccino',
        categoriaId: categoriaId,
        costo: 5.20,
        precioVenta: 11.00,
        emoji: const Value('☕'),
      ),

      ProductosCompanion.insert(
        codigo: 'CAF009',
        nombre: 'Chocolate caliente',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 10.00,
        emoji: const Value('🍫'),
      ),
    ];

    final faltantes = lista
        .where((producto) => !codigosExistentes.contains(producto.codigo.value))
        .toList();
    if (faltantes.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(db.productos, faltantes);
    });
  }
}