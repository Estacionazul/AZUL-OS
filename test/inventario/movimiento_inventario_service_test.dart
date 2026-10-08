import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../lib/database/app_database.dart';
import '../../lib/models/insumo_model.dart';
import '../../lib/models/movimiento_inventario_model.dart';
import '../../lib/models/producto_model.dart';
import '../../lib/repositories/insumo_repository.dart';
import '../../lib/repositories/movimiento_inventario_repository.dart';
import '../../lib/repositories/producto_repository.dart';
import '../../lib/services/insumo_service.dart';
import '../../lib/services/movimiento_inventario_service.dart';
import '../../lib/services/producto_service.dart';

void main() {
  late Directory tempDirectory;
  late AppDatabase database;
  late ProductoRepository productoRepository;
  late InsumoRepository insumoRepository;
  late MovimientoInventarioRepository movimientoRepository;
  late ProductoService productoService;
  late InsumoService insumoService;
  late MovimientoInventarioService movimientoService;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'azul_os_stock_test_',
    );

    final databasePath =
        '${tempDirectory.path}${Platform.pathSeparator}stock_test.db';

    database = AppDatabase(databasePath: databasePath);

    productoRepository = ProductoRepository(database);
    insumoRepository = InsumoRepository(database);
    movimientoRepository = MovimientoInventarioRepository(database);

    productoService = ProductoService(productoRepository);
    insumoService = InsumoService(database);

    await productoService.cargarProductos();
    await insumoService.obtenerTodos();

    movimientoService = MovimientoInventarioService(
      repository: movimientoRepository,
      productoRepository: productoRepository,
      insumoRepository: insumoRepository,
      productoService: productoService,
      insumoService: insumoService,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test('entrada de insumo aumenta exactamente una vez y registra un movimiento', () async {
    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-001',
        nombre: 'Insumo de prueba',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 0,
        stockMinimo: 10,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    await movimientoService.registrarMovimiento(
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'ENTRADA',
        nombreItem: 'Insumo de prueba',
        emoji: '🧪',
        unidad: 'g',
        insumoId: insumoId,
        cantidad: 6,
        signo: 1,
        observacion: 'Compra',
      ),
    );

    final insumo = await insumoRepository.obtenerPorId(insumoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(insumo?.stock, 6);
    expect(
      movimientos.where((item) => item.insumoId == insumoId).length,
      1,
    );
  });

  test('movimiento sincroniza inmediatamente el stock de los servicios en memoria', () async {
    final productoId = await productoRepository.insertar(
      const ProductoModel(
        codigo: 'TEST-PRO-SYNC-001',
        codigoBarras: '',
        nombre: 'Producto sincronizado',
        descripcion: '',
        categoriaId: 1,
        costo: 1,
        precioVenta: 2,
        stock: 0,
        stockMinimo: 1,
        tipoInventario: 'producto',
        tipoAfectacionIgv: '10',
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-SYNC-001',
        nombre: 'Insumo sincronizado',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 0,
        stockMinimo: 1,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    await productoService.cargarProductos();
    await insumoService.obtenerTodos();

    await movimientoService.registrarMovimientos([
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'ENTRADA',
        nombreItem: 'Producto sincronizado',
        emoji: '🧪',
        unidad: 'unidad',
        productoId: productoId,
        cantidad: 5,
        signo: 1,
      ),
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'ENTRADA',
        nombreItem: 'Insumo sincronizado',
        emoji: '🧪',
        unidad: 'g',
        insumoId: insumoId,
        cantidad: 250,
        signo: 1,
      ),
    ]);

    expect(productoService.obtenerProducto(productoId)?.stock, 5);
    expect(insumoService.insumos.any(
      (item) => item.id == insumoId && item.stock == 250,
    ), isTrue);
  });

  test('ajuste por stock objetivo calcula la diferencia desde la BD', () async {
    final productoId = await productoRepository.insertar(
      const ProductoModel(
        codigo: 'TEST-PRO-AJUSTE-001',
        codigoBarras: '',
        nombre: 'Producto ajuste objetivo',
        descripcion: '',
        categoriaId: 1,
        costo: 1,
        precioVenta: 2,
        stock: 50,
        stockMinimo: 1,
        tipoInventario: 'producto',
        tipoAfectacionIgv: '10',
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    final producto = await productoRepository.obtenerPorId(productoId);
    expect(producto, isNotNull);

    // Simula una pantalla que tiene stock antiguo en memoria (50),
    // mientras la BD ya fue modificada a 60 por otra operación.
    await productoRepository.actualizar(
      ProductoModel(
        id: producto!.id,
        codigo: producto.codigo,
        codigoBarras: producto.codigoBarras,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        categoriaId: producto.categoriaId,
        costo: producto.costo,
        precioVenta: producto.precioVenta,
        stock: 60,
        stockMinimo: producto.stockMinimo,
        tipoInventario: producto.tipoInventario,
        tipoAfectacionIgv: producto.tipoAfectacionIgv,
        emoji: producto.emoji,
        imagen: producto.imagen,
        activo: producto.activo,
      ),
    );

    await movimientoService.ajustarStockProductoA(
      producto: producto,
      nuevoStock: 5,
      motivo: 'Regularización de stock inicial',
    );

    final actualizado = await productoRepository.obtenerPorId(productoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(actualizado?.stock, 5);

    final propios = movimientos
        .where((item) => item.productoId == productoId)
        .toList();

    expect(propios.length, 1);
    expect(propios.single.tipo, 'AJUSTE_SALIDA');
    expect(propios.single.cantidad, 55);
    expect(propios.single.signo, -1);
  });

  test('ajuste por stock objetivo también puede aumentar el saldo', () async {
    final productoId = await productoRepository.insertar(
      const ProductoModel(
        codigo: 'TEST-PRO-AJUSTE-002',
        codigoBarras: '',
        nombre: 'Producto ajuste entrada',
        descripcion: '',
        categoriaId: 1,
        costo: 1,
        precioVenta: 2,
        stock: 5,
        stockMinimo: 1,
        tipoInventario: 'producto',
        tipoAfectacionIgv: '10',
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    final producto = await productoRepository.obtenerPorId(productoId);
    expect(producto, isNotNull);

    await movimientoService.ajustarStockProductoA(
      producto: producto!,
      nuevoStock: 7,
      motivo: 'Conteo físico',
    );

    final actualizado = await productoRepository.obtenerPorId(productoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(actualizado?.stock, 7);

    final propios = movimientos
        .where((item) => item.productoId == productoId)
        .toList();

    expect(propios.length, 1);
    expect(propios.single.tipo, 'AJUSTE_ENTRADA');
    expect(propios.single.cantidad, 2);
    expect(propios.single.signo, 1);
  });

  test('ajuste de insumo por stock objetivo calcula la diferencia desde la BD', () async {
    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-AJUSTE-001',
        nombre: 'Insumo ajuste objetivo',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 100,
        stockMinimo: 10,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    final insumo = await insumoRepository.obtenerPorId(insumoId);
    expect(insumo, isNotNull);

    await insumoRepository.actualizar(
      InsumoModel(
        id: insumo!.id,
        codigo: insumo.codigo,
        nombre: insumo.nombre,
        descripcion: insumo.descripcion,
        categoriaId: insumo.categoriaId,
        unidadMedida: insumo.unidadMedida,
        stock: 140,
        stockMinimo: insumo.stockMinimo,
        costoCompra: insumo.costoCompra,
        proveedorId: insumo.proveedorId,
        emoji: insumo.emoji,
        imagen: insumo.imagen,
        activo: insumo.activo,
      ),
    );

    await movimientoService.ajustarStockInsumoA(
      insumo: insumo,
      nuevoStock: 75,
      motivo: 'Conteo físico',
    );

    final actualizado = await insumoRepository.obtenerPorId(insumoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(actualizado?.stock, 75);

    final propios = movimientos
        .where((item) => item.insumoId == insumoId)
        .toList();

    expect(propios.length, 1);
    expect(propios.single.tipo, 'AJUSTE_SALIDA');
    expect(propios.single.cantidad, 65);
    expect(propios.single.signo, -1);
  });

  test('dos entradas independientes acumulan sin duplicar una operación', () async {
    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-002',
        nombre: 'Insumo acumulativo',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 0,
        stockMinimo: 10,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    Future<void> entrada(double cantidad) {
      return movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime(2026, 10, 4),
          tipo: 'ENTRADA',
          nombreItem: 'Insumo acumulativo',
          emoji: '🧪',
          unidad: 'g',
          insumoId: insumoId,
          cantidad: cantidad,
          signo: 1,
        ),
      );
    }

    await entrada(6);
    await entrada(6);

    final insumo = await insumoRepository.obtenerPorId(insumoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(insumo?.stock, 12);
    expect(
      movimientos.where((item) => item.insumoId == insumoId).length,
      2,
    );
  });

  test('ajuste de salida descuenta exactamente la cantidad solicitada', () async {
    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-003',
        nombre: 'Insumo ajustable',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 12,
        stockMinimo: 10,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    await movimientoService.registrarMovimiento(
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'AJUSTE_SALIDA',
        nombreItem: 'Insumo ajustable',
        emoji: '🧪',
        unidad: 'g',
        insumoId: insumoId,
        cantidad: 6,
        signo: -1,
        observacion: 'Merma',
      ),
    );

    final insumo = await insumoRepository.obtenerPorId(insumoId);

    expect(insumo?.stock, 6);
  });

  test('no permite una salida mayor al stock y no registra movimiento', () async {
    final insumoId = await insumoRepository.insertar(
      const InsumoModel(
        codigo: 'TEST-INS-004',
        nombre: 'Insumo insuficiente',
        descripcion: '',
        categoriaId: 1,
        unidadMedida: 'g',
        stock: 5,
        stockMinimo: 2,
        costoCompra: 1,
        proveedorId: null,
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    expect(
      () => movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime(2026, 10, 4),
          tipo: 'AJUSTE_SALIDA',
          nombreItem: 'Insumo insuficiente',
          emoji: '🧪',
          unidad: 'g',
          insumoId: insumoId,
          cantidad: 6,
          signo: -1,
        ),
      ),
      throwsStateError,
    );

    final insumo = await insumoRepository.obtenerPorId(insumoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(insumo?.stock, 5);
    expect(
      movimientos.where((item) => item.insumoId == insumoId).isEmpty,
      isTrue,
    );
  });

  test('producto físico acumula entrada y permite salida', () async {
    final productoId = await productoRepository.insertar(
      const ProductoModel(
        codigo: 'TEST-PRO-001',
        codigoBarras: '',
        nombre: 'Producto físico de prueba',
        descripcion: '',
        categoriaId: 1,
        costo: 1,
        precioVenta: 2,
        stock: 0,
        stockMinimo: 1,
        tipoInventario: 'producto',
        tipoAfectacionIgv: '10',
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    await movimientoService.registrarMovimiento(
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'ENTRADA',
        nombreItem: 'Producto físico de prueba',
        emoji: '🧪',
        unidad: 'unidad',
        productoId: productoId,
        cantidad: 6,
        signo: 1,
      ),
    );

    await movimientoService.registrarMovimiento(
      MovimientoInventarioModel(
        fecha: DateTime(2026, 10, 4),
        tipo: 'AJUSTE_SALIDA',
        nombreItem: 'Producto físico de prueba',
        emoji: '🧪',
        unidad: 'unidad',
        productoId: productoId,
        cantidad: 1,
        signo: -1,
      ),
    );

    final producto = await productoRepository.obtenerPorId(productoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(producto?.stock, 5);
    expect(
      movimientos.where((item) => item.productoId == productoId).length,
      2,
    );
  });

  test('producto receta no acepta entrada manual', () async {
    final productoId = await productoRepository.insertar(
      const ProductoModel(
        codigo: 'TEST-REC-001',
        codigoBarras: '',
        nombre: 'Receta de prueba',
        descripcion: '',
        categoriaId: 1,
        costo: 1,
        precioVenta: 2,
        stock: 0,
        stockMinimo: 1,
        tipoInventario: 'receta',
        tipoAfectacionIgv: '10',
        emoji: '🧪',
        imagen: '',
        activo: true,
      ),
    );

    expect(
      () => movimientoService.registrarMovimiento(
        MovimientoInventarioModel(
          fecha: DateTime(2026, 10, 4),
          tipo: 'ENTRADA',
          nombreItem: 'Receta de prueba',
          emoji: '🧪',
          unidad: 'unidad',
          productoId: productoId,
          cantidad: 1,
          signo: 1,
        ),
      ),
      throwsStateError,
    );

    final producto = await productoRepository.obtenerPorId(productoId);
    final movimientos = await movimientoRepository.obtenerTodos();

    expect(producto?.stock, 0);
    expect(
      movimientos.where((item) => item.productoId == productoId).isEmpty,
      isTrue,
    );
  });
}
