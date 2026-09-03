import 'package:flutter/foundation.dart';

import '../models/venta.dart';

class VentasService extends ChangeNotifier {
  final List<Venta> _ventas = [];

  List<Venta> get ventas => List.unmodifiable(_ventas);

  void registrarVenta(Venta venta) {
    _ventas.add(venta);
    notifyListeners();
  }

  double get totalVentasHoy {
    final hoy = DateTime.now();

    return _ventas
        .where(
          (v) =>
              v.fecha.year == hoy.year &&
              v.fecha.month == hoy.month &&
              v.fecha.day == hoy.day,
        )
        .fold(0.0, (total, venta) => total + venta.total);
  }

  int get cantidadVentasHoy {
    final hoy = DateTime.now();

    return _ventas
        .where(
          (v) =>
              v.fecha.year == hoy.year &&
              v.fecha.month == hoy.month &&
              v.fecha.day == hoy.day,
        )
        .length;
  }

  void limpiarVentas() {
    _ventas.clear();
    notifyListeners();
  }
}
