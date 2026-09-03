import 'package:flutter/foundation.dart';

import '../models/receta_detalle_model.dart';
import '../models/receta_model.dart';
import '../repositories/recetas_repository.dart';

class RecetasService extends ChangeNotifier {
  final RecetasRepository _repository;

  RecetasService(this._repository);

  List<RecetaModel> _recetas = [];
  List<RecetaModel> _recetasFiltradas = [];

  List<RecetaDetalleModel> _detalle = [];

  List<RecetaModel> get recetas => List.unmodifiable(_recetasFiltradas);

  List<RecetaDetalleModel> get detalle => List.unmodifiable(_detalle);

  /// ============================
  /// RECETAS
  /// ============================

  Future<void> cargarRecetas() async {
    _recetas = await _repository.obtenerTodas();

    _recetasFiltradas = List.from(_recetas);

    notifyListeners();
  }

  Future<void> guardarReceta(RecetaModel receta) async {
    await _repository.insertarReceta(receta);

    await cargarRecetas();
  }

  Future<void> actualizarReceta(RecetaModel receta) async {
    await _repository.actualizarReceta(receta);

    await cargarRecetas();
  }

  Future<void> eliminarReceta(int id) async {
    await _repository.eliminarReceta(id);

    await cargarRecetas();
  }

  RecetaModel? obtenerPorProducto(int productoId) {
    try {
      return _recetas.firstWhere((r) => r.productoId == productoId);
    } catch (_) {
      return null;
    }
  }

  void buscarRecetas(String texto) {
    if (texto.trim().isEmpty) {
      _recetasFiltradas = List.from(_recetas);
    } else {
      final busqueda = texto.toLowerCase();

      _recetasFiltradas = _recetas.where((receta) {
        return receta.nombre.toLowerCase().contains(busqueda) ||
            receta.productoId.toString().contains(busqueda);
      }).toList();
    }

    notifyListeners();
  }

  /// ============================
  /// DETALLE
  /// ============================

  void agregarDetalle(RecetaDetalleModel item) {
    _detalle.add(item);

    notifyListeners();
  }

  void eliminarDetalle(int index) {
    _detalle.removeAt(index);

    notifyListeners();
  }

  void limpiarDetalle() {
    _detalle.clear();

    notifyListeners();
  }

  /// ============================
  /// DASHBOARD
  /// ============================

  int get totalRecetas => _recetas.length;

  int get recetasActivas => _recetas.where((r) => r.activo).length;

  int get recetasInactivas => _recetas.where((r) => !r.activo).length;
}
