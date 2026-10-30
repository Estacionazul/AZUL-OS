import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'sync_config.dart';

typedef VentaHandler = Future<void> Function(Map<String, dynamic> venta);
typedef VentasProvider = Future<List<Map<String, dynamic>>> Function(
    DateTime? desde);

class SyncServer {
  SyncServer({required this.onVenta, this.ventasProvider});

  final VentaHandler onVenta;
  final VentasProvider? ventasProvider;
  HttpServer? _server;

  Future<void> start() async {
    if (_server != null) return;
    if (SyncConfig.token.isEmpty) {
      stderr.writeln('SyncServer: falta AZUL_SYNC_TOKEN, servidor no iniciado');
      return;
    }
    _server = await HttpServer.bind(
        InternetAddress.anyIPv4, SyncConfig.port, shared: true);
    _server!.listen(_handle, onError: (_) {});
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      if (req.headers.value('x-azul-token') != SyncConfig.token) {
        return _json(req, 401, {'error': 'no autorizado'});
      }
      final path = req.uri.path;

      if (req.method == 'GET' && path == '/ping') {
        return _json(req, 200, {'ok': true});
      }

      if (req.method == 'POST' && path == '/ventas') {
        if (req.contentLength > 1024 * 1024) {
          return _json(req, 413, {'error': 'payload muy grande'});
        }
        final raw = await utf8.decoder.bind(req).join();
        final data = jsonDecode(raw);
        if (data is! Map<String, dynamic>) {
          return _json(req, 400, {'error': 'JSON inválido'});
        }
        await onVenta(data);
        return _json(req, 200, {'ok': true, 'id': data['id']});
      }

      if (req.method == 'GET' && path == '/ventas' && ventasProvider != null) {
        final d = req.uri.queryParameters['desde'];
        final lista =
            await ventasProvider!(d == null ? null : DateTime.tryParse(d));
        return _json(req, 200, {'ventas': lista});
      }

      return _json(req, 404, {'error': 'no encontrado'});
    } catch (e) {
      return _json(req, 500, {'error': e.toString()});
    }
  }

  Future<void> _json(HttpRequest req, int status, Object body) async {
    req.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await req.response.close();
  }
}