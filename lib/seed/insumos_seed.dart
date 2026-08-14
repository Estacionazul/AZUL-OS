import 'package:drift/drift.dart';

import '../database/app_database.dart';

class InsumosSeed {
  static Future<void> cargar(
      AppDatabase db,
      int categoriaId,
      ) async {

    final existentes = await db.select(db.insumos).get();

    if (existentes.isNotEmpty) return;

    Future<void> agregar({
      required String codigo,
      required String nombre,
      required String unidad,
      required double stock,
      required double minimo,
      required double costo,
      required String emoji,
    }) async {

      await db.into(db.insumos).insert(
        InsumosCompanion.insert(
          codigo: codigo,
          nombre: nombre,
          categoriaId: categoriaId,
          unidadMedida: unidad,
          stock: Value(stock),
          stockMinimo: Value(minimo),
          costoCompra: Value(costo),
          emoji: Value(emoji),
        ),
      );
    }

    //----------------------------------------
    // CAFÉ
    //----------------------------------------

    await agregar(
      codigo: "INS001",
      nombre: "Café Espresso",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.08,
      emoji: "☕",
    );

    await agregar(
      codigo: "INS002",
      nombre: "Leche",
      unidad: "ml",
      stock: 10000,
      minimo: 2000,
      costo: 0.006,
      emoji: "🥛",
    );

    await agregar(
      codigo: "INS003",
      nombre: "Chocolate",
      unidad: "g",
      stock: 3000,
      minimo: 500,
      costo: 0.04,
      emoji: "🍫",
    );

    await agregar(
      codigo: "INS004",
      nombre: "Azúcar",
      unidad: "g",
      stock: 10000,
      minimo: 1000,
      costo: 0.002,
      emoji: "🍚",
    );

    await agregar(
      codigo: "INS005",
      nombre: "Canela",
      unidad: "g",
      stock: 1000,
      minimo: 100,
      costo: 0.05,
      emoji: "🌿",
    );

    //----------------------------------------
    // JUGOS
    //----------------------------------------

    await agregar(
      codigo: "INS006",
      nombre: "Fresa",
      unidad: "g",
      stock: 4000,
      minimo: 1000,
      costo: 0.02,
      emoji: "🍓",
    );

    await agregar(
      codigo: "INS007",
      nombre: "Plátano",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.01,
      emoji: "🍌",
    );

    await agregar(
      codigo: "INS008",
      nombre: "Papaya",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.01,
      emoji: "🧡",
    );

    await agregar(
      codigo: "INS009",
      nombre: "Piña",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.02,
      emoji: "🍍",
    );

    await agregar(
      codigo: "INS010",
      nombre: "Mango",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.02,
      emoji: "🥭",
    );

    //----------------------------------------
    // HAMBURGUESAS
    //----------------------------------------

    await agregar(
      codigo: "INS011",
      nombre: "Pan Brioche",
      unidad: "und",
      stock: 100,
      minimo: 20,
      costo: 1.2,
      emoji: "🍔",
    );

    await agregar(
      codigo: "INS012",
      nombre: "Carne",
      unidad: "g",
      stock: 5000,
      minimo: 1000,
      costo: 0.03,
      emoji: "🥩",
    );

    await agregar(
      codigo: "INS013",
      nombre: "Queso",
      unidad: "g",
      stock: 3000,
      minimo: 500,
      costo: 0.03,
      emoji: "🧀",
    );

    await agregar(
      codigo: "INS014",
      nombre: "Lechuga",
      unidad: "g",
      stock: 3000,
      minimo: 500,
      costo: 0.01,
      emoji: "🥬",
    );

    await agregar(
      codigo: "INS015",
      nombre: "Tomate",
      unidad: "g",
      stock: 3000,
      minimo: 500,
      costo: 0.01,
      emoji: "🍅",
    );
  }
}