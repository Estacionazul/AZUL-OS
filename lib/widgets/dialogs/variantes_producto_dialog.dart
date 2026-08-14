import 'package:flutter/material.dart';

import '../../models/producto_model.dart';

class VariantesProductoDialog extends StatefulWidget {
  final ProductoModel producto;

  const VariantesProductoDialog({
    super.key,
    required this.producto,
  });

  @override
  State<VariantesProductoDialog> createState() =>
      _VariantesProductoDialogState();
}

class _VariantesProductoDialogState
    extends State<VariantesProductoDialog> {

String tamano = "Clásico";
String leche = "Entera";
String endulzante = "Azúcar";
bool extraShot = false;
String infusion = "Manzanilla";

final TextEditingController observacionesController =
TextEditingController();

bool get esCafe {
return widget.producto.categoriaId == 1;
}

bool get esBebida {
return widget.producto.categoriaId == 2 ||
widget.producto.categoriaId == 5;
}

bool get esEspresso {
return widget.producto.nombre.toLowerCase() == "espresso";
}

bool get esChocolate {
  return widget.producto.nombre == "Chocolate Caliente";
}

bool get esInfusion {
  return widget.producto.nombre == "Infusiones";
}

bool get esJugoConLeche {
  return widget.producto.nombre == "Papaya con Leche" ||
      widget.producto.nombre == "Fresa con Leche";
}

bool get esJugoNormal {
  return widget.producto.categoriaId == 2 &&
      !esJugoConLeche;
}

bool get esLimonada {
  return widget.producto.nombre.contains("Limonada");
}

bool get esChichaMaracuya {
  return widget.producto.nombre == "Chicha Morada" ||
      widget.producto.nombre == "Maracuyá";
}

double get precioFinal {
  double precio = widget.producto.precioVenta;

  // Tamaño grande
  if (tamano == "Grande") {
    if (esCafe || esInfusion) {
      precio += 2;
    } else if (widget.producto.categoriaId == 2) {
      precio += 2;
    }
  }

  // Extra Shot
  if (extraShot) {
    precio += 3;
  }

  return precio;
}

@override
Widget build(BuildContext context) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(22),
),
title: Text(
widget.producto.nombre,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
content: SizedBox(
width: 420,
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
if (!esEspresso) ...[
const Text(
"TAMAÑO",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
const SizedBox(height: 8),

RadioListTile<String>(
value: "Clásico",
groupValue: tamano,
title: const Text("Clásico (355 ml)"),
onChanged: (value) {
setState(() {
tamano = value!;
});
},
),

RadioListTile<String>(
value: "Grande",
groupValue: tamano,
title: const Text("Grande (473 ml)"),
onChanged: (value) {
setState(() {
tamano = value!;
});
},
),

const Divider(height: 30),
],

  if (esInfusion) ...[
    const Text(
      "¿QUÉ INFUSIÓN DESEA?",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),

    const SizedBox(height: 8),

    RadioListTile<String>(
      value: "Manzanilla",
      groupValue: infusion,
      title: const Text("🌼 Manzanilla"),
      onChanged: (value) {
        setState(() {
          infusion = value!;
        });
      },
    ),

    RadioListTile<String>(
      value: "Anís",
      groupValue: infusion,
      title: const Text("🌿 Anís"),
      onChanged: (value) {
        setState(() {
          infusion = value!;
        });
      },
    ),

    RadioListTile<String>(
      value: "Hierba Luisa",
      groupValue: infusion,
      title: const Text("🌱 Hierba Luisa"),
      onChanged: (value) {
        setState(() {
          infusion = value!;
        });
      },
    ),

    RadioListTile<String>(
      value: "Té Canela y Clavo",
      groupValue: infusion,
      title: const Text("🌰 Té Canela y Clavo"),
      onChanged: (value) {
        setState(() {
          infusion = value!;
        });
      },
    ),

    RadioListTile<String>(
      value: "Frutos Rojos",
      groupValue: infusion,
      title: const Text("🍓 Frutos Rojos"),
      onChanged: (value) {
        setState(() {
          infusion = value!;
        });
      },
    ),

    const Divider(height: 30),
  ],
  if ((esCafe && !esEspresso && !esChocolate && !esInfusion) ||
      esJugoConLeche) ...[
const Text(
"TIPO DE LECHE",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),

const SizedBox(height: 8),

RadioListTile<String>(
value: "Entera",
groupValue: leche,
title: const Text("Leche Entera"),
onChanged: (value) {
setState(() {
leche = value!;
});
},
),

RadioListTile<String>(
value: "Deslactosada",
groupValue: leche,
title: const Text("Leche Deslactosada"),
onChanged: (value) {
setState(() {
leche = value!;
});
},
),

    RadioListTile<String>(
      value: "Light",
      groupValue: leche,
      title: const Text("Leche Light"),
      onChanged: (value) {
        setState(() {
          leche = value!;
        });
      },
    ),

const Divider(height: 30),
],

  if ((esCafe && !esEspresso) ||
      esChocolate ||
      esInfusion ||
      esJugoNormal ||
      esJugoConLeche ||
      esLimonada) ...[
const Text(
"ENDULZANTE",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),

const SizedBox(height: 8),

RadioListTile<String>(
value: "Azúcar",
groupValue: endulzante,
title: const Text("Azúcar"),
onChanged: (value) {
setState(() {
endulzante = value!;
});
},
),

RadioListTile<String>(
value: "Sin azúcar",
groupValue: endulzante,
title: const Text("Sin azúcar"),
onChanged: (value) {
setState(() {
endulzante = value!;
});
},
),

RadioListTile<String>(
value: "Stevia",
groupValue: endulzante,
title: const Text("Stevia"),
onChanged: (value) {
setState(() {
endulzante = value!;
});
},
),

const Divider(height: 30),
],

  if (esCafe &&
      !esEspresso &&
      !esChocolate &&
      !esInfusion)
CheckboxListTile(
value: extraShot,
title: const Text("Extra Shot de Espresso"),
subtitle: const Text("Agregar un shot adicional"),
onChanged: (value) {
setState(() {
extraShot = value ?? false;
});
},
),

  const Divider(height: 30),

  const Text(
    "OBSERVACIONES",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),

  const SizedBox(height: 8),

  TextField(
    controller: observacionesController,
    maxLines: 3,
    decoration: InputDecoration(
      hintText: "Ej.: Muy caliente, para llevar, sin espuma...",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
],
),
),
),
  actions: [
    TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Cancelar"),
    ),
    ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(
          context,
          {
            "tamano": esEspresso ? null : tamano,
            "tipoLeche": (esCafe && !esEspresso) ? leche : null,
            "endulzante": (esCafe || esBebida) ? endulzante : null,
            "extraShot": (esCafe && !esEspresso) ? extraShot : false,
            "infusion": esInfusion ? infusion : null,
            "observaciones": observacionesController.text.trim(),
          },
        );
      },
      icon: const Icon(Icons.shopping_cart),
      label: Text(
        "Agregar al carrito • S/. ${precioFinal.toStringAsFixed(2)}",
      ),
    ),
  ],
);
}

@override
void dispose() {
  observacionesController.dispose();
  super.dispose();
}
}