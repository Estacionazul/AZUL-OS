import 'package:azul_os/multidispositivo/azul_api_client.dart';
import 'package:azul_os/screens/auth/api_central_pos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakePosApiClient extends AzulApiClient {
  _FakePosApiClient() : super();

  Map<String, dynamic>? cash;
  Map<String, dynamic>? lastSaleBody;
  String? lastIdempotencyKey;

  static const productId = 'f2c8b91a-a0c3-4dc4-8b32-3e4e9cb31b01';

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    if (path == '/api/v1/cash/current') {
      return <String, dynamic>{'cashRegister': cash};
    }
    if (path == '/api/v1/catalog/products') {
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': productId,
            'code': 'CAF-001',
            'name': 'Americano central',
            'salePrice': 8.0,
            'inventoryType': 'producto',
            'igvAffectation': '10',
            'emoji': '☕',
            'active': true,
          },
        ],
        'pagination': <String, dynamic>{'limit': 100, 'offset': 0, 'total': 1},
      };
    }
    throw StateError('Unexpected endpoint: $path');
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, Object?>? body,
    String? idempotencyKey,
  }) async {
    if (path == '/api/v1/cash/open') {
      cash = <String, dynamic>{
        'id': 'cash-id',
        'openingAmount': body?['openingAmount'],
        'openedAt': '2026-10-09T10:00:00.000Z',
      };
      return <String, dynamic>{'cashRegister': cash};
    }
    if (path == '/api/v1/sales') {
      lastSaleBody = body;
      lastIdempotencyKey = idempotencyKey;
      return <String, dynamic>{
        'sale': <String, dynamic>{
          'id': 'sale-id',
          'number': 'V000001',
          'total': 8.0,
        },
        'replayed': false,
      };
    }
    throw StateError('Unexpected endpoint: $path');
  }
}

void main() {
  testWidgets('central POS opens central cash and registers a server sale', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakePosApiClient();
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay caja central abierta'), findsOneWidget);
    await tester.tap(find.text('Abrir caja'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Caja abierta'), findsOneWidget);

    await tester.tap(find.byTooltip('Agregar al carrito'));
    await tester.pumpAndSettle();
    expect(find.text('S/ 8.00'), findsWidgets);

    await tester.tap(find.text('REGISTRAR VENTA CENTRAL'));
    await tester.pumpAndSettle();

    expect(api.lastSaleBody?['paymentMethod'], 'Efectivo');
    expect(api.lastSaleBody?['items'], isA<List<Object?>>());
    expect(api.lastIdempotencyKey, isNotNull);
    expect(find.textContaining('V000001'), findsOneWidget);

  testWidgets('central POS validates and sends mixed payment breakdown', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakePosApiClient();
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir caja'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Agregar al carrito'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REGISTRAR VENTA CENTRAL'));
    await tester.pumpAndSettle();

    expect(api.lastSaleBody?['paymentMethod'], 'Mixto');
    final payments = api.lastSaleBody?['payments'] as List<Object?>;
    expect(payments, hasLength(2));
    final paid = payments.cast<Map<String, Object?>>().fold<double>(
      0,
      (sum, payment) => sum + (payment['amount'] as num).toDouble(),
    );
    expect(paid, 8.0);
    expect(find.textContaining('V000001'), findsOneWidget);
  });

}
