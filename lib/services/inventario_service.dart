import '../data/inventario_data.dart';
import '../models/insumo.dart';

class InventarioService {
  final List<Insumo> _insumos = inventarioData;

  List<Insumo> get insumos => _insumos;

  void aumentarStock(Insumo insumo, double cantidad) {
    insumo.stock += cantidad;
  }

  void disminuirStock(Insumo insumo, double cantidad) {
    if (insumo.stock >= cantidad) {
      insumo.stock -= cantidad;
    }
  }

  void agregarInsumo(Insumo insumo) {
    _insumos.add(insumo);
  }

  void eliminarInsumo(Insumo insumo) {
    _insumos.remove(insumo);
  }

  Insumo? buscarPorCodigo(String codigo) {
    try {
      return _insumos.firstWhere((i) => i.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  List<Insumo> obtenerStockBajo({double minimo = 5}) {
    return _insumos.where((i) => i.stock <= minimo).toList();
  }
}
