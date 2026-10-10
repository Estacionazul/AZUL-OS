import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AzulApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const AzulApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AzulApiException($statusCode, $code): $message';
}

/// Cliente HTTP compartido para Windows, Android y tabletas.
/// No modifica ni migra la base SQLite local.
class AzulApiClient {
  AzulApiClient({
    FlutterSecureStorage? secureStorage,
    HttpClient? httpClient,
  })  : _storage = secureStorage ?? const FlutterSecureStorage(),
        _http = httpClient ?? HttpClient() {
    _http.connectionTimeout = const Duration(seconds: 10);
    _http.idleTimeout = const Duration(seconds: 20);
  }

  static const _baseUrlKey = 'azul.api.base_url';
  static const _establishmentKey = 'azul.api.establishment_id';
  static const _deviceKey = 'azul.api.device_id';
  static const _tokenKey = 'azul.api.access_token';
  static const _pendingCentralSaleKey = 'azul.api.pending_central_sale';

  final FlutterSecureStorage _storage;
  final HttpClient _http;

  Future<String?> get baseUrl => _storage.read(key: _baseUrlKey);
  Future<String?> get establishmentId => _storage.read(key: _establishmentKey);
  Future<String?> get deviceId => _storage.read(key: _deviceKey);
  Future<bool> get hasSession async => (await _storage.read(key: _tokenKey)) != null;

  Future<void> configure({
    required String baseUrl,
    required String establishmentId,
    required String deviceId,
    bool allowInsecureHttp = false,
  }) async {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        !['http', 'https'].contains(uri.scheme)) {
      throw const FormatException('Indica una URL base válida, sin rutas ni credenciales.');
    }
    final isLoopback = ['localhost', '127.0.0.1', '::1', '10.0.2.2'].contains(uri.host.toLowerCase());
    if (uri.scheme != 'https' && !(allowInsecureHttp && isLoopback)) {
      throw const FormatException('La API debe usar HTTPS. HTTP solo se permite para pruebas locales explícitas.');
    }
    if (!_isUuid(establishmentId) || !_isUuid(deviceId)) {
      throw const FormatException('El establecimiento y el dispositivo deben ser UUID válidos.');
    }

    final normalizedUrl = uri.replace(path: '', query: null, fragment: null).toString().replaceFirst(RegExp(r'/$'), '');
    await _storage.write(key: _baseUrlKey, value: normalizedUrl);
    await _storage.write(key: _establishmentKey, value: establishmentId);
    await _storage.write(key: _deviceKey, value: deviceId);
    await clearSession();
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String pin,
  }) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const FormatException('El PIN debe tener exactamente cuatro dígitos.');
    }
    final establishment = await _required(_establishmentKey, 'Falta configurar el establecimiento.');
    final device = await _required(_deviceKey, 'Falta configurar este dispositivo.');
    final result = await _send(
      method: 'POST',
      path: '/api/v1/auth/login',
      authenticated: false,
      body: {
        'establishmentId': establishment,
        'deviceId': device,
        'username': username.trim(),
        'pin': pin,
      },
    );
    final token = result['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('La API devolvió una respuesta de inicio de sesión inválida.');
    }
    await _storage.write(key: _tokenKey, value: token);
    return result;
  }

  Future<Map<String, dynamic>> checkHealth() =>
      _send(method: 'GET', path: '/health/ready', authenticated: false);

  Future<Map<String, dynamic>> me() => getJson('/api/v1/auth/me');

  Future<void> logout() async {
    try {
      if (await hasSession) {
        await _send(method: 'POST', path: '/api/v1/auth/logout');
      }
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() => _storage.delete(key: _tokenKey);

  /// Persists the exact pending central sale request so an ambiguous network
  /// result can be retried with the same idempotency key after app restart.
  Future<void> savePendingCentralSale({
    required String idempotencyKey,
    required Map<String, Object?> body,
  }) async {
    await _storage.write(
      key: _pendingCentralSaleKey,
      value: jsonEncode(<String, Object?>{
        'idempotencyKey': idempotencyKey,
        'body': body,
        'baseUrl': await _storage.read(key: _baseUrlKey),
        'establishmentId': await _storage.read(key: _establishmentKey),
        'deviceId': await _storage.read(key: _deviceKey),
      }),
    );
  }

  Future<Map<String, dynamic>?> readPendingCentralSale() async {
    final raw = await _storage.read(key: _pendingCentralSaleKey);
    if (raw == null || raw.trim().isEmpty) return null;
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException(
        'La venta central pendiente está dañada. No inicies otro cobro hasta revisar el historial central.',
      );
    }
    if (decoded is Map<String, dynamic> &&
        decoded['idempotencyKey'] is String &&
        decoded['body'] is Map<String, dynamic>) {
      final baseUrl = await _storage.read(key: _baseUrlKey);
      final establishmentId = await _storage.read(key: _establishmentKey);
      final deviceId = await _storage.read(key: _deviceKey);
      if (decoded['baseUrl'] != baseUrl ||
          decoded['establishmentId'] != establishmentId ||
          decoded['deviceId'] != deviceId) {
        throw const FormatException(
          'Hay una venta pendiente asociada a otra API, establecimiento o dispositivo. No cambies de servidor ni cobres de nuevo hasta verificar el historial del servidor original.',
        );
      }
      return decoded;
    }
    throw const FormatException(
      'La venta central pendiente está dañada. No inicies otro cobro hasta revisar el historial central.',
    );
  }

  Future<void> clearPendingCentralSale() =>
      _storage.delete(key: _pendingCentralSaleKey);

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) =>
      _send(method: 'GET', path: path, query: query);

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, Object?>? body,
    String? idempotencyKey,
  }) =>
      _send(
        method: 'POST',
        path: path,
        body: body,
        idempotencyKey: idempotencyKey,
      );

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, Object?> body,
  }) =>
      _send(method: 'PATCH', path: path, body: body);

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, String>? query,
    Map<String, Object?>? body,
    String? idempotencyKey,
    bool authenticated = true,
  }) async {
    final configuredUrl = await _required(_baseUrlKey, 'Primero configura la dirección de la API.');
    final uri = Uri.parse('$configuredUrl$path').replace(queryParameters: query);
    final request = await _http.openUrl(method, uri).timeout(const Duration(seconds: 15));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (body != null) request.headers.contentType = ContentType.json;
    if (idempotencyKey != null) request.headers.set('Idempotency-Key', idempotencyKey);
    if (authenticated) {
      final token = await _required(_tokenKey, 'Inicia sesión para continuar.');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.add(utf8.encode(jsonEncode(body)));

    final response = await request.close().timeout(const Duration(seconds: 20));
    final text = await response.transform(utf8.decoder).join();
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (text.trim().isNotEmpty) {
      try {
        final value = jsonDecode(text);
        if (value is Map<String, dynamic>) decoded = value;
      } on FormatException {
        decoded = <String, dynamic>{};
      }
    }

    if (response.statusCode == 401 && authenticated) {
      await clearSession();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'];
      final errorMap = error is Map<String, dynamic> ? error : const <String, dynamic>{};
      throw AzulApiException(
        statusCode: response.statusCode,
        code: errorMap['code'] is String ? errorMap['code'] as String : 'HTTP_ERROR',
        message: errorMap['message'] is String ? errorMap['message'] as String : 'La API devolvió un error.',
      );
    }
    return decoded;
  }

  Future<String> _required(String key, String message) async {
    final value = await _storage.read(key: key);
    if (value == null || value.trim().isEmpty) throw StateError(message);
    return value;
  }

  bool _isUuid(String value) => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      ).hasMatch(value);

  static String newIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void dispose() => _http.close(force: true);
}
