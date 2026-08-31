import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../../database/app_database.dart';

import '../../models/item_carrito.dart';
import '../data/ubicaciones_pedido_data.dart';
import '../models/estado_pedido.dart';
import '../models/pedido_abierto.dart';
import '../models/ubicacion_pedido.dart';

class PedidosService extends ChangeNotifier {
  final AppDatabase database;

  PedidosService(this.database);
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

  Future<PedidoAbierto> abrirPedido(
      UbicacionPedido ubicacion,
      ) async {
    final existente = _pedidos[ubicacion.id];

    if (existente != null) {
      return existente;
    }

    final ahora = DateTime.now();

    final numeroPedido = await _obtenerSiguienteNumeroPedido();

    final numero =
        'P${numeroPedido.toString().padLeft(6, '0')}';

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

  /// Agrega productos al pedido.
  ///
  /// Si el producto con la misma configuración ya existe,
  /// aumenta su cantidad en lugar de crear otra línea.
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

    for (final nuevoItem in items) {
      final indiceExistente = pedido.items.indexWhere(
            (itemExistente) =>
        _claveItem(itemExistente) == _claveItem(nuevoItem),
      );

      if (indiceExistente >= 0) {
        pedido.items[indiceExistente].cantidad +=
            nuevoItem.cantidad;
      } else {
        pedido.agregarItems([nuevoItem]);
      }
    }

    if (pedido.estado == EstadoPedido.enviado) {
      pedido.estado = EstadoPedido.abierto;
    }

    notifyListeners();
  }

  /// Aumenta en una unidad la cantidad de un producto.
  void aumentarCantidad(
      String ubicacionId,
      ItemCarrito item,
      ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return;
    }

    if (pedido.estado == EstadoPedido.esperandoCuenta ||
        pedido.estado == EstadoPedido.cerrado) {
      return;
    }

    final indice = pedido.items.indexWhere(
          (itemExistente) =>
      _claveItem(itemExistente) == _claveItem(item),
    );

    if (indice == -1) {
      return;
    }

    pedido.items[indice].cantidad++;

    if (pedido.estado == EstadoPedido.enviado) {
      pedido.estado = EstadoPedido.abierto;
    }

    notifyListeners();
  }

  /// Disminuye en una unidad la cantidad de un producto.
  ///
  /// IMPORTANTE:
  /// Si parte de la cantidad ya fue enviada a preparación,
  /// nunca permite bajar por debajo de esa cantidad.
  bool disminuirCantidad(
      String ubicacionId,
      ItemCarrito item,
      ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return false;
    }

    if (pedido.estado == EstadoPedido.esperandoCuenta ||
        pedido.estado == EstadoPedido.cerrado) {
      return false;
    }

    final indice = pedido.items.indexWhere(
          (itemExistente) =>
      _claveItem(itemExistente) == _claveItem(item),
    );

    if (indice == -1) {
      return false;
    }

    final itemActual = pedido.items[indice];

    final cantidadesComandadas =
        _cantidadesComandadas[ubicacionId] ?? {};

    final cantidadEnviada =
        cantidadesComandadas[_claveItem(itemActual)] ?? 0;

    // No podemos reducir una cantidad que ya fue
    // enviada a preparación.
    if (itemActual.cantidad <= cantidadEnviada) {
      return false;
    }

    itemActual.cantidad--;

    // Si llegó a cero, eliminamos la línea.
    if (itemActual.cantidad <= 0) {
      pedido.items.removeAt(indice);
    }

    notifyListeners();

    return true;
  }

  /// Elimina completamente un producto del pedido.
  ///
  /// Solo se permite eliminarlo si todavía NO fue enviado
  /// a preparación.
  bool eliminarItem(
      String ubicacionId,
      ItemCarrito item,
      ) {
    final pedido = _pedidos[ubicacionId];

    if (pedido == null) {
      return false;
    }

    if (pedido.estado == EstadoPedido.esperandoCuenta ||
        pedido.estado == EstadoPedido.cerrado) {
      return false;
    }

    final indice = pedido.items.indexWhere(
          (itemExistente) =>
      _claveItem(itemExistente) == _claveItem(item),
    );

    if (indice == -1) {
      return false;
    }

    final itemActual = pedido.items[indice];

    final cantidadesComandadas =
        _cantidadesComandadas[ubicacionId] ?? {};

    final cantidadEnviada =
        cantidadesComandadas[_claveItem(itemActual)] ?? 0;

    // Si ya fue enviado a cocina, no permitimos
    // eliminarlo completamente.
    if (cantidadEnviada > 0) {
      return false;
    }

    pedido.items.removeAt(indice);

    notifyListeners();

    return true;
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

  /// Marca como enviados a preparación los productos
  /// que existen actualmente en el pedido.
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

  Future<int> _obtenerSiguienteNumeroPedido() async {
    return database.transaction(() async {
      final consulta = database.select(database.correlativos)
        ..where((t) => t.clave.equals('pedido'));

      final existente = await consulta.getSingleOrNull();

      if (existente == null) {
        await database.into(database.correlativos).insert(
          CorrelativosCompanion.insert(
            clave: 'pedido',
            ultimoNumero: const Value(1),
          ),
        );

        return 1;
      }

      final siguiente = existente.ultimoNumero + 1;

      await (database.update(database.correlativos)
        ..where((t) => t.clave.equals('pedido')))
          .write(
        CorrelativosCompanion(
          ultimoNumero: Value(siguiente),
        ),
      );

      return siguiente;
    });
  }
}