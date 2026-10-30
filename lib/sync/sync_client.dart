import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'sync_config.dart';

class SyncClient {
  String? _base;

  Future<({int status, String body})> _send(String method, String url,
      {String? body}) async {
    final c = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final r = await c.openUrl(method, Uri.parse(url));
      r.headers.set('x-azul-token', SyncConfig.token);
      r.headers.contentType = ContentType.json;
      if (body != null) r.add(utf8.encode(body));
      final resp = await r.close().timeout(const Duration(seconds: 10));
      final text = await utf8.decoder.bind(resp).join();
      return (status: resp.statusCode, body: text);
    } finally {
      c.close(force: true);
    }
  }

  /// Prueba Wi-Fi local primero y luego Tailscale.
  Future<String?> _resolve() async {
    for (final host in SyncConfig.hosts) {
      final base = 'http://$host:${SyncConfig.port}';
      try {
        final r = await _send('GET', '$base/ping');
        if (r.status == 200) return _base = base;
      } catch (_) {}
    }
    return _base = null;
  }

  /// true = la PC confirmó la venta. false = reintentar luego.
  Future<bool> enviarVenta(Map<String, dynamic> venta) async {
    for (var intento = 0; intento < 2; intento++) {
      final base = _base ?? await _resolve();
      if (base == null) return false;
      try {
        final r = await _send('POST', '$base/ventas', body: jsonEncode(venta));
        if (r.status == 200) return true;
        if (r.status >= 400 && r.status < 500) return false;
      } catch (_) {
        _base = null;
      }
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> obtenerVentas({DateTime? desde}) async {
    final base = _base ?? await _resolve();
    if (base == null) return [];
    final q = desde == null ? '' : '?desde=${desde.toUtc().toIso8601String()}';
    final r = await _send('GET', '$base/ventas$q');
    if (r.status != 200) return [];
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(j['ventas'] as List);
  }
}