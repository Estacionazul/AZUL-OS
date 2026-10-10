import 'package:azul_os/multidispositivo/azul_api_client.dart';
import 'package:azul_os/screens/auth/api_central_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeAzulApiClient extends AzulApiClient {
  _FakeAzulApiClient() : super();

  @override
  Future<bool> get hasSession async => false;

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String pin,
  }) async {
    expect(username, 'ceo.central');
    expect(pin, '1234');
    return <String, dynamic>{
      'token': 'test-token',
      'user': <String, dynamic>{
        'id': 'user-id',
        'username': 'ceo.central',
        'name': 'CEO Central',
        'role': 'CEO',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    if (path == '/api/v1/catalog/categories') {
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': '2d2dfaf1-8d56-4b14-9b45-8e6c04a1f1a1',
            'name': 'Cafés',
            'icon': '☕',
            'sortOrder': 1,
          },
        ],
      };
    }
    if (path == '/api/v1/catalog/products') {
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'f2c8b91a-a0c3-4dc4-8b32-3e4e9cb31b01',
            'code': 'CAF-001',
            'name': 'Americano central',
            'categoryId': '2d2dfaf1-8d56-4b14-9b45-8e6c04a1f1a1',
            'categoryName': 'Cafés',
            'salePrice': 8.0,
            'inventoryType': 'producto',
            'igvAffectation': '10',
            'emoji': '☕',
            'active': true,
          },
        ],
        'pagination': <String, dynamic>{
          'limit': 100,
          'offset': 0,
          'total': 1,
        },
      };
    }
    throw StateError('Unexpected endpoint: $path');
  }
}

void main() {
  testWidgets('central login loads server catalog without local database', (tester) async {
    final api = _FakeAzulApiClient();
    addTearDown(api.dispose);

    await tester.pumpWidget(
      Provider<AzulApiClient>.value(
        value: api,
        child: const MaterialApp(home: ApiCentralScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión central'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'ceo.central');
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('INGRESAR AL SERVIDOR'));
    await tester.pumpAndSettle();

    expect(find.text('CEO Central'), findsOneWidget);
    expect(find.text('Americano central'), findsOneWidget);
    expect(find.text('S/ 8.00'), findsOneWidget);
    expect(find.textContaining('Solo lectura'), findsOneWidget);
  });
}
