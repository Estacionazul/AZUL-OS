import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../multidispositivo/azul_api_client.dart';

class ApiCentralInventoryScreen extends StatefulWidget {
  const ApiCentralInventoryScreen({super.key});

  @override
  State<ApiCentralInventoryScreen> createState() => _ApiCentralInventoryScreenState();
}

class _ApiCentralInventoryScreenState extends State<ApiCentralInventoryScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  bool _working = false;
  bool _lowOnly = false;
  String _itemType = 'todos';
  String? _error;
  String? _notice;
  List<Map<String, dynamic>> _items = [];
  int _total = 0;
  String? _pendingMovementKey;
  Map<String, Object?>? _pendingMovementBody;
  bool _pendingMovementRejected = false;
  bool _recoveryBlocked = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final pending = await context.read<AzulApiClient>().readPendingCentralInventoryMovement();
      if (pending != null && mounted) {
        final key = pending['idempotencyKey'];
        final body = pending['body'];
        if (key is String && body is Map<String, dynamic>) {
          setState(() {
            _pendingMovementKey = key;
            _pendingMovementBody = Map<String, Object?>.from(body);
            _notice = 'Se recuperó un movimiento de inventario pendiente. Reintenta la misma solicitud antes de registrar otra.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyError(e);
          _recoveryBlocked = true;
        });
      }
    }
    await _loadStock();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(Object? value, [String fallback = '—']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  String _quantity(Object? value) {
    final number = _number(value);
    return number == number.roundToDouble()
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Future<void> _showMovementHistory() async {
    setState(() {
      _working = true;
      if (!_recoveryBlocked) _error = null;
    });
    try {
      final response = await context.read<AzulApiClient>().getJson(
        '/api/v1/inventory/movements',
        query: const {'limit': '50', 'offset': '0'},
      );
      final items = response['items'];
      if (items is! List) {
        throw const FormatException('La API devolvió un historial de inventario inválido.');
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Movimientos de inventario central'),
          content: SizedBox(
            width: 720,
            height: 520,
            child: items.isEmpty
                ? const Center(child: Text('Todavía no hay movimientos centrales.'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final movement = items[index];
                      if (movement is! Map<String, dynamic>) return const SizedBox.shrink();
                      final delta = _number(movement['delta']);
                      return ListTile(
                        title: Text('${_text(movement['itemName'])} · ${_text(movement['type'])}'),
                        subtitle: Text('${_text(movement['date'])}\n${_text(movement['note'], 'Sin observación')}'),
                        isThreeLine: true,
                        trailing: Text(
                          '${delta > 0 ? '+' : ''}${_quantity(delta)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: delta < 0 ? Theme.of(context).colorScheme.error : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _loadStock() async {
    setState(() {
      _loading = true;
      if (!_recoveryBlocked) _error = null;
    });
    try {
      final response = await context.read<AzulApiClient>().getJson(
        '/api/v1/inventory/stock',
        query: {
          'itemType': _itemType,
          'lowStockOnly': _lowOnly ? 'true' : 'false',
          'limit': '100',
          'offset': '0',
          if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        },
      );
      final items = response['items'];
      if (items is! List) {
        throw const FormatException('La API devolvió un inventario con formato inválido.');
      }
      if (!mounted) return;
      setState(() {
        _items = items.whereType<Map<String, dynamic>>().toList();
        _total = _number((response['pagination'] as Map<String, dynamic>?)?['total']).toInt();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(e);
        _loading = false;
      });
    }
  }

  Future<void> _registerMovement(Map<String, dynamic> item) async {
    final quantityController = TextEditingController(text: '1');
    final noteController = TextEditingController();
    String movementType = 'ENTRADA';
    int adjustmentSign = 1;
    final formKey = GlobalKey<FormState>();
    final input = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Movimiento · ${_text(item['name'])}'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Stock actual: ${_quantity(item['currentStock'])} · mínimo: ${_quantity(item['minimumStock'])}'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: movementType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Tipo de movimiento'),
                    items: const [
                      DropdownMenuItem(value: 'ENTRADA', child: Text('Entrada')),
                      DropdownMenuItem(value: 'SALIDA', child: Text('Salida')),
                      DropdownMenuItem(value: 'AJUSTE', child: Text('Ajuste de inventario')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => movementType = value);
                    },
                  ),
                  if (movementType == 'AJUSTE')
                    DropdownButtonFormField<int>(
                      value: adjustmentSign,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'El ajuste'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Aumenta el stock')),
                        DropdownMenuItem(value: -1, child: Text('Disminuye el stock')),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => adjustmentSign = value);
                      },
                    ),
                  TextFormField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    validator: (value) {
                      final amount = double.tryParse((value ?? '').trim());
                      if (amount == null || !amount.isFinite || amount <= 0 ||
                          (amount * 10000).roundToDouble() != amount * 10000) {
                        return 'Ingresa una cantidad positiva (máximo 4 decimales).';
                      }
                      if ((movementType == 'SALIDA' || (movementType == 'AJUSTE' && adjustmentSign < 0)) &&
                          amount > _number(item['currentStock'])) {
                        return 'La cantidad supera el stock disponible.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: noteController,
                    maxLength: 500,
                    decoration: const InputDecoration(labelText: 'Motivo / observación'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, <String, Object?>{
                  'type': movementType,
                  'quantity': double.parse(quantityController.text.trim()),
                  'sign': movementType == 'AJUSTE' ? adjustmentSign : null,
                  'note': noteController.text.trim(),
                });
              },
              child: const Text('Registrar movimiento'),
            ),
          ],
        ),
      ),
    );
    quantityController.dispose();
    noteController.dispose();
    if (input == null || !mounted) return;

    final key = AzulApiClient.newIdempotencyKey();
    final body = <String, Object?>{
      'itemType': item['itemType'],
      'itemId': item['id'],
      'type': input['type'],
      'quantity': input['quantity'],
      if (input['sign'] != null) 'sign': input['sign'],
      if ((input['note'] as String).isNotEmpty) 'note': input['note'],
    };
    try {
      await context.read<AzulApiClient>().savePendingCentralInventoryMovement(
        idempotencyKey: key,
        body: body,
      );
      if (!mounted) return;
      setState(() {
        _pendingMovementKey = key;
        _pendingMovementBody = body;
        _pendingMovementRejected = false;
      });
      await _submitPendingMovement();
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    }
  }

  Future<void> _submitPendingMovement() async {
    final key = _pendingMovementKey;
    final body = _pendingMovementBody;
    if (key == null || body == null || _recoveryBlocked) return;
    await _runOperation(() async {
      final api = context.read<AzulApiClient>();
      await api.postJson(
        '/api/v1/inventory/movements',
        body: body,
        idempotencyKey: key,
      );
      await api.clearPendingCentralInventoryMovement();
      setState(() {
        _pendingMovementKey = null;
        _pendingMovementBody = null;
        _pendingMovementRejected = false;
        _notice = 'Movimiento central registrado correctamente.';
      });
      await _loadStock();
    });
  }

  Future<void> _discardRejectedMovement() async {
    if (_pendingMovementKey == null || !_pendingMovementRejected) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar movimiento rechazado'),
        content: const Text('El servidor rechazó el movimiento sin aplicarlo. Se eliminará la solicitud pendiente para permitir corregirla. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Volver')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AzulApiClient>().clearPendingCentralInventoryMovement();
    setState(() {
      _pendingMovementKey = null;
      _pendingMovementBody = null;
      _pendingMovementRejected = false;
      _error = null;
      _notice = 'Intento rechazado descartado. Puedes corregir el movimiento.';
    });
  }

  Future<void> _runOperation(Future<void> Function() operation) async {
    setState(() {
      _working = true;
      _error = null;
      _notice = null;
    });
    try {
      await operation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyError(e);
          _pendingMovementRejected = _pendingMovementKey != null &&
              e is AzulApiException &&
              (e.statusCode == 400 ||
               (e.statusCode == 409 && e.code != 'IDEMPOTENCY_CONFLICT'));
        });
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is AzulApiException) {
      switch (error.code) {
        case 'STOCK_INSUFFICIENT':
        case 'STOCK_INSUFFICIENTE':
          return error.message;
        case 'RECIPE_STOCK_CONTROLLED':
          return 'El stock de productos con receta se descuenta al vender; no admite ajustes manuales.';
        case 'IDEMPOTENCY_CONFLICT':
          return 'La operación ya tiene una clave usada con datos diferentes. Actualiza el inventario antes de repetir.';
        default:
          return 'API ${error.statusCode}: ${error.message}';
      }
    }
    if (error is FormatException) return error.message;
    if (error is StateError) return error.message;
    return 'No se pudo completar el movimiento. Actualiza el inventario y verifica el resultado antes de repetir.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AZUL OS · Inventario central'),
        actions: [
          IconButton(
            tooltip: 'Historial de movimientos',
            onPressed: _working ? null : _showMovementHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Actualizar inventario',
            onPressed: _working ? null : _loadStock,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Estos movimientos afectan solo al inventario central. El inventario local de la laptop permanece separado.',
              textAlign: TextAlign.center,
            ),
          ),
          if (_error != null) _banner(_error!, isError: true),
          if (_pendingMovementKey != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _working || _recoveryBlocked ? null : _submitPendingMovement,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reintentar movimiento pendiente'),
                  ),
                  if (_pendingMovementRejected)
                    OutlinedButton(
                      onPressed: _working ? null : _discardRejectedMovement,
                      child: const Text('Descartar intento rechazado'),
                    ),
                ],
              ),
            ),
          if (_recoveryBlocked)
            _banner('Se bloqueó el registro de movimientos porque no se pudo verificar la operación pendiente. Revisa el historial central antes de continuar.', isError: true),
          if (_notice != null) _banner(_notice!),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadStock(),
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto o insumo',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    value: _itemType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Tipo de artículo'),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Productos e insumos')),
                      DropdownMenuItem(value: 'producto', child: Text('Productos físicos')),
                      DropdownMenuItem(value: 'insumo', child: Text('Insumos')),
                    ],
                    onChanged: _working ? null : (value) {
                      if (value != null) setState(() => _itemType = value);
                      _loadStock();
                    },
                  ),
                ),
                FilterChip(
                  label: const Text('Solo stock bajo'),
                  selected: _lowOnly,
                  onSelected: _working ? null : (value) {
                    setState(() => _lowOnly = value);
                    _loadStock();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: _working ? null : _loadStock,
                  icon: const Icon(Icons.search),
                  label: const Text('Consultar'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('$_total artículos en el filtro · mostrando ${_items.length}'),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No hay artículos que coincidan con el filtro.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final low = item['lowStock'] == true;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(item['itemType'] == 'insumo' ? Icons.inventory_2 : Icons.local_cafe),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(_text(item['name']), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stock ${_quantity(item['currentStock'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: low ? Theme.of(context).colorScheme.error : null,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${_text(item['code'])} · ${_text(item['category'])}\n'
                                'Tipo: ${_text(item['itemType'])} · Mínimo: ${_quantity(item['minimumStock'])} · ${_text(item['status'])}',
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                tooltip: 'Registrar movimiento',
                                onPressed: _working || _recoveryBlocked || _pendingMovementKey != null ? null : () => _registerMovement(item),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _banner(String message, {bool isError = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isError ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );
}
