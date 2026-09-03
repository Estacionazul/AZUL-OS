import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/producto_model.dart';

class ProductoMapper {
  /// Convierte un Producto de Drift a ProductoModel
  static ProductoModel toModel(Producto producto) {
    return ProductoModel(
      id: producto.id,
      codigo: producto.codigo,
      codigoBarras: producto.codigoBarras ?? '',
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      categoriaId: producto.categoriaId,
      costo: producto.costo,
      precioVenta: producto.precioVenta,
      stock: producto.stock,
      stockMinimo: producto.stockMinimo,
      tipoInventario: producto.tipoInventario,
      emoji: producto.emoji,
      imagen: producto.imagen,
      activo: producto.activo,
    );
  }

  /// Convierte un ProductoModel a ProductosCompanion
  static ProductosCompanion toCompanion(ProductoModel model) {
    return ProductosCompanion(
      id: model.id == null ? const Value.absent() : Value(model.id!),
      codigo: Value(model.codigo),
      codigoBarras: model.codigoBarras.isEmpty
          ? const Value.absent()
          : Value(model.codigoBarras),
      nombre: Value(model.nombre),
      descripcion: Value(model.descripcion),
      categoriaId: Value(model.categoriaId),
      costo: Value(model.costo),
      precioVenta: Value(model.precioVenta),
      stock: Value(model.stock),
      stockMinimo: Value(model.stockMinimo),
      tipoInventario: Value(model.tipoInventario),
      emoji: Value(model.emoji),
      imagen: Value(model.imagen),
      activo: Value(model.activo),
    );
  }
}
