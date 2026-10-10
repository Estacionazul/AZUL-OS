import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../multidispositivo/azul_api_client.dart';

class ApiConnectionScreen extends StatefulWidget {
  const ApiConnectionScreen({super.key});

  @override
  State<ApiConnectionScreen> createState() => _ApiConnectionScreenState();
}

class _ApiConnectionScreenState extends State<ApiConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _establishmentController = TextEditingController();
  final _deviceController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _status;
  bool _success = false;
  bool _allowLocalHttp = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<AzulApiClient>();
    _urlController.text = await api.baseUrl ?? '';
    _establishmentController.text = await api.establishmentId ?? '';
    _deviceController.text = await api.deviceId ?? '';
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _establishmentController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Ingresa $label.';
    return null;
  }

  Future<void> _saveAndTest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _status = null;
    });
    try {
      final api = context.read<AzulApiClient>();
      await api.configure(
        baseUrl: _urlController.text,
        establishmentId: _establishmentController.text.trim(),
        deviceId: _deviceController.text.trim(),
        allowInsecureHttp: _allowLocalHttp,
      );
      final health = await api.checkHealth();
      if (!mounted) return;
      setState(() {
        _success = health['status'] == 'ready';
        _status = _success
            ? 'Conexión correcta. PostgreSQL responde y la API está lista.'
            : 'La API respondió, pero todavía no está lista para operar.';
      });
    } on AzulApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _success = false;
        _status = 'API ${error.statusCode}: ${error.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _success = false;
        _status = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conexión multidispositivo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.devices_rounded, size: 52),
                            const SizedBox(height: 12),
                            const Text(
                              'Configurar servidor AZUL OS',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Estos datos se guardan de forma segura en este equipo. Usa la URL HTTPS del servidor y los UUID que entrega la administración del CEO.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _urlController,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                labelText: 'URL base de la API',
                                hintText: 'https://api.tudominio.pe',
                              ),
                              validator: (value) => _required(value, 'la URL de la API'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _establishmentController,
                              decoration: const InputDecoration(labelText: 'UUID del establecimiento'),
                              validator: (value) => _required(value, 'el UUID del establecimiento'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _deviceController,
                              decoration: const InputDecoration(labelText: 'UUID de este dispositivo'),
                              validator: (value) => _required(value, 'el UUID del dispositivo'),
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _allowLocalHttp,
                              onChanged: _saving ? null : (value) => setState(() => _allowLocalHttp = value ?? false),
                              title: const Text('Permitir HTTP solo para pruebas locales'),
                              subtitle: const Text('Solo acepta localhost, 127.0.0.1 o el emulador Android 10.0.2.2.'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _saving ? null : _saveAndTest,
                              icon: _saving
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.wifi_tethering_rounded),
                              label: Text(_saving ? 'COMPROBANDO...' : 'GUARDAR Y PROBAR CONEXIÓN'),
                            ),
                            if (_status != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _success ? Colors.green.withValues(alpha: 0.10) : Theme.of(context).colorScheme.errorContainer,
                                ),
                                child: Text(_status!, style: TextStyle(
                                  color: _success ? Colors.green.shade800 : Theme.of(context).colorScheme.onErrorContainer,
                                )),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Text(
                              'Importante: esta pantalla solo configura y prueba la conexión. No cambia el sistema de ventas local ni sincroniza datos históricos.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
