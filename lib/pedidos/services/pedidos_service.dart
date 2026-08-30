import 'package:flutter/foundation.dart';

import '../../models/item_carrito.dart';
import '../data/ubicaciones_pedido_data.dart';
import '../models/estado_pedido.dart';
import '../models/pedido_abierto.dart';
import '../models/ubicacion_pedido.dart';

class PedidosService extends ChangeNotifier {
  final Map<String, PedidoAbierto> _pedidos = {};

  /// Cantidades que ya fueron enviadas a preparación.
  ///
  /// La clave corresponde a la ubicación.
  /// Dentro se guarda:
  ///
  /// clave del producto/personalización -> cantidad impresa
  final Map<String, Map<String, int>> _cantidadesComandadas = {};

  List<UbicacionPedido> get ubicaciones =>
      UbicacionesPedidoData.todas;

  List<PedidoAbierto> get pedidos =>
      List.unmodifiable(_pedidos.values);

  PedidoAbierto? obtenerPedido(String ubicacionId) {
    return _pedidos[ubicacionId];
  }

  bool estaOcupada(String ubicacionId) {
    final pedido = _pedidos[ubicacionId];

    return pedido != null &&
        pedido.estado != EstadoPedido.cerrado &&
        pedido.items.isNotEmpty;
  }

  PedidoAbierto abrirPedido(
    UbicacionPedido ubicacion,
  ) {
    final existente = _pedidos[ubicacion.id];

    if (existente != null) {
      return existente;
    }

    final ahora = DateTime.now();

    final numero =
        'P${ahora.microsecondsSinceEpoch}';

    final pedido = PedidoAbierto(
      id: '${ubicacion.id}_${ahora.microsecondsSinceEpoch}',
      numero: numero,
      ubicacion: ubicacion,
      fechaApertura: ahora,
    );

    _pedidos[ubicacion.id] = pedido;

    _cantidadesComandadas[ubicacion.id] = {};

    notifyListeners();

    return pedido;
  }

  void agregarProductos(
    String ubicacionId,
    List<ItemCarrito> items,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      throw StateError(
        'No existe un pedido abierto para $ubicacionId.',
      );
    }

    if (pedido.estado == EstadoPedido.esperandoCuenta ||
        pedido.estado == EstadoPedido.cerrado) {
      throw StateError(
        'El pedido ya está cerrado para nuevos productos.',
      );
    }

    pedido.agregarItems(items);

    if (pedido.estado == EstadoPedido.enviado) {
      pedido.estado = EstadoPedido.abierto;
    }

    notifyListeners();
  }

  /// Devuelve SOLO los productos que todavía no fueron enviados
  /// a la impresora.
  List<ItemCarrito> obtenerItemsPendientesParaComanda(
    String ubicacionId,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null || pedido.estaVacio) {
      return [];
    }

    final cantidadesEnviadas =
        _cantidadesComandadas[ubicacionId] ?? {};

    final pendientes = <ItemCarrito>[];

    for (final item in pedido.items) {
      final clave = _claveItem(item);

      final enviados =
          cantidadesEnviadas[clave] ?? 0;

      final cantidadPendiente =
          item.cantidad - enviados;

      if (cantidadPendiente <= 0) {
        continue;
      }

      pendientes.add(
        ItemCarrito(
          producto: item.producto,
          cantidad: cantidadPendiente,
          tamano: item.tamano,
          tipoLeche: item.tipoLeche,
          endulzante: item.endulzante,
          infusion: item.infusion,
          extraShot: item.extraShot,
          observaciones: item.observaciones,
        ),
      );
    }

    return pendientes;
  }

  /// Marca como impresos los productos que existen actualmente
  /// en el pedido.
  void marcarComandaEnviada(
    String ubicacionId,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return;
    }

    final cantidades = <String, int>{};

    for (final item in pedido.items) {
      cantidades[_claveItem(item)] = item.cantidad;
    }

    _cantidadesComandadas[ubicacionId] = cantidades;

    pedido.numeroComanda++;
    pedido.estado = EstadoPedido.enviado;

    notifyListeners();
  }

  int obtenerSiguienteNumeroComanda(
    String ubicacionId,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return 1;
    }

    return pedido.numeroComanda + 1;
  }

  void pasarAEsperandoCuenta(
    String ubicacionId,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return;
    }

    if (pedido.estaVacio) {
      return;
    }

    pedido.estado =
        EstadoPedido.esperandoCuenta;

    notifyListeners();
  }

  void actualizarObservaciones(
    String ubicacionId,
    String observaciones,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return;
    }

    pedido.observaciones =
        observaciones.trim();

    notifyListeners();
  }

  void cerrarPedido(
    String ubicacionId,
  ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return;
    }

    pedido.estado =
        EstadoPedido.cerrado;

    _pedidos.remove(ubicacionId);
    _cantidadesComandadas.remove(ubicacionId);

    notifyListeners();
  }

  void cancelarPedido(
    String ubicacionId,
  ) {
    _pedidos.remove(ubicacionId);
    _cantidadesComandadas.remove(ubicacionId);

    notifyListeners();
  }

  bool get hayPedidosAbiertos =>
      _pedidos.isNotEmpty;

  String _claveItem(ItemCarrito item) {
    return [
      item.producto.codigo,
      item.tamano ?? '',
      item.tipoLeche ?? '',
      item.endulzante ?? '',
      item.infusion ?? '',
      item.extraShot.toString(),
      item.observaciones ?? '',
    ].join('|');
  }
}
