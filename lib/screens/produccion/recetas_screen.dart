import 'package:flutter/material.dart';

class RecetasScreen extends StatelessWidget {
  const RecetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("RECETAS"),
        centerTitle: true,
        backgroundColor: const Color(0xff0A2E6E),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Lo conectaremos con el diálogo en el siguiente paso
        },
        backgroundColor: const Color(0xff0A2E6E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Receta",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar receta...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "Aún no hay recetas registradas",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
