import '../database/app_database.dart';

class RecetasSeed {
  static Future<void> cargar(AppDatabase db) async {

    // ==========================================================
    // BUSCAR PRODUCTO
    // ==========================================================

    Future<int> productoId(String codigo) async {
      final producto = await (db.select(db.productos)
        ..where((p) => p.codigo.equals(codigo)))
          .getSingle();

      return producto.id;
    }

    // ==========================================================
    // CREAR RECETA SOLO SI NO EXISTE
    // ==========================================================

    Future<void> agregarReceta({
      required String codigoProducto,
      required String nombre,
    }) async {

      final idProducto = await productoId(codigoProducto);

      final existente = await (db.select(db.recetas)
        ..where((r) => r.productoId.equals(idProducto)))
          .getSingleOrNull();

      if (existente != null) {
        return;
      }

      await db.into(db.recetas).insert(
        RecetasCompanion.insert(
          productoId: idProducto,
          nombre: nombre,
        ),
      );
    }

    // ==========================================================
    // CAFÉS
    // ==========================================================

    await agregarReceta(
      codigoProducto: "CAF001",
      nombre: "Espresso",
    );

    await agregarReceta(
      codigoProducto: "CAF002",
      nombre: "Doble Espresso",
    );

    await agregarReceta(
      codigoProducto: "CAF003",
      nombre: "Americano",
    );

    await agregarReceta(
      codigoProducto: "CAF004",
      nombre: "Capuccino",
    );

    await agregarReceta(
      codigoProducto: "CAF005",
      nombre: "Latte",
    );

    await agregarReceta(
      codigoProducto: "CAF006",
      nombre: "Mocaccino",
    );

    await agregarReceta(
      codigoProducto: "CAF007",
      nombre: "Flat White",
    );

    await agregarReceta(
      codigoProducto: "CAF008",
      nombre: "Cortado",
    );

    await agregarReceta(
      codigoProducto: "CAF009",
      nombre: "Chocolate Caliente",
    );

    // ==========================================================
    // JUGOS — 600 ML
    // ==========================================================

    await agregarReceta(
      codigoProducto: "JUG001",
      nombre: "Jugo de Naranja",
    );

    await agregarReceta(
      codigoProducto: "JUG002",
      nombre: "Jugo de Papaya",
    );

    await agregarReceta(
      codigoProducto: "JUG003",
      nombre: "Jugo de Piña",
    );

    await agregarReceta(
      codigoProducto: "JUG004",
      nombre: "Jugo de Mango",
    );

    await agregarReceta(
      codigoProducto: "JUG005",
      nombre: "Jugo de Fresa",
    );

    await agregarReceta(
      codigoProducto: "JUG006",
      nombre: "Jugo Surtido",
    );

    await agregarReceta(
      codigoProducto: "JUG007",
      nombre: "Papaya con Leche",
    );

    await agregarReceta(
      codigoProducto: "JUG008",
      nombre: "Fresa con Leche",
    );

    await agregarReceta(
      codigoProducto: "JUG009",
      nombre: "Piña con Plátano",
    );

    // ==========================================================
    // VERIFICACIÓN
    // ==========================================================

    final recetas = await db.select(db.recetas).get();

    print("====================================");
    print("TOTAL RECETAS: ${recetas.length}");

    for (final receta in recetas) {
      print(
        "${receta.id} - "
            "${receta.nombre} - "
            "Producto ID: ${receta.productoId}",
      );
    }

    print("====================================");
  }
}