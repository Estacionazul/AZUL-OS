import 'package:flutter/material.dart';

import '../../widgets/pos/pos_cart.dart';
import '../../widgets/pos/pos_categories.dart';
import '../../widgets/pos/pos_checkout_button.dart';
import '../../widgets/pos/pos_products.dart';
import '../../widgets/pos/pos_search.dart';
import '../../widgets/pos/pos_total.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Punto de Venta"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [

            //==================================
            // IZQUIERDA
            //==================================

            Expanded(
              flex: 2,

              child: Column(
                children: const [

                  PosSearch(),

                  SizedBox(height: 16),

                  PosCategories(),

                  SizedBox(height: 16),

                  Expanded(
                    child: PosProducts(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            //==================================
            // DERECHA
            //==================================

            SizedBox(
              width: 350,

              child: Column(
                children: const [

                  Expanded(
                    child: PosCart(),
                  ),

                  Divider(),

                  PosTotal(),

                  SizedBox(height: 12),

                  PosCheckoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}