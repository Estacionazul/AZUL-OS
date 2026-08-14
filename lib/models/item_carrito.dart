import '../configuracion/precios.dart';
import 'producto_model.dart';

class ItemCarrito {
  final ProductoModel producto;
  final String uid;

  int cantidad;

  // Variantes
  final String? tamano;
  final String? tipoLeche;
  final String? endulzante;
  final String? infusion;
  final String? observaciones;
  final bool extraShot;

  ItemCarrito({
    String? uid,
    required this.producto,
    this.cantidad = 1,
    this.tamano,
    this.tipoLeche,
    this.endulzante,
    this.infusion,
    this.observaciones,
    this.extraShot = false,
  }) : uid = uid ?? DateTime.now().microsecondsSinceEpoch.toString();

  double get precioUnitario {
    double precio = producto.precioVenta;

    // Tamaño Grande
    if (tamano == "Grande") {
      precio += PreciosConfig.incrementoGrande;
    }

    // Extra Shot
    if (extraShot) {
      precio += PreciosConfig.precioExtraShot;
    }

    return precio;
  }

  double get subtotal => precioUnitario * cantidad;
}