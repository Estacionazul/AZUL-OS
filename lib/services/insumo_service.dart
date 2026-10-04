import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/insumo_model.dart';
import '../repositories/insumo_repository.dart';

class InsumoService extends ChangeNotifier {
  final InsumoRepository _repository;

  InsumoService(AppDatabase database)
    : _repository = InsumoRepository(database);

  List<InsumoModel> _insumos = [];
  List<InsumoModel> _insumosFiltrados = [];

  List<InsumoModel> get insumos => List.unmodifiable(_insumosFiltrados);

  /// Obtener todos los insumos
  Future<List<InsumoModel>> obtenerTodos() async {
    _insumos = await _repository.obtenerTodos();
    _insumosFiltrados = List.from(_insumos);

    notifyListeners();

    return _insumosFiltrados;
  }

  /// Insertar un insumo
  Future<int> agregar(InsumoModel insumo) async {
    final id = await _repository.insertar(insumo);

    await obtenerTodos();

    return id;
  }

  /// Actualizar un insumo
  Future<bool> actualizar(InsumoModel insumo) async {
    final actualizado = await _repository.actualizar(insumo);

    await obtenerTodos();

    return actualizado;
  }

  /// Eliminar un insumo
  Future<int> eliminar(int id) async {
    final eliminado = await _repository.eliminar(id);

    await obtenerTodos();

    return eliminado;
  }

  /// Buscar por código
  Future<InsumoModel?> buscarPorCodigo(String codigo) async {
    final insumos = await _repository.obtenerTodos();

    try {
      return insumos.firstWhere((i) => i.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  /// Obtener insumos con stock bajo
  Future<List<InsumoModel>> obtenerStockBajo() async {
    final insumos = await _repository.obtenerTodos();

    return insumos.where((i) => i.stock <= i.stockMinimo).toList();
  }

  /// Buscar por nombre o código
  void buscarInsumos(String texto) {
    if (texto.trim().isEmpty) {
      _insumosFiltrados = List.from(_insumos);
    } else {
      final busqueda = texto.toLowerCase();

      _insumosFiltrados = _insumos.where((insumo) {
        return insumo.nombre.toLowerCase().contains(busqueda) ||
            insumo.codigo.toLowerCase().contains(busqueda);
      }).toList();
    }

    notifyListeners();
  }

  /// Obtener un insumo por ID
  Future<InsumoModel?> obtenerPorId(int id) {
    return _repository.obtenerPorId(id);
  }
}
