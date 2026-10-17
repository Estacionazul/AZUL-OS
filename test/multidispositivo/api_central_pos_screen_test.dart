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
  String? lastCloseIdempotencyKey;
  Map<String, dynamic>? pendingSale;
  Map<String, dynamic>? pendingCashClose;
  Map<String, dynamic> recoveryResponse = <String, dynamic>{'found': false};
  Object? recoveryError;
  int salePostCount = 0;

  static const productId = 'f2c8b91a-a0c3-4dc4-8b32-3e4e9cb31b01';

  @override
  Future<void> savePendingCentralSale({
    required String idempotencyKey,
    required Map<String, Object?> body,
  }) async {
    pendingSale = <String, dynamic>{'idempotencyKey': idempotencyKey, 'body': body};
  }

  @override
  Future<Map<String, dynamic>?> readPendingCentralSale() async => pendingSale;

  @override
  Future<void> clearPendingCentralSale() async {
    pendingSale = null;
  }

  @override
  Future<void> savePendingCentralCashClose({
    required String idempotencyKey,
    required Map<String, Object?> body,
  }) async {
    pendingCashClose = <String, dynamic>{'idempotencyKey': idempotencyKey, 'body': body};
  }

  @override
  Future<Map<String, dynamic>?> readPendingCentralCashClose() async => pendingCashClose;

  @override
  Future<void> clearPendingCentralCashClose() async {
    pendingCashClose = null;
  }


  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    if (path.startsWith('/api/v1/sales/by-idempotency/')) {
      if (recoveryError != null) throw recoveryError!;
      return recoveryResponse;
    }
    if (path == '/api/v1/cash/current') {
      return <String, dynamic>{'cashRegister': cash};
    }
    if (path == '/api/v1/sales') {
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'sale-id',
            'numero': 'V000001',
            'fecha': '2026-10-10T10:00:00.000Z',
            'documentType': 'Nota de Venta',
            'customerName': null,
            'total': 8.0,
            'paymentMethod': 'Efectivo',
          },
        ],
        'total': 1,
        'limit': 50,
        'offset': 0,
      };
    }
    if (path == '/api/v1/sales/sale-id') {
      return <String, dynamic>{
        'sale': <String, dynamic>{
          'id': 'sale-id',
          'number': 'V000001',
          'total': 8.0,
          'paymentMethod': 'Efectivo',
          'customerName': null,
        },
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'productId': productId,
            'productName': 'Americano central',
            'quantity': 1,
            'unitPrice': 8.0,
            'subtotal': 8.0,
          },
        ],
        'payments': <Map<String, dynamic>>[
          <String, dynamic>{'method': 'Efectivo', 'amount': 8.0},
        ],
        'documents': <Object?>[],
      };
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
    if (path == '/api/v1/cash/close') {
      lastCloseIdempotencyKey = idempotencyKey;
      cash = null;
      return <String, dynamic>{
        'cashRegister': <String, dynamic>{'id': 'cash-id', 'estado': 'CERRADA'},
        'reconciliation': <String, dynamic>{'expectedCash': 100.0, 'difference': 0.0},
        'replayed': true,
      };
    }
    if (path == '/api/v1/cash/open') {
      cash = <String, dynamic>{
        'id': 'cash-id',
        'openingAmount': body?['openingAmount'],
        'openedAt': '2026-10-09T10:00:00.000Z',
      };
      return <String, dynamic>{'cashRegister': cash};
    }
    if (path == '/api/v1/sales') {
      salePostCount++;
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
    await tester.enterText(find.byType(TextField).first, '1.15');
    await tester.tap(find.text('Abrir caja'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Caja abierta'), findsOneWidget);
    expect(api.cash?['openingAmount'], 1.15);

    await tester.tap(find.byTooltip('Agregar al carrito'));
    await tester.pumpAndSettle();
    expect(find.text('S/ 8.00'), findsWidgets);

    await tester.tap(find.text('REGISTRAR VENTA CENTRAL'));
    await tester.pumpAndSettle();

    expect(api.lastSaleBody?['paymentMethod'], 'Efectivo');
    expect(api.lastSaleBody?['items'], isA<List<Object?>>());
    expect(api.lastIdempotencyKey, isNotNull);
    expect(find.textContaining('V000001'), findsOneWidget);
  });

  testWidgets('central POS retries a pending cash close with its original key', (tester) async {
    final api = _FakePosApiClient()
      ..pendingCashClose = <String, dynamic>{
        'idempotencyKey': 'close-key-original',
        'body': <String, dynamic>{'closingAmount': 100.0},
      };
    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cierre de caja pendiente'), findsOneWidget);
    await tester.tap(find.text('Reintentar cierre'));
    await tester.pumpAndSettle();

    expect(api.lastCloseIdempotencyKey, 'close-key-original');
    expect(api.pendingCashClose, isNull);
    expect(find.textContaining('Caja cerrada'), findsOneWidget);
  });

  testWidgets('central POS opens central sales history and detail', (tester) async {
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
    await tester.tap(find.byTooltip('Historial de ventas centrales'));
    // The central history keeps the parent operation alive while its modal is open;
    // advance the route animation directly instead of waiting for global quiescence.
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('V000001'), findsOneWidget);
    await tester.tap(find.textContaining('V000001'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Americano central'), findsWidgets);
    expect(find.text('Venta V000001'), findsOneWidget);
    expect(find.text('Desglose de pagos'), findsOneWidget);
  });

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
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.labelText == 'Importe Efectivo'), '1.15');
    await tester.enterText(find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.labelText == 'Importe Yape'), '6.85');
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

  testWidgets('recovery confirms an existing sale and never posts it again', (tester) async {
    final api = _FakePosApiClient()
      ..pendingSale = <String, dynamic>{
        'idempotencyKey': 'sale-key-existing',
        'body': <String, Object?>{
          'items': <Map<String, Object?>>[
            <String, Object?>{'productId': _FakePosApiClient.productId, 'quantity': 1, 'extraShot': false},
          ],
          'paymentMethod': 'Efectivo',
          'discount': 0,
        },
      }
      ..recoveryResponse = <String, dynamic>{
        'found': true,
        'sale': <String, dynamic>{'number': 'V000123', 'total': 8.0},
      };
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.salePostCount, 0);
    expect(api.pendingSale, isNull);
    expect(find.textContaining('V000123'), findsOneWidget);
    expect(find.textContaining('No se volvió a cobrar'), findsOneWidget);
  });

  testWidgets('recovery not found keeps the original key and retries the same sale', (tester) async {
    final originalBody = <String, Object?>{
      'items': <Map<String, Object?>>[
        <String, Object?>{'productId': _FakePosApiClient.productId, 'quantity': 1, 'extraShot': false},
      ],
      'paymentMethod': 'Efectivo',
      'discount': 0,
    };
    final api = _FakePosApiClient()
      ..cash = <String, dynamic>{'id': 'cash-id', 'openingAmount': 20.0}
      ..pendingSale = <String, dynamic>{
        'idempotencyKey': 'sale-key-original',
        'body': originalBody,
      }
      ..recoveryResponse = <String, dynamic>{'found': false};
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.pendingSale?['idempotencyKey'], 'sale-key-original');
    expect(api.salePostCount, 0);
    await tester.tap(find.text('REGISTRAR VENTA CENTRAL'));
    await tester.pumpAndSettle();

    expect(api.lastIdempotencyKey, 'sale-key-original');
    expect(api.lastSaleBody, originalBody);
    expect(api.salePostCount, 1);
    expect(api.pendingSale, isNull);
  });

  testWidgets('recovery server error preserves pending sale and blocks another charge', (tester) async {
    final api = _FakePosApiClient()
      ..cash = <String, dynamic>{'id': 'cash-id', 'openingAmount': 20.0}
      ..pendingSale = <String, dynamic>{
        'idempotencyKey': 'sale-key-protected',
        'body': <String, Object?>{
          'items': <Map<String, Object?>>[
            <String, Object?>{'productId': _FakePosApiClient.productId, 'quantity': 1, 'extraShot': false},
          ],
          'paymentMethod': 'Efectivo',
          'discount': 0,
        },
      }
      ..recoveryError = const AzulApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Sesión no autorizada',
      );
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralPosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.pendingSale?['idempotencyKey'], 'sale-key-protected');
    expect(api.salePostCount, 0);
    expect(find.textContaining('Sesión no autorizada'), findsOneWidget);
    await tester.tap(find.text('REGISTRAR VENTA CENTRAL'));
    await tester.pumpAndSettle();
    expect(api.pendingSale?['idempotencyKey'], 'sale-key-protected');
    expect(api.salePostCount, 0);
    expect(find.textContaining('no registres otro cobro'), findsOneWidget);
  });

}
