import 'package:drift/drift.dart';

import '../database/app_database.dart';

class JugosSeed {
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
        codigo: 'JUG001',
        nombre: 'Jugo de Naranja',
        categoriaId: categoriaId,
        costo: 3.50,
        precioVenta: 7.00,
        emoji: const Value('🍊'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG002',
        nombre: 'Jugo de Papaya',
        categoriaId: categoriaId,
        costo: 3.50,
        precioVenta: 7.00,
        emoji: const Value('🍈'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG003',
        nombre: 'Jugo de Piña',
        categoriaId: categoriaId,
        costo: 3.80,
        precioVenta: 7.00,
        emoji: const Value('🍍'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG004',
        nombre: 'Jugo de Mango',
        categoriaId: categoriaId,
        costo: 4.20,
        precioVenta: 8.00,
        emoji: const Value('🥭'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG005',
        nombre: 'Jugo de Fresa',
        categoriaId: categoriaId,
        costo: 4.50,
        precioVenta: 8.00,
        emoji: const Value('🍓'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG006',
        nombre: 'Jugo Surtido',
        categoriaId: categoriaId,
        costo: 5.00,
        precioVenta: 8.00,
        emoji: const Value('🍹'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG007',
        nombre: 'Papaya con Leche',
        categoriaId: categoriaId,
        costo: 4.80,
        precioVenta: 9.00,
        emoji: const Value('🥛'),
      ),

      ProductosCompanion.insert(
        codigo: 'JUG008',
        nombre: 'Fresa con Leche',
        categoriaId: categoriaId,
        costo: 5.20,
        precioVenta: 10.00,
        emoji: const Value('🥛'),
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.productos, lista);
    });
  }
}