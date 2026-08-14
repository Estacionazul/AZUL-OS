import '../database/app_database.dart';
import 'package:drift/drift.dart';

class RecetaDetalleSeed {
  static Future<void> cargar(AppDatabase db) async {
    final detalles = await db.select(db.recetaDetalle).get();

    if (detalles.isNotEmpty) return;

    Future<int> recetaId(String nombre) async {
      final receta = await (db.select(db.recetas)
        ..where((r) => r.nombre.equals(nombre)))
          .getSingle();

      return receta.id;
    }

    Future<int> insumoId(String codigo) async {
      final insumo = await (db.select(db.insumos)
        ..where((i) => i.codigo.equals(codigo)))
          .getSingle();

      return insumo.id;
    }

    //=========================
    // ESPRESSO
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Espresso"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    //=========================
// DOBLE ESPRESSO
//=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Doble Espresso"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(20.0),
      ),
    );

    //=========================
    // AMERICANO
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Americano"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    //=========================
// CORTADO
//=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Cortado"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Cortado"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(60.0),
      ),
    );

    //=========================
    // CAPPUCCINO
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Capuccino"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Capuccino"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(180.0),
      ),
    );

    //=========================
    // LATTE
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Latte"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Latte"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(240.0),
      ),
    );

    //=========================
    // FLAT WHITE
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Flat White"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(20.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Flat White"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(160.0),
      ),
    );

    //=========================
    // MOCACCINO
    //=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Mocaccino"),
        insumoId: await insumoId("INS001"),
        cantidad: const Value(10.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Mocaccino"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(220.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Mocaccino"),
        insumoId: await insumoId("INS003"),
        cantidad: const Value(20.0),
      ),
    );

    //=========================
// CHOCOLATE CALIENTE
//=========================

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Chocolate Caliente"),
        insumoId: await insumoId("INS002"),
        cantidad: const Value(250.0),
      ),
    );

    await db.into(db.recetaDetalle).insert(
      RecetaDetalleCompanion.insert(
        recetaId: await recetaId("Chocolate Caliente"),
        insumoId: await insumoId("INS003"),
        cantidad: const Value(30.0),
      ),
    );
    final total = await db.select(db.recetaDetalle).get();

    print("====================================");
    print("TOTAL DETALLE RECETAS: ${total.length}");

    for (final d in total) {
      print(
        "Receta: ${d.recetaId} - Insumo: ${d.insumoId} - Cantidad: ${d.cantidad}",
      );
    }

    print("====================================");
  }
}