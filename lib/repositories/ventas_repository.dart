import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../database/dao/ventas_dao.dart';

import '../models/venta.dart' as model;
import '../models/item_carrito.dart';
import '../models/dashboard_resumen.dart';

import '../repositories/producto_repository.dart';

class VentasRepository {
  final VentasDao _dao;
  final ProductoRepository _productoRepository;

  VentasRepository(AppDatabase database)
      : _dao = VentasDao(database),
        _productoRepository = ProductoRepository(database);

  // ==========================================================
  // GUARDAR VENTA COMPLETA
  //
  // Método normal.
  //
  // Mantiene la compatibilidad con las partes del sistema que
  // necesiten guardar una venta de forma independiente.
  // ==========================================================

  Future<int> guardarVenta(model.Venta venta) async {
    final ventaCompanion = _crearVentaCompanion(venta);

    final detalles = venta.items
        .map(_crearDetalle)
        .toList();

    return _dao.guardarVentaCompleta(
      venta: ventaCompanion,
      detalles: detalles,
    );
  }

  // ==========================================================
  // GUARDAR VENTA SIN TRANSACCIÓN
  //
  // IMPORTANTE:
  //
  // Este método NO abre una transacción.
  //
  // Será utilizado posteriormente por CobroService dentro de
  // una única transacción que incluirá:
  //
  // VENTA
  // +
  // DETALLES
  // +
  // STOCK
  // +
  // KARDEX
  //
  // Si cualquier parte falla, todo podrá revertirse.
  // ==========================================================

  Future<int> guardarVentaSinTransaccion(
      model.Venta venta,
      ) async {
    final ventaCompanion = _crearVentaCompanion(venta);

    final detalles = venta.items
        .map(_crearDetalle)
        .toList();

    return _dao.guardarVentaCompletaSinTransaccion(
      venta: ventaCompanion,
      detalles: detalles,
    );
  }

  // ==========================================================
  // CREAR COMPANION DE VENTA
  // ==========================================================

  VentasCompanion _crearVentaCompanion(
      model.Venta venta,
      ) {
    return VentasCompanion.insert(
      numero: venta.numero,
      fecha: Value(venta.fecha),
      tipoDocumento: Value(venta.tipoDocumento),
      dni: Value(venta.dni),
      ruc: Value(venta.ruc),
      nombreCliente: Value(venta.nombreCliente),
      razonSocial: Value(venta.razonSocial),
      direccionFiscal: Value(venta.direccionFiscal),
      subtotal: Value(venta.subtotal),
      igv: Value(venta.igv),
      descuento: Value(venta.descuento),
      total: Value(venta.total),
      metodoPago: Value(venta.metodoPago),
      observaciones: Value(venta.observaciones),
    );
  }

  // ==========================================================
  // CONVERTIR ITEM -> DETALLE SQLITE
  // ==========================================================

  DetalleVentasCompanion _crearDetalle(
      ItemCarrito item,
      ) {
    return DetalleVentasCompanion.insert(
      ventaId: 0,
      productoId: item.producto.id!,
      nombreProducto: item.producto.nombre,
      cantidad: Value(item.cantidad),
      precioUnitario: Value(item.precioUnitario),
      subtotal: Value(item.subtotal),
      tamano: Value(item.tamano),
      tipoLeche: Value(item.tipoLeche),
      endulzante: Value(item.endulzante),
      infusion: Value(item.infusion),
      extraShot: Value(item.extraShot),
      observaciones: Value(item.observaciones),
    );
  }

  // ==========================================================
  // CONVERTIR DETALLE SQLITE -> ITEM CARRITO
  // ==========================================================

  Future<ItemCarrito?> _crearItemDesdeDetalle(
      dynamic detalle,
      ) async {
    final producto =
    await _productoRepository.obtenerPorId(
      detalle.productoId,
    );

    if (producto == null) {
      debugPrint(
        '⚠️ No se encontró el producto '
            '${detalle.productoId} para la reimpresión.',
      );

      return null;
    }

    return ItemCarrito(
      producto: producto,
      cantidad: detalle.cantidad,
      tamano: detalle.tamano,
      tipoLeche: detalle.tipoLeche,
      endulzante: detalle.endulzante,
      infusion: detalle.infusion,
      extraShot: detalle.extraShot,
      observaciones: detalle.observaciones,
    );
  }

  // ==========================================================
  // CONVERTIR VENTA DB -> MODELO COMPLETO
  // ==========================================================

  Future<model.Venta> _crearVentaCompleta(
      dynamic venta,
      ) async {
    final detalles =
    await _dao.obtenerDetalleVenta(venta.id);

    final items = <ItemCarrito>[];

    for (final detalle in detalles) {
      final item =
      await _crearItemDesdeDetalle(detalle);

      if (item != null) {
        items.add(item);
      }
    }

    return model.Venta(
      numero: venta.numero,
      fecha: venta.fecha,
      items: items,
      subtotal: venta.subtotal,
      igv: venta.igv,
      total: venta.total,
      metodoPago: venta.metodoPago,
      tipoDocumento: venta.tipoDocumento,
      dni: venta.dni,
      ruc: venta.ruc,
      nombreCliente: venta.nombreCliente,
      razonSocial: venta.razonSocial,
      direccionFiscal: venta.direccionFiscal,
      descuento: venta.descuento,
      observaciones: venta.observaciones,
    );
  }

  // ==========================================================
  // CONSULTAS
  // ==========================================================

  Future<List<model.Venta>> obtenerVentas() async {
    final ventasDb =
    await _dao.obtenerVentas();

    final ventas = <model.Venta>[];

    for (final venta in ventasDb) {
      final ventaCompleta =
      await _crearVentaCompleta(venta);

      ventas.add(ventaCompleta);
    }

    return ventas;
  }

  // ==========================================================
  // OBTENER UNA VENTA COMPLETA
  // ==========================================================

  Future<model.Venta?> obtenerVenta(
      int id,
      ) async {
    final ventaDb =
    await _dao.obtenerVenta(id);

    if (ventaDb == null) {
      return null;
    }

    return _crearVentaCompleta(ventaDb);
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  Future<double> obtenerTotalVentasHoy() async {
    final ventas =
    await obtenerVentas();

    final hoy = DateTime.now();

    final ventasHoy = ventas.where(
          (v) =>
      v.fecha.year == hoy.year &&
          v.fecha.month == hoy.month &&
          v.fecha.day == hoy.day,
    );

    return ventasHoy.fold<double>(
      0.0,
          (total, venta) => total + venta.total,
    );
  }

  Future<int> obtenerCantidadVentasHoy() async {
    final ventas =
    await obtenerVentas();

    final hoy = DateTime.now();

    return ventas.where(
          (v) =>
      v.fecha.year == hoy.year &&
          v.fecha.month == hoy.month &&
          v.fecha.day == hoy.day,
    ).length;
  }

  Future<int> obtenerCantidadClientesHoy() async {
    final ventas =
    await obtenerVentas();

    final hoy = DateTime.now();

    return ventas
        .where(
          (v) =>
      v.fecha.year == hoy.year &&
          v.fecha.month == hoy.month &&
          v.fecha.day == hoy.day,
    )
        .map(
          (v) =>
      v.nombreCliente ??
          'Cliente General',
    )
        .toSet()
        .length;
  }

  Future<DashboardResumen>
  obtenerResumenDashboard() async {
    final ventas = await obtenerVentas();

    final ahora = DateTime.now();

    final ventasHoy = ventas.where(
          (venta) =>
      venta.fecha.year == ahora.year &&
          venta.fecha.month == ahora.month &&
          venta.fecha.day == ahora.day,
    ).toList();

    final ventasMes = ventas.where(
          (venta) =>
      venta.fecha.year == ahora.year &&
          venta.fecha.month == ahora.month,
    ).toList();

    final clientesHoy = ventasHoy
        .map(
          (venta) =>
      venta.nombreCliente?.trim() ??
          'Cliente General',
    )
        .where((nombre) => nombre.isNotEmpty)
        .toSet()
        .length;

    final clientesMes = ventasMes
        .map(
          (venta) =>
      venta.nombreCliente?.trim() ??
          'Cliente General',
    )
        .where((nombre) => nombre.isNotEmpty)
        .toSet()
        .length;

    return DashboardResumen(
      ventasHoy: ventasHoy.fold<double>(
        0.0,
            (total, venta) => total + venta.total,
      ),

      ventasMes: ventasMes.fold<double>(
        0.0,
            (total, venta) => total + venta.total,
      ),

      ticketsHoy: ventasHoy.length,

      ticketsMes: ventasMes.length,

      clientesHoy: clientesHoy,

      clientesMes: clientesMes,

      alertas: 0,
    );
  }

  // ==========================================================
  // SIGUIENTE NÚMERO DE VENTA
  // ==========================================================

  Future<String> obtenerSiguienteNumeroVenta() async {
    final ultimoNumero =
    await _dao.obtenerUltimoNumeroVenta();

    if (ultimoNumero == null) {
      return 'V000001';
    }

    final numero = int.tryParse(
      ultimoNumero.replaceAll('V', ''),
    ) ??
        0;

    final siguiente = numero + 1;

    return 'V${siguiente.toString().padLeft(6, '0')}';
  }
}