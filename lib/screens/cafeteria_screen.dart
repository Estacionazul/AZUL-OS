import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../data/productos_data.dart';

class CafeteriaScreen extends StatefulWidget {
  const CafeteriaScreen({super.key});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  final List<Producto> carrito = [];

  void agregarAlCarrito(Producto producto) {
    setState(() {
      carrito.add(producto);
    });
  }

  double get total {
    return carrito.fold(0, (suma, producto) => suma + producto.precio);
  }

  @override
  Widget build(BuildContext context) {
    final cafes =
    productosData.where((p) => p.categoria == "Cafés").toList();

    final jugos =
    productosData.where((p) => p.categoria == "Jugos").toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("CAFETERÍA"),
        centerTitle: true,
        backgroundColor: const Color(0xff0A2E6E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "CAFÉS",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...cafes.map((p) => tarjetaProducto(p)),

          const SizedBox(height: 30),

          const Text(
            "JUGOS",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...jugos.map((p) => tarjetaProducto(p)),

          const SizedBox(height: 30),

          const Divider(),

          const Text(
            "🛒 CARRITO",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          if (carrito.isEmpty)
            const Text("No hay productos agregados."),

          ...carrito.map(
                (p) => ListTile(
              leading: Text(
                p.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(p.nombre),
              subtitle: Text("Código: ${p.codigo}"),
              trailing: Text(
                "S/. ${p.precio.toStringAsFixed(2)}",
              ),
            ),
          ),

          const Divider(),

          ListTile(
            title: const Text(
              "TOTAL",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "S/. ${total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: carrito.isEmpty ? null : () {},
              child: const Text(
                "COBRAR",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaProducto(Producto producto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(
          producto.emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(producto.nombre),
        subtitle: Text(
          "S/. ${producto.precio.toStringAsFixed(2)}",
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
          onPressed: () {
            agregarAlCarrito(producto);
          },
        ),
      ),
    );
  }
}