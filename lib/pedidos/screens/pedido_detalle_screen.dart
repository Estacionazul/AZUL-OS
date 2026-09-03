import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/item_carrito.dart';
import '../../models/producto_model.dart';

import '../../services/carrito_service.dart';
import '../../services/cobro_service.dart';
import '../../services/printer_service.dart';
import '../../services/producto_service.dart';

import '../../widgets/dialogs/finalizar_venta_dialog.dart';
import '../../widgets/dialogs/variantes_producto_dialog.dart';

import '../models/estado_pedido.dart';
import '../models/pedido_abierto.dart';
import '../models/ubicacion_pedido.dart';

import '../printing/pedido_comanda_print_service.dart';
import '../services/pedidos_service.dart';

class PedidoDetalleScreen extends StatelessWidget {
  final UbicacionPedido ubicacion;

  const PedidoDetalleScreen({super.key, required this.ubicacion});

  @override
  Widget build(BuildContext context) {
    final pedidosService = context.watch<PedidosService>();

    final pedido = pedidosService.obtenerPedido(ubicacion.id);

    if (pedido == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ubicacion.nombre)),
        body: const Center(
          child: Text(
            'No existe un pedido abierto.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (pedido.estaVacio) {
          pedidosService.cancelarPedido(ubicacion.id);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          title: Text(
            ubicacion.nombre,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Center(
                child: Text(
                  pedido.numero,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _ProductosPedidoPanel(pedido: pedido)),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: _ResumenPedido(pedido: pedido)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// PRODUCTOS
// ==========================================================

class _ProductosPedidoPanel extends StatelessWidget {
  final PedidoAbierto pedido;

  const _ProductosPedidoPanel({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoService>().todosProductos;

    final puedeAgregar =
        pedido.estado != EstadoPedido.esperandoCuenta &&
        pedido.estado != EstadoPedido.cerrado;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AGREGAR PRODUCTOS',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 8),

            Text(
              puedeAgregar
                  ? 'Selecciona los productos para ${pedido.ubicacion.nombre}.'
                  : 'El pedido está esperando el pago.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: puedeAgregar
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 2.7,
                          ),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];

                        return _ProductoPedidoButton(
                          producto: producto,
                          onTap: () => _agregarProducto(context, producto),
                        );
                      },
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payments_rounded,
                            size: 55,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Pedido listo para cobrar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _agregarProducto(
    BuildContext context,
    ProductoModel producto,
  ) async {
    final pedidosService = context.read<PedidosService>();

    final requiereVariantes =
        (producto.categoriaId == 1 &&
            producto.nombre.toLowerCase() != 'espresso') ||
        producto.categoriaId == 2 ||
        producto.categoriaId == 5;

    Map<String, dynamic>? resultado;

    if (requiereVariantes) {
      resultado = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (_) => VariantesProductoDialog(producto: producto),
      );

      if (resultado == null) {
        return;
      }
    }

    final item = ItemCarrito(
      producto: producto,
      tamano: resultado?['tamano'],
      tipoLeche: resultado?['tipoLeche'],
      endulzante: resultado?['endulzante'],
      infusion: resultado?['infusion'],
      observaciones: resultado?['observaciones'],
      extraShot: resultado?['extraShot'] ?? false,
    );

    pedidosService.agregarProductos(pedido.ubicacion.id, [item]);
  }
}

// ==========================================================
// BOTÓN DE PRODUCTO
// ==========================================================

class _ProductoPedidoButton extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onTap;

  const _ProductoPedidoButton({required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        side: BorderSide(color: Colors.grey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline_rounded,
            color: Color(0xFF1565C0),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              producto.nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            'S/. ${producto.precioVenta.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// RESUMEN DEL PEDIDO
// ==========================================================

class _ResumenPedido extends StatelessWidget {
  final PedidoAbierto pedido;

  const _ResumenPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PedidosService>();

    final esperandoCuenta = pedido.estado == EstadoPedido.esperandoCuenta;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF1565C0),
                  size: 28,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'PEDIDO',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),

                Text(
                  '#${pedido.numeroComanda}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              pedido.ubicacion.nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            if (esperandoCuenta) ...[
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ESPERANDO CUENTA',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 30),

            Expanded(
              child: pedido.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no hay productos.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: pedido.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = pedido.items[index];

                        return _ItemPedidoRow(
                          item: item,
                          ubicacionId: pedido.ubicacion.id,
                        );
                      },
                    ),
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  'S/. ${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // ENVIAR COMANDA
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: pedido.estaVacio || esperandoCuenta
                    ? null
                    : () => _enviarComanda(context, service),
                icon: const Icon(Icons.print_rounded),
                label: const Text(
                  'ENVIAR COMANDA',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // SOLICITAR / COBRAR CUENTA
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: pedido.estaVacio
                    ? null
                    : esperandoCuenta
                    ? () => _cobrarCuenta(context)
                    : () => _solicitarCuenta(context, service),
                icon: Icon(
                  esperandoCuenta
                      ? Icons.payments_rounded
                      : Icons.receipt_long_rounded,
                ),
                label: Text(
                  esperandoCuenta ? 'COBRAR CUENTA' : 'SOLICITAR CUENTA',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: esperandoCuenta ? Colors.green : null,
                  foregroundColor: esperandoCuenta ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SOLICITAR CUENTA
  // ==========================================================

  void _solicitarCuenta(BuildContext context, PedidosService service) {
    service.pasarAEsperandoCuenta(pedido.ubicacion.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido enviado a espera de cuenta.')),
    );
  }

  // ==========================================================
  // COBRAR CUENTA
  // ==========================================================

  Future<void> _cobrarCuenta(BuildContext context) async {
    final carrito = context.read<CarritoService>();

    final cobro = context.read<CobroService>();

    final pedidosService = context.read<PedidosService>();

    // --------------------------------------------------------
    // CARGAR PEDIDO EN EL CARRITO
    // --------------------------------------------------------

    carrito.cargarItems(pedido.items);

    // --------------------------------------------------------
    // ABRIR DIÁLOGO DE COBRO
    // --------------------------------------------------------

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return FinalizarVentaDialog(
          total: pedido.total,
          onConfirmar: (metodoPago) async {
            try {
              // ------------------------------------------------
              // COBRAR
              // ------------------------------------------------

              await cobro.cobrar(metodoPago: metodoPago);

              // ------------------------------------------------
              // SOLO SI EL COBRO TERMINÓ CORRECTAMENTE
              // CERRAMOS EL PEDIDO
              // ------------------------------------------------

              pedidosService.cerrarPedido(pedido.ubicacion.id);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cuenta cobrada correctamente. Mesa liberada.'),
                  backgroundColor: Colors.green,
                ),
              );

              // ------------------------------------------------
              // VOLVER A LA PANTALLA DE MESAS
              // ------------------------------------------------

              Navigator.of(context).pop();
            } catch (e) {
              if (!context.mounted) {
                return;
              }

              final mensaje = e.toString().replaceFirst('Bad state: ', '');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text(mensaje)),
              );
            }
          },
        );
      },
    );
  }

  // ==========================================================
  // ENVIAR COMANDA
  // ==========================================================

  Future<void> _enviarComanda(
    BuildContext context,
    PedidosService service,
  ) async {
    final pendientes = service.obtenerItemsPendientesParaComanda(
      pedido.ubicacion.id,
    );

    if (pendientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos nuevos para enviar.')),
      );
      return;
    }

    try {
      final printerService = context.read<PrinterService>();

      final printService = PedidoComandaPrintService(
        printerService: printerService,
      );

      final numeroComanda = service.obtenerSiguienteNumeroComanda(
        pedido.ubicacion.id,
      );

      await printService.imprimir(
        pedido: pedido,
        items: pendientes,
        numeroComanda: numeroComanda,
      );

      service.marcarComandaEnviada(pedido.ubicacion.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comanda #$numeroComanda enviada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo imprimir la comanda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ==========================================================
// ITEM DEL PEDIDO
// ==========================================================

class _ItemPedidoRow extends StatelessWidget {
  final ItemCarrito item;
  final String ubicacionId;

  const _ItemPedidoRow({required this.item, required this.ubicacionId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<PedidosService>();

    final detalles = <String>[];

    if (item.tipoLeche != null && item.tipoLeche!.trim().isNotEmpty) {
      detalles.add('Leche: ${item.tipoLeche}');
    }

    if (item.endulzante != null && item.endulzante!.trim().isNotEmpty) {
      detalles.add('Endulzante: ${item.endulzante}');
    }

    if (item.infusion != null && item.infusion!.trim().isNotEmpty) {
      detalles.add('Infusión: ${item.infusion}');
    }

    if (item.extraShot) {
      detalles.add('Extra Shot');
    }

    if (item.observaciones != null && item.observaciones!.trim().isNotEmpty) {
      detalles.add('Obs: ${item.observaciones}');
    }

    void aumentar() {
      service.aumentarCantidad(ubicacionId, item);
    }

    void disminuir() {
      final pudoDisminuir = service.disminuirCantidad(ubicacionId, item);

      if (!pudoDisminuir) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede disminuir: esa cantidad ya fue enviada a cocina.',
            ),
          ),
        );
      }
    }

    void eliminar() {
      final pudoEliminar = service.eliminarItem(ubicacionId, item);

      if (!pudoEliminar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede eliminar: el producto ya fue enviado a cocina.',
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Disminuir',
                    onPressed: disminuir,
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    color: const Color(0xFF1565C0),
                    visualDensity: VisualDensity.compact,
                  ),

                  Text(
                    '${item.cantidad}x',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Aumentar',
                    onPressed: aumentar,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    color: const Color(0xFF1565C0),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                item.producto.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            Text(
              'S/. ${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),

            const SizedBox(width: 4),

            IconButton(
              tooltip: 'Eliminar producto',
              onPressed: eliminar,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red.shade600,
            ),
          ],
        ),

        if (detalles.isNotEmpty) ...[
          const SizedBox(height: 7),

          ...detalles.map(
            (detalle) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                detalle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
