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

      // BEBIDAS FRÍAS CON CAFÉ
      'BEB001': 'Iced Coffee',
      'BEB002': 'Iced Mocca',
      'BEB003': 'Iced Caramel',

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

      // Preservamos recetas fuera de esta lista: pueden ser personalizadas.
      // La depuración del catálogo debe ser explícita y auditada.

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
        }
        // Las recetas existentes, incluidos sus nombres, se preservan.
        // Los cambios de nombre requieren una acción explícita del usuario.
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