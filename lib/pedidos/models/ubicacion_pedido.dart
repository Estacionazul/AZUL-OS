enum TipoUbicacion { mesa, barra, paraLlevar }

class UbicacionPedido {
  final String id;
  final String nombre;
  final TipoUbicacion tipo;

  const UbicacionPedido({
    required this.id,
    required this.nombre,
    required this.tipo,
  });

  bool get esMesa => tipo == TipoUbicacion.mesa;

  bool get esBarra => tipo == TipoUbicacion.barra;

  bool get esParaLlevar => tipo == TipoUbicacion.paraLlevar;
}
