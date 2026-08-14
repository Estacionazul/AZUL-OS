import '../database/app_database.dart';

import 'cafes_seed.dart';
import 'jugos_seed.dart';
import 'bebidas_frias_seed.dart';
import 'snacks_seed.dart';
import 'hamburguesas_seed.dart';
import 'postres_seed.dart';
import 'combos_seed.dart';
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

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Cafés'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Jugos Naturales'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Bebidas Frías'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Snacks'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Hamburguesas'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Postres'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Combos'),
    );

    await db.into(db.categorias).insert(
      CategoriasCompanion.insert(nombre: 'Insumos'),
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

    await CafesSeed.cargar(db, cafes);
    await JugosSeed.cargar(db, jugos);
    await BebidasFriasSeed.cargar(db, bebidas);
    await SnacksSeed.cargar(db, snacks);
    await HamburguesasSeed.cargar(db, hamburguesas);
    await PostresSeed.cargar(db, postres);
    await CombosSeed.cargar(db, combos);
  }

  Future<int> _categoriaId(String nombre) async {
    final categoria = await (db.select(db.categorias)
      ..where((c) => c.nombre.equals(nombre)))
        .getSingle();

    return categoria.id;
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