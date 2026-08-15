import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'database/app_database.dart';
import 'repositories/producto_repository.dart';
import 'repositories/ventas_repository.dart';
import 'services/inventario_automatico_service.dart';
import 'services/disponibilidad_producto_service.dart';
import 'repositories/recetas_repository.dart';
import 'repositories/receta_detalle_repository.dart';
import 'repositories/clientes_repository.dart';
import 'repositories/insumo_repository.dart';
import 'screens/home_screen.dart';

import 'seed/datos_iniciales.dart';

import 'services/carrito_service.dart';
import 'services/cobro_service.dart';
import 'services/insumo_service.dart';
import 'services/inventario_service.dart';
import 'services/producto_service.dart';
import 'services/recetas_service.dart';
import 'services/receta_detalle_service.dart';
import 'services/venta_service.dart';
import 'services/ventas_service.dart';
import 'services/clientes_service.dart';
import 'repositories/movimiento_inventario_repository.dart';
import 'services/movimiento_inventario_service.dart';
import 'services/produccion_service.dart';
import 'services/printer_service.dart';
import 'services/ticket_print_service.dart';
import 'ticket/esc_pos_renderer.dart';
import 'printer/windows_printer_adapter.dart';
import 'screens/ventas/pos_screen.dart';
import 'screens/inventario/inventario_screen.dart';
import 'screens/ventas/ventas_screen.dart';
import 'repositories/empresa_repository.dart';
import 'services/empresa_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  await DatosIniciales(database).cargar();

  // ==========================================
  // IMPRESORA WINDOWS
  // ==========================================

  final printerAdapter = WindowsPrinterAdapter();

  print('');
  print('==============================================');
  print('        INICIALIZANDO IMPRESORA');
  print('              AZUL OS');
  print('==============================================');

  final printers = await printerAdapter.discoverPrinters();

  const nombreImpresora = 'POS-58-Series';

  if (printers.contains(nombreImpresora)) {
    await printerAdapter.selectPrinter(nombreImpresora);

    print('');
    print('✅ IMPRESORA AUTOMÁTICAMENTE SELECCIONADA');
    print('🖨️ $nombreImpresora');
  } else {
    print('');
    print('⚠️ NO SE ENCONTRÓ LA IMPRESORA:');
    print('🖨️ $nombreImpresora');
  }

  print('==============================================');
  print('');

  runApp(
    AzulOSApp(
      database: database,
      printerAdapter: printerAdapter,
    ),
  );
}

class AzulOSApp extends StatelessWidget {
  final AppDatabase database;
  final WindowsPrinterAdapter printerAdapter;

  const AzulOSApp({
    super.key,
    required this.database,
    required this.printerAdapter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(
          value: database,
        ),

        Provider(
          create: (_) => ProductoRepository(database),
        ),

        Provider(
          create: (_) => ClientesRepository(database),
        ),

        Provider(
          create: (_) => EmpresaRepository(database),
        ),

        ChangeNotifierProvider(
          create: (context) => ClientesService(
            context.read<ClientesRepository>(),
          ),
        ),

        Provider(
          create: (_) => EmpresaService(database),
        ),

        Provider(
          create: (_) => VentasRepository(database),
        ),

        Provider(
          create: (_) => RecetasRepository(database),
        ),

        Provider(
          create: (_) => RecetaDetalleRepository(
            database.recetaDetalleDao,
          ),
        ),

        Provider(
          create: (_) => InsumoRepository(database),
        ),

        Provider(
          create: (context) => DisponibilidadProductoService(
            recetasRepository: context.read<RecetasRepository>(),
            detalleRepository: context.read<RecetaDetalleRepository>(),
            insumoRepository: context.read<InsumoRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => ProductoService(
            context.read<ProductoRepository>(),
          )..cargarProductos(),
        ),

        ChangeNotifierProvider(
          create: (context) => RecetasService(
            context.read<RecetasRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => RecetaDetalleService(
            context.read<RecetaDetalleRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => CarritoService(),
        ),

        ChangeNotifierProvider(
          create: (_) => VentasService(),
        ),

        Provider(
          create: (_) => VentaService.instance,
        ),

        ChangeNotifierProvider(
          create: (_) => InsumoService(database)..obtenerTodos(),
        ),

        Provider(
          create: (_) => InventarioService(),
        ),

        Provider(
          create: (_) => MovimientoInventarioRepository(database),
        ),

        ChangeNotifierProvider(
          create: (context) => MovimientoInventarioService(
            repository:
            context.read<MovimientoInventarioRepository>(),
            productoRepository:
            context.read<ProductoRepository>(),
            insumoRepository:
            context.read<InsumoRepository>(),
            productoService:
            context.read<ProductoService>(),
            insumoService:
            context.read<InsumoService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => ProduccionService(
            productoService: context.read<ProductoService>(),
            insumoService: context.read<InsumoService>(),
            recetaDetalleService:
            context.read<RecetaDetalleService>(),
            movimientoService:
            context.read<MovimientoInventarioService>(),
          ),
        ),

        Provider(
          create: (context) => InventarioAutomaticoService(
            recetasRepository:
            context.read<RecetasRepository>(),
            productoService:
            context.read<ProductoService>(),
            insumoService:
            context.read<InsumoService>(),
            movimientoService:
            context.read<MovimientoInventarioService>(),
          ),
        ),

        // ==========================================
        // IMPRESORA
        // ==========================================

        Provider<WindowsPrinterAdapter>.value(
          value: printerAdapter,
        ),

        Provider(
          create: (context) => PrinterService(
            context.read<WindowsPrinterAdapter>(),
          ),
        ),

        Provider(
          create: (_) => const EscPosRenderer(),
        ),

        Provider(
          create: (_) => const TicketPrintService(),
        ),

        // ==========================================
        // COBRO
        // ==========================================

        ProxyProvider5<
            CarritoService,
            VentasService,
            VentaService,
            VentasRepository,
            InventarioAutomaticoService,
            CobroService>(
          update: (
              context,
              carrito,
              ventas,
              ventaService,
              ventasRepository,
              inventarioAutomaticoService,
              __,
              ) =>
              CobroService(
                carritoService: carrito,
                ventasService: ventas,
                ventaService: ventaService,
                ventasRepository: ventasRepository,
                inventarioAutomaticoService:
                inventarioAutomaticoService,

                ticketPrintService:
                context.read<TicketPrintService>(),

                escPosRenderer:
                context.read<EscPosRenderer>(),

                printerService:
                context.read<PrinterService>(),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AZUL OS',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}