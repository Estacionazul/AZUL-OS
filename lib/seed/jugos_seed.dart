import 'package:drift/drift.dart';

import '../database/app_database.dart';

class JugosSeed {
  static Future<void> cargar(
      AppDatabase db,
      int categoriaId,
      ) async {

    // ==========================================================
    // INSERTAR SOLO PRODUCTOS QUE NO EXISTAN
    // ==========================================================

    Future<void> agregar({
      required String codigo,
      required String nombre,
      required double costo,
      required double precioVenta,
      required String emoji,
    }) async {

      final existente = await (db.select(db.productos)
        ..where((p) => p.codigo.equals(codigo)))
          .getSingleOrNull();

      if (existente != null) {
        return;
      }

      await db.into(db.productos).insert(
        ProductosCompanion.insert(
          codigo: codigo,
          nombre: nombre,
          categoriaId: categoriaId,
          costo: costo,
          precioVenta: precioVenta,
          emoji: Value(emoji),
        ),
      );
    }

    // ==========================================================
    // JUGOS NATURALES
    // ==========================================================

    await agregar(
      codigo: 'JUG001',
      nombre: 'Jugo de Naranja',
      costo: 3.50,
      precioVenta: 7.00,
      emoji: '🍊',
    );

    await agregar(
      codigo: 'JUG002',
      nombre: 'Jugo de Papaya',
      costo: 3.50,
      precioVenta: 7.00,
      emoji: '🍈',
    );

    await agregar(
      codigo: 'JUG003',
      nombre: 'Jugo de Piña',
      costo: 3.80,
      precioVenta: 7.00,
      emoji: '🍍',
    );

    await agregar(
      codigo: 'JUG004',
      nombre: 'Jugo de Mango',
      costo: 4.20,
      precioVenta: 8.00,
      emoji: '🥭',
    );

    await agregar(
      codigo: 'JUG005',
      nombre: 'Jugo de Fresa',
      costo: 4.50,
      precioVenta: 8.00,
      emoji: '🍓',
    );

    await agregar(
      codigo: 'JUG006',
      nombre: 'Jugo Surtido',
      costo: 5.00,
      precioVenta: 8.00,
      emoji: '🍹',
    );

    await agregar(
      codigo: 'JUG007',
      nombre: 'Papaya con Leche',
      costo: 4.80,
      precioVenta: 9.00,
      emoji: '🥛',
    );

    await agregar(
      codigo: 'JUG008',
      nombre: 'Fresa con Leche',
      costo: 5.20,
      precioVenta: 10.00,
      emoji: '🥛',
    );

    // ==========================================================
    // NUEVO
    // ==========================================================

    await agregar(
      codigo: 'JUG009',
      nombre: 'Piña con Plátano',
      costo: 4.50,
      precioVenta: 8.00,
      emoji: '🍍',
    );

    // ==========================================================
    // VERIFICACIÓN
    // ==========================================================

    final productos = await (db.select(db.productos)
      ..where((p) => p.categoriaId.equals(categoriaId)))
        .get();

    print("====================================");
    print("JUGOS REGISTRADOS: ${productos.length}");

    for (final producto in productos) {
      print(
        "${producto.codigo} - "
            "${producto.nombre} - "
            "S/. ${producto.precioVenta.toStringAsFixed(2)}",
      );
    }

    print("====================================");
  }
}