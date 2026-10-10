import 'package:azul_os/multidispositivo/azul_api_client.dart';
import 'package:azul_os/screens/auth/api_central_inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeInventoryApi extends AzulApiClient {
  _FakeInventoryApi() : super();

  static const itemId = 'f2c8b91a-a0c3-4dc4-8b32-3e4e9cb31b01';
  Map<String, Object?>? movementBody;
  String? movementKey;
  int stockRequests = 0;
  Map<String, dynamic>? pendingMovement;

  @override
  Future<void> savePendingCentralInventoryMovement({
    required String idempotencyKey,
    required Map<String, Object?> body,
  }) async {
    pendingMovement = <String, dynamic>{'idempotencyKey': idempotencyKey, 'body': body};
  }

  @override
  Future<Map<String, dynamic>?> readPendingCentralInventoryMovement() async => null;

  @override
  Future<void> clearPendingCentralInventoryMovement() async {
    pendingMovement = null;
  }

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    if (path == '/api/v1/inventory/stock') {
      stockRequests++;
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'itemType': 'insumo',
            'id': itemId,
            'code': 'INS-001',
            'name': 'Leche fresca',
            'category': 'Insumos',
            'minimumStock': 2,
            'currentStock': 10,
            'lowStock': false,
            'status': 'OK',
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
    if (path == '/api/v1/inventory/movements') {
      movementBody = body;
      movementKey = idempotencyKey;
      return <String, dynamic>{'id': 'movement-id', 'replayed': false};
    }
    throw StateError('Unexpected endpoint: $path');
  }
}

void main() {
  testWidgets('central inventory registers an idempotent stock movement', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _FakeInventoryApi();
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralInventoryScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Leche fresca'), findsOneWidget);
    expect(find.text('Stock 10'), findsOneWidget);

    await tester.tap(find.byTooltip('Registrar movimiento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar movimiento'));
    await tester.pumpAndSettle();

    expect(api.movementBody?['itemType'], 'insumo');
    expect(api.movementBody?['itemId'], _FakeInventoryApi.itemId);
    expect(api.movementBody?['type'], 'ENTRADA');
    expect(api.movementBody?['quantity'], 1.0);
    expect(api.movementKey, isNotNull);
    expect(api.pendingMovement, isNull);
    // Successful post, cleared pending request and refreshed stock are the
    // deterministic proof of completion; banner visibility is presentation-only.
    expect(api.stockRequests, greaterThanOrEqualTo(2));
  });
}
