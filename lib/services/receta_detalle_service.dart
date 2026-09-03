import 'package:flutter/foundation.dart';

import '../models/receta_detalle_model.dart';
import '../repositories/receta_detalle_repository.dart';

class RecetaDetalleService extends ChangeNotifier {
  final RecetaDetalleRepository _repository;

  RecetaDetalleService(this._repository);

  List<RecetaDetalleModel> _ingredientes = [];

  List<RecetaDetalleModel> get ingredientes => List.unmodifiable(_ingredientes);

  /// Cargar ingredientes de una receta
  Future<void> cargarIngredientes(int recetaId) async {
    _ingredientes = await _repository.obtenerPorReceta(recetaId);

    notifyListeners();
  }

  /// Agregar ingrediente
  Future<void> agregarIngrediente(RecetaDetalleModel detalle) async {
    final existe = _ingredientes.any((i) => i.insumoId == detalle.insumoId);

    if (existe) {
      throw Exception("Este insumo ya fue agregado a la receta.");
    }

    await _repository.insertar(detalle);

    await cargarIngredientes(detalle.recetaId);
  }

  /// Editar ingrediente
  Future<void> editarIngrediente(RecetaDetalleModel detalle) async {
    await _repository.actualizar(detalle);
    await cargarIngredientes(detalle.recetaId);
  }

  /// Eliminar ingrediente
  Future<void> eliminarIngrediente(RecetaDetalleModel detalle) async {
    if (detalle.id == null) return;

    await _repository.eliminar(detalle.id!);
    await cargarIngredientes(detalle.recetaId);
  }

  /// Eliminar todos los ingredientes
  Future<void> eliminarTodo(int recetaId) async {
    await _repository.eliminarPorReceta(recetaId);

    _ingredientes = [];

    notifyListeners();
  }

  int get cantidadIngredientes => _ingredientes.length;
  Future<List<RecetaDetalleModel>> obtenerPorReceta(int recetaId) async {
    return await _repository.obtenerPorReceta(recetaId);
  }
}
