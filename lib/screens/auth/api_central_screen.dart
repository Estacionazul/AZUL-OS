import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../multidispositivo/azul_api_client.dart';

class ApiCentralScreen extends StatefulWidget {
  const ApiCentralScreen({super.key});

  @override
  State<ApiCentralScreen> createState() => _ApiCentralScreenState();
}

class _ApiCentralScreenState extends State<ApiCentralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _pin = TextEditingController();
  final _search = TextEditingController();

  bool _checking = true;
  bool _working = false;
  bool _showPin = false;
  String? _error;
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _username.dispose();
    _pin.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final api = context.read<AzulApiClient>();
    try {
      if (await api.hasSession) {
        final profile = await api.me();
        final user = profile['user'];
        if (user is Map<String, dynamic>) {
          _user = user;
          await _loadCatalog();
        }
      }
    } on AzulApiException catch (e) {
      if (e.statusCode != 401) _error = e.message;
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final result = await context.read<AzulApiClient>().login(
        username: _username.text.trim(),
        pin: _pin.text,
      );
      final user = result['user'];
      if (user is! Map<String, dynamic>) {
        await context.read<AzulApiClient>().clearSession();
        throw const FormatException('La API no devolvió los datos del usuario.');
      }
      _user = user;
      await _loadCatalog();
    } catch (e) {
      _user = null;
      _error = _friendlyError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _loadCatalog() async {
    final api = context.read<AzulApiClient>();
    final responses = await Future.wait([
      api.getJson('/api/v1/catalog/categories'),
      api.getJson('/api/v1/catalog/products', query: {
        'limit': '100',
        'offset': '0',
        if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        if (_categoryId != null) 'categoryId': _categoryId!,
      }),
    ]);
    final categories = responses[0]['items'];
    final products = responses[1]['items'];
    if (categories is! List || products is! List) {
      throw const FormatException('La API devolvió un catálogo con formato inválido.');
    }
    _categories = categories.whereType<Map<String, dynamic>>().toList();
    _products = products.whereType<Map<String, dynamic>>().toList();
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await _loadCatalog();
    } catch (e) {
      _error = _friendlyError(e);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _working = true);
    try {
      await context.read<AzulApiClient>().logout();
    } catch (_) {
      await context.read<AzulApiClient>().clearSession();
    }
    if (!mounted) return;
    setState(() {
      _user = null;
      _products = [];
      _categories = [];
      _pin.clear();
      _error = null;
      _working = false;
    });
  }

  String _friendlyError(Object e) {
    if (e is AzulApiException) {
      if (e.statusCode == 401) return 'Credenciales incorrectas o dispositivo no autorizado.';
      if (e.statusCode == 403) return 'Tu usuario no tiene permiso para consultar el catálogo central.';
      return 'API ${e.statusCode}: ${e.message}';
    }
    if (e is FormatException) return e.message;
    if (e is StateError) return e.message;
    return 'No se pudo conectar. Verifica la configuración y el servidor.';
  }

  String _value(Object? value, [String fallback = '—']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _money(Object? value) {
    final n = value is num ? value : num.tryParse(value?.toString() ?? '');
    return n == null ? 'S/ —' : 'S/ ${n.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final user = _user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AZUL OS · Servidor central'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Cerrar sesión central',
              onPressed: _working ? null : _logout,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: user == null ? _loginForm() : _catalog(user),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.cloud_sync_rounded, size: 56),
                  const SizedBox(height: 12),
                  const Text('Iniciar sesión central',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Usa el usuario y PIN creados en la administración central. No se utiliza ni modifica el usuario local de esta laptop.',
                    textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _username,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Usuario central',
                      prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingresa el usuario central.' : null),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pin,
                    obscureText: !_showPin,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'PIN de cuatro dígitos',
                      prefixIcon: const Icon(Icons.lock_outline),
                      counterText: '',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _showPin = !_showPin),
                        icon: Icon(_showPin ? Icons.visibility_off : Icons.visibility))),
                    validator: (v) => v == null || !RegExp(r'^\d{4}$').hasMatch(v)
                      ? 'El PIN debe tener cuatro dígitos.' : null),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _errorBanner(_error!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _working ? null : _login,
                    icon: _working
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login_rounded),
                    label: Text(_working ? 'CONECTANDO...' : 'INGRESAR AL SERVIDOR')),
                  const SizedBox(height: 14),
                  const Text(
                    'Esta etapa consulta el catálogo central en modo lectura. Las ventas e inventario locales siguen separados hasta completar su integración y la migración histórica.',
                    style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _catalog(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.cloud_done_rounded)),
              title: Text(_value(user['name'], _value(user['username'], 'Usuario central')),
                style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Rol: ${_value(user['role'])} · Catálogo central en lectura'),
              trailing: IconButton(
                tooltip: 'Actualizar catálogo',
                onPressed: _working ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _refresh(),
                  decoration: InputDecoration(
                    labelText: 'Buscar producto central',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: _working ? null : () { _search.clear(); _refresh(); },
                      icon: const Icon(Icons.clear_rounded)))),
              ),
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<String>(
                  value: _categoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categoría central'),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Todas las categorías')),
                    ..._categories.map((c) => DropdownMenuItem<String>(
                      value: _value(c['id'], ''),
                      child: Text(_value(c['name'])))),
                  ],
                  onChanged: _working ? null : (v) { setState(() => _categoryId = v); _refresh(); },
                ),
              ),
            ],
          ),
        ),
        if (_error != null) Padding(
          padding: const EdgeInsets.all(20), child: _errorBanner(_error!)),
        Expanded(
          child: _working && _products.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
              ? const Center(child: Text('No hay productos en el catálogo central.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = _products[i];
                    return Card(
                      child: ListTile(
                        leading: Text(_value(p['emoji'], '📦'), style: const TextStyle(fontSize: 28)),
                        title: Text(_value(p['name'])),
                        subtitle: Text(
                          '${_value(p['code'])} · ${_value(p['categoryName'])}\n'
                          'Tipo: ${_value(p['inventoryType'])} · IGV: ${_value(p['igvAffectation'])}'),
                        isThreeLine: true,
                        trailing: Text(_money(p['salePrice']),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            '${_products.length} productos · ${_categories.length} categorías · Solo lectura',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget _errorBanner(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(8)),
    child: Text(message, style: TextStyle(
      color: Theme.of(context).colorScheme.onErrorContainer)));
}
