import 'package:drift/drift.dart';

import '../database/app_database.dart';

class RecetasSeed {
  static Future<void> cargar(AppDatabase db) async {
    final recetas = await db.select(db.recetas).get();

    if (recetas.isNotEmpty) return;

    Future<int> productoId(String codigo) async {
      final producto = await (db.select(db.productos)
        ..where((p) => p.codigo.equals(codigo)))
          .getSingle();

      return producto.id;
    }

    final lista = <RecetasCompanion>[
      RecetasCompanion.insert(
        productoId: await productoId("CAF001"),
        nombre: "Espresso",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF002"),
        nombre: "Doble Espresso",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF003"),
        nombre: "Americano",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF004"),
        nombre: "Capuccino",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF005"),
        nombre: "Latte",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF006"),
        nombre: "Mocaccino",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF007"),
        nombre: "Flat White",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF008"),
        nombre: "Cortado",
      ),

      RecetasCompanion.insert(
        productoId: await productoId("CAF009"),
        nombre: "Chocolate Caliente",
      ),
    ];

    await db.batch((batch) {
      batch.insertAll(db.recetas, lista);
    });
  }
}