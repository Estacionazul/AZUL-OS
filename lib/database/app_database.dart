import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dao/productos_dao.dart';
import 'dao/insumos_dao.dart';
import 'dao/recetas_dao.dart';
import 'dao/receta_detalle_dao.dart';
import 'dao/ventas_dao.dart';
import 'dao/clientes_dao.dart';
import 'dao/movimientos_inventario_dao.dart';
import 'dao/empresa_dao.dart';
import 'dao/cajas_dao.dart';
import 'dao/usuarios_dao.dart';
import 'dao/permisos_usuario_dao.dart';
import 'dao/comprobantes_electronicos_dao.dart';
import 'dao/resumenes_diarios_dao.dart';
import 'dao/resumenes_diarios_detalles_dao.dart';

import 'tables/productos_table.dart';
import 'tables/categorias_table.dart';
import 'tables/insumos_table.dart';
import 'tables/recetas_table.dart';
import 'tables/receta_detalle_table.dart';
import 'tables/ventas_table.dart';
import 'tables/detalle_ventas_table.dart';
import 'tables/clientes_table.dart';
import 'tables/movimientos_inventario_table.dart';
import 'tables/empresa_table.dart';
import 'tables/cajas_table.dart';
import 'tables/movimientos_caja_table.dart';
import 'tables/usuarios_table.dart';
import 'tables/permisos_usuario_table.dart';
import 'tables/comprobantes_electronicos_table.dart';
import 'tables/correlativos_table.dart';
import 'tables/pedidos_table.dart';
import 'tables/pedido_detalles_table.dart';
import 'tables/resumenes_diarios_table.dart';
import 'tables/resumenes_diarios_detalles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Productos,
    Categorias,
    Insumos,
    Recetas,
    RecetaDetalle,
    Ventas,
    DetalleVentas,
    Clientes,
    MovimientosInventario,
    Empresa,
    Cajas,
    MovimientosCaja,
    Usuarios,
    PermisosUsuario,
    ComprobantesElectronicos,
    Correlativos,
    Pedidos,
    PedidoDetalles,
    ResumenesDiarios,
    ResumenesDiariosDetalles,
  ],
  daos: [
    ProductosDao,
    InsumosDao,
    RecetasDao,
    RecetaDetalleDao,
    VentasDao,
    ClientesDao,
    MovimientosInventarioDao,
    EmpresaDao,
    CajasDao,
    UsuariosDao,
    PermisosUsuarioDao,
    ComprobantesElectronicosDao,
    ResumenesDiariosDao,
    ResumenesDiariosDetallesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({String? databasePath})
      : super(_openConnection(databasePath));

  @override
  int get schemaVersion => 35;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 11) {
        await m.createTable(cajas);
        await m.createTable(movimientosCaja);
      }

      if (from < 12) {
        await m.createTable(usuarios);
      }

      if (from < 13) {
        await m.createTable(permisosUsuario);
      }

      if (from < 14) {
        await m.createTable(comprobantesElectronicos);
      }

      if (from < 15) {
        await m.createTable(correlativos);
      }

      if (from < 16) {
        await m.createTable(pedidos);
        await m.createTable(pedidoDetalles);
      }

      if (from < 17) {
        await m.createTable(resumenesDiarios);
      }

      if (from < 18) {
        await m.createTable(resumenesDiariosDetalles);
      }

      if (from < 19) {
        await m.addColumn(ventas, ventas.usuarioId);
      }

      if (from < 20) {
        await m.addColumn(empresa, empresa.razonSocial);
      }

      if (from < 21) {
        await m.addColumn(comprobantesElectronicos, comprobantesElectronicos.razonSocial);
      }

      if (from < 22) {
        await m.addColumn(detalleVentas, detalleVentas.tipoAfectacionIgv);
      }

      if (from < 23) {
        await m.addColumn(productos, productos.tipoAfectacionIgv);
      }

      if (from < 24) {
        await into(categorias).insert(
          CategoriasCompanion.insert(
            nombre: 'Gaseosas y Aguas',
            icono: const Value('🥤'),
            orden: const Value(9),
            activo: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      if (from < 32) {
        // ============================================================
        // MIGRACIÓN 32
        // ACTUALIZACIÓN DEL CATÁLOGO ESTACIÓN AZUL
        // ============================================================
        //
        // Objetivo:
        // 1. Crear o actualizar los productos conocidos de la carta.
        // 2. Corregir nombres, precios y descripciones del catálogo definido.
        // 3. Crear GA019, GA020 y GA021.
        // 4. Preservar productos ajenos a la carta codificada: podrían
        //    tener referencias históricas o ser productos personalizados.
        // 5. No eliminar automáticamente productos ni movimientos históricos.
        //
        // Los cambios de catálogo siguen requiriendo revisión antes de
        // ejecutar una migración sobre una base productiva.
        //
        // ============================================================

        if (from < 32) {
          // ==========================================================
          // CATÁLOGO DEFINITIVO
          // ==========================================================

          // SEGURIDAD DE DATOS:
          // No eliminamos productos fuera de la carta actual durante una
          // migración automática. Pueden existir referencias históricas en
          // ventas, pedidos, recetas o movimientos de inventario. La depuración
          // del catálogo debe ser un proceso explícito y auditado, no parte
          // del arranque de la aplicación.

          // FUNCIÓN PARA OBTENER CATEGORÍA
          // ==========================================================

          Future<int> categoriaId(String nombre) async {
            final categoria = await (select(categorias)
              ..where(
                    (c) => c.nombre.equals(nombre),
              ))
                .getSingle();

            return categoria.id;
          }

          // ==========================================================
          // FUNCIÓN PARA CREAR O ACTUALIZAR PRODUCTO
          // ==========================================================

          Future<void> guardarProducto({
            required String codigo,
            required String nombre,
            required String categoria,
            required double costo,
            required double precio,
            String emoji = '📦',
            String descripcion = '',
          }) async {
            final existente = await (select(productos)
              ..where(
                    (p) => p.codigo.equals(codigo),
              ))
                .getSingleOrNull();

            final idCategoria = await categoriaId(categoria);

            if (existente == null) {
              await into(productos).insert(
                ProductosCompanion.insert(
                  codigo: codigo,
                  nombre: nombre,
                  descripcion: Value(descripcion),
                  categoriaId: idCategoria,
                  costo: costo,
                  precioVenta: precio,
                  emoji: Value(emoji),
                ),
              );
            } else {
              // No sobrescribimos automáticamente nombre, categoría, precio,
              // costo ni estado de productos existentes durante el arranque.
              // Las correcciones comerciales deben hacerse mediante un cambio
              // explícito y revisado, no como efecto colateral de una migración.
            }
          }

          // ==========================================================
          // CAFÉS
          // ==========================================================

          await guardarProducto(
            codigo: 'CAF001',
            nombre: 'Espresso',
            categoria: 'Cafés',
            costo: 1.60,
            precio: 6.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF002',
            nombre: 'Espresso Doble',
            categoria: 'Cafés',
            costo: 2.40,
            precio: 8.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF003',
            nombre: 'Americano',
            categoria: 'Cafés',
            costo: 1.60,
            precio: 7.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF004',
            nombre: 'Café con Leche',
            categoria: 'Cafés',
            costo: 2.80,
            precio: 8.50,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF005',
            nombre: 'Cappuccino',
            categoria: 'Cafés',
            costo: 3.20,
            precio: 10.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF006',
            nombre: 'Latte',
            categoria: 'Cafés',
            costo: 3.20,
            precio: 10.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF007',
            nombre: 'Latte Vainilla o Caramelo',
            categoria: 'Cafés',
            costo: 3.60,
            precio: 11.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF008',
            nombre: 'Mocaccino',
            categoria: 'Cafés',
            costo: 3.80,
            precio: 11.00,
            emoji: '☕',
          );

          await guardarProducto(
            codigo: 'CAF009',
            nombre: 'Chocolate Caliente',
            categoria: 'Cafés',
            costo: 3.50,
            precio: 10.00,
            emoji: '🍫',
          );

          // ==========================================================
          // JUGOS
          // ==========================================================

          await guardarProducto(
            codigo: 'JUG001',
            nombre: 'Jugo de Naranja',
            categoria: 'Jugos Naturales',
            costo: 3.50,
            precio: 8.00,
            emoji: '🍊',
          );

          await guardarProducto(
            codigo: 'JUG002',
            nombre: 'Jugo de Papaya',
            categoria: 'Jugos Naturales',
            costo: 3.50,
            precio: 8.00,
            emoji: '🧡',
          );

          await guardarProducto(
            codigo: 'JUG003',
            nombre: 'Jugo de Piña',
            categoria: 'Jugos Naturales',
            costo: 3.80,
            precio: 8.00,
            emoji: '🍍',
          );

          await guardarProducto(
            codigo: 'JUG004',
            nombre: 'Jugo de Mango',
            categoria: 'Jugos Naturales',
            costo: 4.20,
            precio: 9.00,
            emoji: '🥭',
          );

          await guardarProducto(
            codigo: 'JUG005',
            nombre: 'Jugo de Fresa',
            categoria: 'Jugos Naturales',
            costo: 4.50,
            precio: 10.00,
            emoji: '🍓',
          );

          await guardarProducto(
            codigo: 'JUG006',
            nombre: 'Jugo Surtido',
            categoria: 'Jugos Naturales',
            costo: 4.50,
            precio: 10.00,
            emoji: '🥤',
          );

          await guardarProducto(
            codigo: 'JUG007',
            nombre: 'Papaya con Leche',
            categoria: 'Jugos Naturales',
            costo: 5.00,
            precio: 10.00,
            emoji: '🥤',
          );

          await guardarProducto(
            codigo: 'JUG008',
            nombre: 'Jugo Especial',
            categoria: 'Jugos Naturales',
            costo: 6.00,
            precio: 12.00,
            emoji: '🥤',
          );

          await guardarProducto(
            codigo: 'JUG009',
            nombre: 'Piña con Plátano',
            categoria: 'Jugos Naturales',
            costo: 4.80,
            precio: 10.00,
            emoji: '🍍',
          );

          await guardarProducto(
            codigo: 'JUG010',
            nombre: 'Fresa con Leche',
            categoria: 'Jugos Naturales',
            costo: 5.20,
            precio: 12.00,
            emoji: '🍓',
          );

          // ==========================================================
          // BEBIDAS FRÍAS
          // ==========================================================

          const bebidasFrias = <Map<String, dynamic>>[
            {
              'codigo': 'BEB001',
              'nombre': 'Iced Coffee',
              'costo': 3.50,
              'precio': 9.00,
            },
            {
              'codigo': 'BEB002',
              'nombre': 'Iced Mocca',
              'costo': 4.00,
              'precio': 10.00,
            },
            {
              'codigo': 'BEB003',
              'nombre': 'Iced Caramel',
              'costo': 4.00,
              'precio': 10.00,
            },
            {
              'codigo': 'BEB004',
              'nombre': 'Frappé de café',
              'costo': 3.50,
              'precio': 9.00,
            },
            {
              'codigo': 'BEB005',
              'nombre': 'Frappé de chocolate',
              'costo': 4.00,
              'precio': 10.00,
            },
            {
              'codigo': 'BEB006',
              'nombre': 'Frappé de caramelo',
              'costo': 4.50,
              'precio': 11.00,
            },
            {
              'codigo': 'BEB007',
              'nombre': 'Frappé de mocaccino',
              'costo': 4.50,
              'precio': 11.00,
            },
            {
              'codigo': 'BEB008',
              'nombre': 'Maracuyá',
              'costo': 2.00,
              'precio': 5.00,
            },
            {
              'codigo': 'BEB009',
              'nombre': 'Limonada',
              'costo': 2.00,
              'precio': 5.00,
            },
            {
              'codigo': 'BEB010',
              'nombre': 'Chicha morada',
              'costo': 2.00,
              'precio': 5.00,
            },
            {
              'codigo': 'BEB011',
              'nombre': 'Maracuyá frozen',
              'costo': 3.00,
              'precio': 8.00,
            },
            {
              'codigo': 'BEB012',
              'nombre': 'Limonada frozen',
              'costo': 3.00,
              'precio': 8.00,
            },
          ];

          for (final bebida in bebidasFrias) {
            await guardarProducto(
              codigo: bebida['codigo'] as String,
              nombre: bebida['nombre'] as String,
              categoria: 'Bebidas Frías',
              costo: bebida['costo'] as double,
              precio: bebida['precio'] as double,
              emoji: '🥤',
            );
          }

          // ==========================================================
          // SNACKS
          // ==========================================================

          const snacks = <Map<String, dynamic>>[
            {
              'codigo': 'SNK001',
              'nombre': 'Croissant',
              'costo': 2.00,
              'precio': 5.00,
            },
            {
              'codigo': 'SNK002',
              'nombre': 'Triple Mixto',
              'costo': 3.00,
              'precio': 8.00,
            },
            {
              'codigo': 'SNK003',
              'nombre': 'Croissant de Jamón y Queso',
              'costo': 3.00,
              'precio': 8.00,
            },
            {
              'codigo': 'SNK004',
              'nombre': 'Croissant de Pollo',
              'costo': 4.00,
              'precio': 10.00,
            },
            {
              'codigo': 'SNK005',
              'nombre': 'Empanada de Carne',
              'costo': 2.50,
              'precio': 6.00,
            },
            {
              'codigo': 'SNK006',
              'nombre': 'Empanada de Pollo',
              'costo': 2.50,
              'precio': 6.00,
            },
            {
              'codigo': 'SNK007',
              'nombre': 'Empanada Mixta',
              'costo': 2.50,
              'precio': 6.00,
            },
            {
              'codigo': 'SNK008',
              'nombre': 'Sándwich de Chorizo',
              'costo': 3.00,
              'precio': 7.00,
            },
            {
              'codigo': 'SNK009',
              'nombre': 'Sándwich de Pollo',
              'costo': 3.00,
              'precio': 7.00,
            },
            {
              'codigo': 'SNK010',
              'nombre': 'Sándwich de Filete de Pechuga',
              'costo': 5.00,
              'precio': 10.00,
            },
          ];

          for (final snack in snacks) {
            await guardarProducto(
              codigo: snack['codigo'] as String,
              nombre: snack['nombre'] as String,
              categoria: 'Snacks',
              costo: snack['costo'] as double,
              precio: snack['precio'] as double,
              emoji: '🥐',
            );
          }

          // ==========================================================
          // HAMBURGUESAS
          // ==========================================================

          await guardarProducto(
            codigo: 'HAM001',
            nombre: 'Hamburguesa Clásica',
            categoria: 'Hamburguesas',
            costo: 4.20,
            precio: 9.00,
            emoji: '🍔',
          );

          await guardarProducto(
            codigo: 'HAM002',
            nombre: 'Hamburguesa con Queso',
            categoria: 'Hamburguesas',
            costo: 5.50,
            precio: 10.00,
            emoji: '🍔',
          );

          await guardarProducto(
            codigo: 'HAM003',
            nombre: 'Hamburguesa Royal',
            categoria: 'Hamburguesas',
            costo: 6.20,
            precio: 12.00,
            emoji: '🍔',
          );

          // ==========================================================
          // POSTRES
          // ==========================================================

          const postres = <Map<String, dynamic>>[
            {
              'codigo': 'POS001',
              'nombre': 'Gelatina',
              'costo': 1.50,
              'precio': 3.00,
            },
            {
              'codigo': 'POS002',
              'nombre': 'Flan',
              'costo': 1.80,
              'precio': 3.00,
            },
            {
              'codigo': 'POS003',
              'nombre': 'Gelatina con Flan',
              'costo': 2.80,
              'precio': 4.00,
            },
            {
              'codigo': 'POS004',
              'nombre': 'Queque de Naranja',
              'costo': 2.50,
              'precio': 5.00,
            },
            {
              'codigo': 'POS005',
              'nombre': 'Pastel de Acelga',
              'costo': 4.50,
              'precio': 7.00,
            },
            {
              'codigo': 'POS006',
              'nombre': 'Pie de Manzana',
              'costo': 4.00,
              'precio': 7.00,
            },
            {
              'codigo': 'POS007',
              'nombre': 'Cheesecake de Maracuyá',
              'costo': 5.50,
              'precio': 8.00,
            },
            {
              'codigo': 'POS008',
              'nombre': 'Pie de Limón',
              'costo': 5.00,
              'precio': 8.00,
            },
            {
              'codigo': 'POS009',
              'nombre': 'Carrot Cake',
              'costo': 5.00,
              'precio': 8.00,
            },
            {
              'codigo': 'POS010',
              'nombre': 'Cheesecake de Fresa',
              'costo': 5.80,
              'precio': 9.00,
            },
            {
              'codigo': 'POS011',
              'nombre': 'Ensalada de Frutas',
              'costo': 6.00,
              'precio': 10.00,
            },
            {
              'codigo': 'POS012',
              'nombre': 'Galletas de Avena',
              'costo': 2.00,
              'precio': 5.00,
            },
            {
              'codigo': 'POS013',
              'nombre': 'Galletas de Choco Chips',
              'costo': 2.20,
              'precio': 5.00,
            },
            {
              'codigo': 'POS014',
              'nombre': 'Waffle Clásico',
              'costo': 4.00,
              'precio': 8.00,
            },
            {
              'codigo': 'POS015',
              'nombre': 'Waffle con Caramelo o Miel',
              'costo': 5.00,
              'precio': 10.00,
            },
            {
              'codigo': 'POS016',
              'nombre': 'Waffle Especial Estación Azul',
              'costo': 6.50,
              'precio': 13.00,
            },
          ];

          for (final postre in postres) {
            await guardarProducto(
              codigo: postre['codigo'] as String,
              nombre: postre['nombre'] as String,
              categoria: 'Postres',
              costo: postre['costo'] as double,
              precio: postre['precio'] as double,
              emoji: '🍰',
            );
          }

          // ==========================================================
          // COMBOS
          // ==========================================================

          await guardarProducto(
            codigo: 'COM001',
            nombre: 'Combo Tradición',
            categoria: 'Combos',
            costo: 7.00,
            precio: 12.00,
            emoji: '☕',
            descripcion: 'Café americano + empanada de carne',
          );

          await guardarProducto(
            codigo: 'COM002',
            nombre: 'Combo Express',
            categoria: 'Combos',
            costo: 7.00,
            precio: 13.00,
            emoji: '🍔',
            descripcion: 'Hamburguesa clásica + gaseosa',
          );

          await guardarProducto(
            codigo: 'COM003',
            nombre: 'Desayuno Azul',
            categoria: 'Combos',
            costo: 10.00,
            precio: 14.00,
            emoji: '🌅',
            descripcion: 'Café americano + sándwich mixto',
          );

          await guardarProducto(
            codigo: 'COM004',
            nombre: 'Combo Fresco',
            categoria: 'Combos',
            costo: 8.50,
            precio: 15.00,
            emoji: '🥤',
            descripcion:
            'Jugo de piña o papaya + azúcar o sin azúcar + sándwich de pollo + papas al hilo',
          );

          await guardarProducto(
            codigo: 'COM005',
            nombre: 'Combo Café Premium',
            categoria: 'Combos',
            costo: 11.50,
            precio: 18.00,
            emoji: '☕',
            descripcion:
            'Cappuccino + croissant de pollo + papas al hilo',
          );

          // ==========================================================
          // GASEOSAS, AGUAS Y OTRAS BEBIDAS
          // ==========================================================

          const gaseosas = <Map<String, dynamic>>[
            {
              'codigo': 'GA001',
              'nombre': 'Coca-Cola 350 ml Vidrio',
              'costo': 1.50,
              'precio': 3.00,
            },
            {
              'codigo': 'GA002',
              'nombre': 'Inca Kola 350 ml Vidrio',
              'costo': 1.50,
              'precio': 3.00,
            },
            {
              'codigo': 'GA003',
              'nombre': 'Sprite 350 ml Vidrio',
              'costo': 1.50,
              'precio': 3.00,
            },
            {
              'codigo': 'GA004',
              'nombre': 'Fanta 350 ml Vidrio',
              'costo': 1.50,
              'precio': 3.00,
            },
            {
              'codigo': 'GA005',
              'nombre': 'Coca-Cola 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA006',
              'nombre': 'Coca-Cola Zero 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA007',
              'nombre': 'Inca Kola 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA008',
              'nombre': 'Inca Kola Zero 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA009',
              'nombre': 'Sprite 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA010',
              'nombre': 'Fanta Naranja 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA011',
              'nombre': 'Fanta Roja 500 ml',
              'costo': 2.50,
              'precio': 4.00,
            },
            {
              'codigo': 'GA012',
              'nombre': 'Inca Kola Gordita 700 ml Vidrio',
              'costo': 3.00,
              'precio': 5.00,
            },
            {
              'codigo': 'GA013',
              'nombre': 'San Mateo Sin Gas Personal',
              'costo': 1.20,
              'precio': 3.00,
            },
            {
              'codigo': 'GA014',
              'nombre': 'San Mateo Con Gas Personal',
              'costo': 1.20,
              'precio': 3.00,
            },
            {
              'codigo': 'GA015',
              'nombre': 'Cielo Personal',
              'costo': 0.70,
              'precio': 2.00,
            },
            {
              'codigo': 'GA016',
              'nombre': 'Cielo 1 L',
              'costo': 1.50,
              'precio': 3.50,
            },
            {
              'codigo': 'GA017',
              'nombre': 'Cielo 2.5 L',
              'costo': 2.40,
              'precio': 4.00,
            },
            {
              'codigo': 'GA018',
              'nombre': 'Sporade',
              'costo': 1.20,
              'precio': 3.00,
            },
            {
              'codigo': 'GA019',
              'nombre': 'Frugos Cajita',
              'costo': 1.20,
              'precio': 2.50,
            },
            {
              'codigo': 'GA020',
              'nombre': 'Frugos Botella',
              'costo': 2.10,
              'precio': 3.00,
            },
            {
              'codigo': 'GA021',
              'nombre': 'Gatorade',
              'costo': 1.40,
              'precio': 3.00,
            },
          ];

          for (final bebida in gaseosas) {
            await guardarProducto(
              codigo: bebida['codigo'] as String,
              nombre: bebida['nombre'] as String,
              categoria: 'Gaseosas y Aguas',
              costo: bebida['costo'] as double,
              precio: bebida['precio'] as double,
              emoji: '🥤',
            );
          }
        }

        // ============================================================
        // MIGRACIÓN 33
        // PRESERVACIÓN DE RECETAS EXISTENTES
        // ============================================================
        // No borrar recetas ni detalles automáticamente: pueden contener
        // fórmulas personalizadas. Cualquier limpieza requiere auditoría y
        // una migración explícita que conserve las referencias válidas.
        // ============================================================
        if (from < 34) {
          // Preservamos las recetas y sus detalles existentes. Borrarlos
          // todos durante una actualización puede destruir fórmulas
          // personalizadas e historial operativo. Las correcciones de recetas
          // deben aplicarse mediante una migración específica y no destructiva.
        }

        // ==========================================================
        // MIGRACIÓN 35
        // CLASIFICACIÓN CORRECTA DEL INVENTARIO
        //
        // Por defecto la tabla Productos usa "receta".
        // En el catálogo actual solo los productos que realmente
        // tienen receta deben quedar como "receta".
        // El resto se maneja como producto de venta directa.
        // ==========================================================

        if (from < 35) {
          // No sobrescribimos masivamente el tipo de inventario de todos
          // los productos durante una actualización. Solo corregimos los
          // códigos conocidos que requieren control por receta.
          // los productos que actualmente tienen receta.
          await (update(productos)
            ..where(
                  (p) => p.codigo.isIn([
                'CAF001',
                'CAF002',
                'CAF003',
                'CAF004',
                'CAF005',
                'CAF006',
                'CAF007',
                'CAF008',
                'CAF009',
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
              ]),
            ))
              .write(
            const ProductosCompanion(
              tipoInventario: Value('receta'),
            ),
          );
        }
      }
    },
  );
}

LazyDatabase _openConnection(String? databasePath) {
  return LazyDatabase(() async {
    final file = databasePath != null
        ? File(databasePath)
        : File(
            p.join(
              (await getApplicationDocumentsDirectory()).path,
              'azul_os.db',
            ),
          );

    return NativeDatabase(file);
  });
}
