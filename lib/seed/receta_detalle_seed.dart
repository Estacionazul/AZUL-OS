import 'package:drift/drift.dart';

import '../database/app_database.dart';

class RecetaDetalleSeed {
  static Future<void> cargar(AppDatabase db) async {

    // ==========================================================
    // BUSCAR RECETA
    // ==========================================================

    Future<int> recetaId(String nombre) async {
      final receta = await (db.select(db.recetas)
        ..where((r) => r.nombre.equals(nombre)))
          .getSingle();

      return receta.id;
    }

    // ==========================================================
    // BUSCAR INSUMO
    // ==========================================================

    Future<int> insumoId(String codigo) async {
      final insumo = await (db.select(db.insumos)
        ..where((i) => i.codigo.equals(codigo)))
          .getSingle();

      return insumo.id;
    }

    // ==========================================================
    // AGREGAR DETALLE SOLO SI NO EXISTE
    // ==========================================================

    Future<void> agregarDetalle({
      required String receta,
      required String insumo,
      required double cantidad,
      required String unidad,
      required int orden,
    }) async {

      final idReceta = await recetaId(receta);
      final idInsumo = await insumoId(insumo);

      final existente = await (db.select(db.recetaDetalle)
        ..where(
              (d) =>
          d.recetaId.equals(idReceta) &
          d.insumoId.equals(idInsumo),
        ))
          .getSingleOrNull();

      if (existente != null) {
        return;
      }

      await db.into(db.recetaDetalle).insert(
        RecetaDetalleCompanion.insert(
          recetaId: idReceta,
          insumoId: idInsumo,
          cantidad: Value(cantidad),
          unidad: Value(unidad),
          orden: Value(orden),
        ),
      );
    }

    // ==========================================================
    // ESPRESSO
    // ==========================================================

    await agregarDetalle(
      receta: "Espresso",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // DOBLE ESPRESSO
    // ==========================================================

    await agregarDetalle(
      receta: "Doble Espresso",
      insumo: "INS001",
      cantidad: 20.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // AMERICANO
    // ==========================================================

    await agregarDetalle(
      receta: "Americano",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // CORTADO
    // ==========================================================

    await agregarDetalle(
      receta: "Cortado",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Cortado",
      insumo: "INS002",
      cantidad: 60.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // CAPPUCCINO
    // ==========================================================

    await agregarDetalle(
      receta: "Capuccino",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Capuccino",
      insumo: "INS002",
      cantidad: 180.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // LATTE
    // ==========================================================

    await agregarDetalle(
      receta: "Latte",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Latte",
      insumo: "INS002",
      cantidad: 240.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // FLAT WHITE
    // ==========================================================

    await agregarDetalle(
      receta: "Flat White",
      insumo: "INS001",
      cantidad: 20.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Flat White",
      insumo: "INS002",
      cantidad: 160.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // MOCACCINO
    // ==========================================================

    await agregarDetalle(
      receta: "Mocaccino",
      insumo: "INS001",
      cantidad: 10.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Mocaccino",
      insumo: "INS002",
      cantidad: 220.0,
      unidad: "ml",
      orden: 2,
    );

    await agregarDetalle(
      receta: "Mocaccino",
      insumo: "INS003",
      cantidad: 20.0,
      unidad: "g",
      orden: 3,
    );

    // ==========================================================
    // CHOCOLATE CALIENTE
    // ==========================================================

    await agregarDetalle(
      receta: "Chocolate Caliente",
      insumo: "INS002",
      cantidad: 250.0,
      unidad: "ml",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Chocolate Caliente",
      insumo: "INS003",
      cantidad: 30.0,
      unidad: "g",
      orden: 2,
    );

    // ==========================================================
    // JUGO DE NARANJA — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo de Naranja",
      insumo: "INS016",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // JUGO DE PAPAYA — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo de Papaya",
      insumo: "INS008",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // JUGO DE PIÑA — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo de Piña",
      insumo: "INS009",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // JUGO DE MANGO — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo de Mango",
      insumo: "INS010",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // JUGO DE FRESA — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo de Fresa",
      insumo: "INS006",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    // ==========================================================
    // JUGO SURTIDO — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Jugo Surtido",
      insumo: "INS008",
      cantidad: 60.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Jugo Surtido",
      insumo: "INS009",
      cantidad: 60.0,
      unidad: "g",
      orden: 2,
    );

    await agregarDetalle(
      receta: "Jugo Surtido",
      insumo: "INS010",
      cantidad: 60.0,
      unidad: "g",
      orden: 3,
    );

    await agregarDetalle(
      receta: "Jugo Surtido",
      insumo: "INS007",
      cantidad: 60.0,
      unidad: "g",
      orden: 4,
    );

    // ==========================================================
    // PAPAYA CON LECHE — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Papaya con Leche",
      insumo: "INS008",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Papaya con Leche",
      insumo: "INS002",
      cantidad: 250.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // FRESA CON LECHE — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Fresa con Leche",
      insumo: "INS006",
      cantidad: 250.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Fresa con Leche",
      insumo: "INS002",
      cantidad: 250.0,
      unidad: "ml",
      orden: 2,
    );

    // ==========================================================
    // PIÑA CON PLÁTANO — 600 ML
    // ==========================================================

    await agregarDetalle(
      receta: "Piña con Plátano",
      insumo: "INS009",
      cantidad: 150.0,
      unidad: "g",
      orden: 1,
    );

    await agregarDetalle(
      receta: "Piña con Plátano",
      insumo: "INS007",
      cantidad: 150.0,
      unidad: "g",
      orden: 2,
    );

    // ==========================================================
    // VERIFICACIÓN
    // ==========================================================

    final total = await db.select(db.recetaDetalle).get();

    print("====================================");
    print("TOTAL DETALLES RECETAS: ${total.length}");

    for (final d in total) {
      print(
        "Receta: ${d.recetaId} | "
            "Insumo: ${d.insumoId} | "
            "Cantidad: ${d.cantidad} | "
            "Unidad: ${d.unidad}",
      );
    }

    print("====================================");
  }
}