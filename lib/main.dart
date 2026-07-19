import 'package:flutter/material.dart';
import 'screens/cafeteria_screen.dart';

void main() {
  runApp(const AzulOSApp());
}

class AzulOSApp extends StatelessWidget {
  const AzulOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AZUL OS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xff0A2E6E),
        title: const Text("AZUL OS"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,

          children: [

            boton(
              Icons.coffee,
              "Cafetería",
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const
                    CafeteriaScreen(),
                  ),
                );
              },
            ),
            boton(Icons.print, "Servicios", () {}),

            boton(Icons.point_of_sale, "Caja", () {}),

            boton(Icons.inventory, "Inventario", () {}),

            boton(Icons.people, "Clientes", () {}),

            boton(Icons.bar_chart, "Reportes", () {}),

          ],
        ),
      ),
    );
  }

  Widget boton(IconData icono, String texto, VoidCallback onTap) {

    return Card(
      elevation:6,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: InkWell(

        borderRadius: BorderRadius.circular(18),

        onTap: onTap,

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icono,
              size:55,
              color: Color(0xff0A2E6E),
            ),

            SizedBox(height:15),

            Text(
              texto,

              style: TextStyle(
                fontSize:20,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );

  }

}