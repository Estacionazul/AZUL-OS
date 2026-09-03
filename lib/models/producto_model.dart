class ProductoModel {
  final int? id;

  // Identificación
  final String codigo;
  final String codigoBarras;

  // Información
  final String nombre;
  final String descripcion;

  // Relación con Categorías
  final int categoriaId;

  // Precios
  final double costo;
  final double precioVenta;

  // Inventario
  final int stock;
  final int stockMinimo;

  /// Tipo de inventario:
  /// receta = descuenta insumos
  /// producto = descuenta stock del producto
  final String tipoInventario;

  // POS
  final String emoji;
  final String imagen;

  // Estado
  final bool activo;

  const ProductoModel({
    this.id,
    required this.codigo,
    this.codigoBarras = '',
    required this.nombre,
    this.descripcion = '',
    required this.categoriaId,
    this.costo = 0,
    required this.precioVenta,
    this.stock = 0,
    this.stockMinimo = 0,
    this.tipoInventario = 'receta',
    this.emoji = '📦',
    this.imagen = '',
    this.activo = true,
  });
}
