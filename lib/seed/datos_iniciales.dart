import '../database/app_database.dart';
import 'package:drift/drift.dart';

import 'cafes_seed.dart';
import 'jugos_seed.dart';
import 'bebidas_frias_seed.dart';
import 'snacks_seed.dart';
import 'hamburguesas_seed.dart';
import 'postres_seed.dart';
import 'combos_seed.dart';
import 'gaseosas_aguas_seed.dart';
import 'insumos_seed.dart';

// NUEVOS
import 'recetas_seed.dart';
import 'receta_detalle_seed.dart';

class DatosIniciales {
  final AppDatabase db;

  DatosIniciales(this.db);

  Future<void> cargar() async {
    await _cargarCategorias();
    await _cargarProductos();
    await _normalizarTiposInventario();
    await _cargarInsumos();

    // NUEVO
    await _cargarRecetas();
    await _cargarDetalleRecetas();
  }

  //==================================================
  // CATEGORÍAS
  //==================================================

  Future<void> _cargarCategorias() async {
    final categorias = await db.select(db.categorias).get();

    if (categorias.isNotEmpty) return;

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Cafés'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Jugos Naturales'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Bebidas Frías'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Snacks'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Hamburguesas'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Postres'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Combos'));

    await db
        .into(db.categorias)
        .insert(CategoriasCompanion.insert(nombre: 'Insumos'));

    await db
        .into(db.categorias)
        .insert(
      CategoriasCompanion.insert(
        nombre: 'Gaseosas y Aguas',
        icono: const Value('🥤'),
        orden: const Value(9),
        activo: const Value(true),
      ),
    );
  }

  //==================================================
  // PRODUCTOS
  //==================================================

  Future<void> _cargarProductos() async {
    final cafes = await _categoriaId('Cafés');
    final jugos = await _categoriaId('Jugos Naturales');
    final bebidas = await _categoriaId('Bebidas Frías');
    final snacks = await _categoriaId('Snacks');
    final hamburguesas = await _categoriaId('Hamburguesas');
    final postres = await _categoriaId('Postres');
    final combos = await _categoriaId('Combos');
    final gaseosasAguas = await _categoriaId('Gaseosas y Aguas');

    await CafesSeed.cargar(db, cafes);
    await JugosSeed.cargar(db, jugos);
    await BebidasFriasSeed.cargar(db, bebidas);
    await SnacksSeed.cargar(db, snacks);
    await HamburguesasSeed.cargar(db, hamburguesas);
    await PostresSeed.cargar(db, postres);
    await CombosSeed.cargar(db, combos);
    await GaseosasAguasSeed.cargar(db, gaseosasAguas);
  }

  Future<int> _categoriaId(String nombre) async {
    final categoria = await (db.select(
      db.categorias,
    )..where((c) => c.nombre.equals(nombre))).getSingle();

    return categoria.id;
  }

  // ==========================================================
  // NORMALIZAR TIPO DE INVENTARIO
  //
  // Todos los productos parten como "producto".
  // Solo los productos que tienen receta real se marcan
  // como "receta".
  // ==========================================================

  Future<void> _normalizarTiposInventario() async {
    const productosConReceta = <String>{
      // CAFÉS
      'CAF001',
      'CAF002',
      'CAF003',
      'CAF004',
      'CAF005',
      'CAF006',
      'CAF007',
      'CAF008',
      'CAF009',

      // JUGOS
      'JUG001',
      'JUG002',
      'JUG003',
      'JUG004',
      'JUG005',
      'JUG006',
      'JUG007',
      'JUG008',
      'JUG009',
      'JUG010',
      'BEB004',
      'BEB005',
      'BEB006',
      'BEB007',
    };

    // Primero: todo el catálogo queda como producto.
    await db.update(db.productos).write(
      const ProductosCompanion(
        tipoInventario: Value('producto'),
      ),
    );

    // Segundo: únicamente los productos con receta real
    // quedan como tipo receta.
    await (db.update(db.productos)
      ..where(
            (p) => p.codigo.isIn(productosConReceta),
      ))
        .write(
      const ProductosCompanion(
        tipoInventario: Value('receta'),
      ),
    );
  }

  //==================================================
  // INSUMOS
  //==================================================

  Future<void> _cargarInsumos() async {
    final categoria = await _categoriaId("Insumos");
    await InsumosSeed.cargar(db, categoria);
  }

  //==================================================
  // RECETAS
  //==================================================

  Future<void> _cargarRecetas() async {
    await RecetasSeed.cargar(db);
  }

  //==================================================
  // DETALLE RECETAS
  //==================================================

  Future<void> _cargarDetalleRecetas() async {
    await RecetaDetalleSeed.cargar(db);
  }
}
