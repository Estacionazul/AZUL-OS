class InsumoModel {
  final int? id;

  // Identificación
  final String codigo;

  // Información
  final String nombre;
  final String descripcion;

  // Categoría
  final int categoriaId;

  // Unidad de medida
  // g, ml, unidad
  final String unidadMedida;

  // Inventario
  final double stock;
  final double stockMinimo;

  // Compras
  final double costoCompra;

  // Proveedor principal
  final int? proveedorId;

  // POS
  final String emoji;
  final String imagen;

  // Estado
  final bool activo;

  const InsumoModel({
    this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion = '',
    required this.categoriaId,
    required this.unidadMedida,
    this.stock = 0,
    this.stockMinimo = 0,
    this.costoCompra = 0,
    this.proveedorId,
    this.emoji = '🥛',
    this.imagen = '',
    this.activo = true,
  });
}
