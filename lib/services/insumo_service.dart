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

  /// Insertar un insumo.
  ///
  /// El stock operativo inicial siempre empieza en 0.
  /// Las entradas se registran mediante MovimientoInventarioService.
  Future<int> agregar(InsumoModel insumo) async {
    final nuevoInsumo = InsumoModel(
      id: null,
      codigo: insumo.codigo,
      nombre: insumo.nombre,
      descripcion: insumo.descripcion,
      categoriaId: insumo.categoriaId,
      unidadMedida: insumo.unidadMedida,
      stock: 0,
      stockMinimo: insumo.stockMinimo,
      costoCompra: insumo.costoCompra,
      proveedorId: insumo.proveedorId,
      emoji: insumo.emoji,
      imagen: insumo.imagen,
      activo: insumo.activo,
    );

    final id = await _repository.insertar(nuevoInsumo);

    await obtenerTodos();

    return id;
  }

  /// Actualizar solo datos maestros de un insumo.
  ///
  /// El stock actual siempre se vuelve a leer desde la BD para
  /// evitar que una edición sobrescriba movimientos recientes.
  Future<bool> actualizar(InsumoModel insumo) async {
    final id = insumo.id;

    if (id == null) {
      return false;
    }

    final actual = await _repository.obtenerPorId(id);

    if (actual == null) {
      return false;
    }

    final actualizado = InsumoModel(
      id: actual.id,
      codigo: insumo.codigo,
      nombre: insumo.nombre,
      descripcion: insumo.descripcion,
      categoriaId: insumo.categoriaId,
      unidadMedida: insumo.unidadMedida,
      stock: actual.stock,
      stockMinimo: insumo.stockMinimo,
      costoCompra: insumo.costoCompra,
      proveedorId: insumo.proveedorId,
      emoji: insumo.emoji,
      imagen: insumo.imagen,
      activo: insumo.activo,
    );

    final ok = await _repository.actualizar(actualizado);

    await obtenerTodos();

    return ok;
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
