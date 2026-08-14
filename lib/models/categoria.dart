class Categoria {
  final String id;
  final String nombre;
  final String icono;
  final String color;
  final bool activa;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.color,
    this.activa = true,
  });
}