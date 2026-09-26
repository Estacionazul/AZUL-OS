import 'package:drift/drift.dart';

import '../database/app_database.dart';

class RecetasSeed {
  static Future<void> cargar(AppDatabase db) async {
    // ==========================================================
    // CATÁLOGO DEFINITIVO DE RECETAS
    // ==========================================================

    const recetasDeseadas = <String, String>{
      // CAFÉS
      'CAF001': 'Espresso',
      'CAF002': 'Espresso doble',
      'CAF003': 'Americano',
      'CAF004': 'Café con leche',
      'CAF005': 'Cappuccino',
      'CAF006': 'Latte',
      'CAF007': 'Latte vainilla o caramelo',
      'CAF008': 'Mocaccino',
      'CAF009': 'Chocolate caliente',

      // JUGOS
      'JUG001': 'Jugo de Naranja',
      'JUG002': 'Jugo de Papaya',
      'JUG003': 'Jugo de Piña',
      'JUG004': 'Jugo de Mango',
      'JUG005': 'Jugo de Fresa',
      'JUG006': 'Jugo Surtido',
      'JUG007': 'Papaya con Leche',
      'JUG008': 'Jugo Especial',
      'JUG009': 'Piña con Plátano',
      'JUG010': 'Fresa con Leche',
      'BEB004': 'Frappé de café',
      'BEB005': 'Frappé de chocolate',
      'BEB006': 'Frappé de caramelo',
      'BEB007': 'Frappé de mocaccino',
    };

    // ==========================================================
    // SINCRONIZAR RECETAS CON LOS PRODUCTOS ACTUALES
    // ==========================================================

    await db.transaction(() async {
      // --------------------------------------------------------
      // 1. Obtener los productos definitivos por código
      // --------------------------------------------------------

      final productos = <String, int>{};

      for (final codigo in recetasDeseadas.keys) {
        final producto = await (db.select(
          db.productos,
        )..where((p) => p.codigo.equals(codigo))).getSingleOrNull();

        if (producto == null) {
          throw StateError(
            'No existe el producto $codigo en la base de datos.',
          );
        }

        productos[codigo] = producto.id;
      }

      final idsPermitidos = productos.values.toList();

      // --------------------------------------------------------
      // 2. Eliminar recetas que ya no pertenecen al catálogo
      // --------------------------------------------------------

      final recetasActuales = await db.select(db.recetas).get();

      for (final receta in recetasActuales) {
        if (!idsPermitidos.contains(receta.productoId)) {
          await (db.delete(db.recetaDetalle)
            ..where((d) => d.recetaId.equals(receta.id)))
              .go();

          await (db.delete(db.recetas)
            ..where((r) => r.id.equals(receta.id)))
              .go();
        }
      }

      // --------------------------------------------------------
      // 3. Crear o corregir las 19 recetas definitivas
      // --------------------------------------------------------

      for (final entrada in recetasDeseadas.entries) {
        final codigo = entrada.key;
        final nombreCorrecto = entrada.value;
        final idProducto = productos[codigo]!;

        final receta = await (db.select(
          db.recetas,
        )..where((r) => r.productoId.equals(idProducto))).getSingleOrNull();

        if (receta == null) {
          await db
              .into(db.recetas)
              .insert(
            RecetasCompanion.insert(
              productoId: idProducto,
              nombre: nombreCorrecto,
            ),
          );
        } else if (receta.nombre != nombreCorrecto) {
          // Si el nombre antiguo era incorrecto, también eliminamos
          // sus detalles para que RecetaDetalleSeed los reconstruya.
          await (db.delete(db.recetaDetalle)
            ..where((d) => d.recetaId.equals(receta.id)))
              .go();

          await (db.update(db.recetas)
            ..where((r) => r.id.equals(receta.id)))
              .write(
            RecetasCompanion(
              nombre: Value(nombreCorrecto),
            ),
          );
        }
      }
    });

    // ==========================================================
    // VERIFICACIÓN
    // ==========================================================

    final recetas = await db.select(db.recetas).get();

    print('====================================');
    print('TOTAL RECETAS: ${recetas.length}');

    for (final receta in recetas) {
      print(
        '${receta.id} - '
            '${receta.nombre} - '
            'Producto ID: ${receta.productoId}',
      );
    }

    print('====================================');
  }
}