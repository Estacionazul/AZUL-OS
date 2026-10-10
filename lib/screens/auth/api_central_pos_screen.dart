import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../multidispositivo/azul_api_client.dart';
import 'api_central_inventory_screen.dart';

class ApiCentralPosScreen extends StatefulWidget {
  const ApiCentralPosScreen({super.key});

  @override
  State<ApiCentralPosScreen> createState() => _ApiCentralPosScreenState();
}

class _ApiCentralPosScreenState extends State<ApiCentralPosScreen> {
  final _openingAmount = TextEditingController(text: '0.00');
  final _closingAmount = TextEditingController();
  final _search = TextEditingController();
  bool _loading = true;
  bool _working = false;
  String? _error;
  String? _notice;
  Map<String, dynamic>? _cash;
  List<Map<String, dynamic>> _products = [];
  final Map<String, int> _cart = <String, int>{};
  String _paymentMethod = 'Efectivo';
  bool _mixedPayment = false;
  String _mixedMethod1 = 'Efectivo';
  String _mixedMethod2 = 'Yape';
  final _mixedAmount1 = TextEditingController();
  final _mixedAmount2 = TextEditingController();
  String? _pendingSaleKey;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _openingAmount.dispose();
    _closingAmount.dispose();
    _search.dispose();
    _mixedAmount1.dispose();
    _mixedAmount2.dispose();
    super.dispose();
  }

  double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(Object? value) => 'S/ ${_number(value).toStringAsFixed(2)}';

  String _text(Object? value, [String fallback = '—']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  List<Map<String, dynamic>> get _cartProducts =>
      _products.where((p) => _cart.containsKey(p['id']?.toString())).toList();

  double get _total => _cartProducts.fold<double>(
        0,
        (sum, p) => sum + _number(p['salePrice']) * (_cart[p['id'].toString()] ?? 0),
      );

  static const _paymentMethods = <String>['Efectivo', 'Yape', 'Plin', 'Tarjeta'];

  Future<void> _showSalesHistory() async {
    setState(() {
      _working = true;
      _error = null;
      _notice = null;
    });
    try {
      final response = await context.read<AzulApiClient>().getJson(
        '/api/v1/sales',
        query: const {'limit': '50', 'offset': '0'},
      );
      final items = response['items'];
      if (items is! List) {
        throw const FormatException('La API devolvió un historial de ventas inválido.');
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Historial de ventas centrales'),
          content: SizedBox(
            width: 720,
            height: 520,
            child: items.isEmpty
                ? const Center(child: Text('Todavía no hay ventas centrales.'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final sale = items[index];
                      if (sale is! Map<String, dynamic>) return const SizedBox.shrink();
                      return ListTile(
                        title: Text('${_text(sale['numero'])} · ${_money(sale['total'])}'),
                        subtitle: Text('${_text(sale['documentType'])} · ${_text(sale['customerName'], 'Cliente general')}\n${_text(sale['paymentMethod'])} · ${_text(sale['fecha'])}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showSaleDetail(dialogContext, _text(sale['id'], '')),
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

  Future<void> _showSaleDetail(BuildContext dialogContext, String saleId) async {
    if (saleId.isEmpty) return;
    try {
      final response = await context.read<AzulApiClient>().getJson('/api/v1/sales/$saleId');
      final sale = response['sale'];
      final items = response['items'];
      final payments = response['payments'];
      final documents = response['documents'];
      if (sale is! Map<String, dynamic> || items is! List) {
        throw const FormatException('La API devolvió un detalle de venta inválido.');
      }
      if (!mounted) return;
      await showDialog<void>(
        context: dialogContext,
        builder: (detailContext) => AlertDialog(
          title: Text('Venta ${_text(sale['number'])}'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total: ${_money(sale['total'])}', style: Theme.of(detailContext).textTheme.titleLarge),
                  Text('Cliente: ${_text(sale['customerName'], 'Cliente general')}'),
                  Text('Medio de pago: ${_text(sale['paymentMethod'])}'),
                  const Divider(),
                  const Text('Productos', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...items.whereType<Map<String, dynamic>>().map((item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_text(item['productName'])),
                    subtitle: Text('${_number(item['quantity']).toStringAsFixed(0)} × ${_money(item['unitPrice'])}'),
                    trailing: Text(_money(item['subtotal'])),
                  )),
                  const Divider(),
                  const Text('Desglose de pagos', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (payments is List && payments.isNotEmpty)
                    ...payments.whereType<Map<String, dynamic>>().map((payment) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_text(payment['method'])),
                      trailing: Text(_money(payment['amount'])),
                    ))
                  else
                    const Text('No hay desglose disponible.'),
                  if (documents is List && documents.isNotEmpty) ...[
                    const Divider(),
                    const Text('Documentos electrónicos', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...documents.whereType<Map<String, dynamic>>().map((document) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${_text(document['type'])} ${_text(document['series'])}-${_text(document['number'])}'),
                      subtitle: Text('${_text(document['status'])} · ${_text(document['sunatMessage'], 'Sin mensaje SUNAT')}'),
                    )),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(detailContext), child: const Text('Cerrar detalle')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AzulApiClient>();
      final responses = await Future.wait([
        api.getJson('/api/v1/cash/current'),
        api.getJson('/api/v1/catalog/products', query: {
          'limit': '100',
          'offset': '0',
          if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        }),
      ]);
      final cashResponse = responses[0]['cashRegister'];
      final items = responses[1]['items'];
      if (cashResponse != null && cashResponse is! Map<String, dynamic>) {
        throw const FormatException('La API devolvió un estado de caja inválido.');
      }
      if (items is! List) {
        throw const FormatException('La API devolvió un catálogo inválido.');
      }
      if (!mounted) return;
      setState(() {
        _cash = cashResponse as Map<String, dynamic>?;
        _products = items.whereType<Map<String, dynamic>>().toList();
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

  Future<void> _openCash() async {
    final amount = double.tryParse(_openingAmount.text.trim());
    if (amount == null || !amount.isFinite || amount < 0 || (amount * 100).roundToDouble() != amount * 100) {
      setState(() => _error = 'Ingresa un monto inicial válido con máximo dos decimales.');
      return;
    }
    await _runOperation(() async {
      final result = await context.read<AzulApiClient>().postJson(
        '/api/v1/cash/open',
        body: {'openingAmount': amount},
      );
      setState(() {
        _cash = result['cashRegister'] as Map<String, dynamic>?;
        _notice = 'Caja central abierta correctamente.';
      });
    });
  }

  Future<void> _closeCash() async {
    final amount = double.tryParse(_closingAmount.text.trim());
    if (amount == null || !amount.isFinite || amount < 0 || (amount * 100).roundToDouble() != amount * 100) {
      setState(() => _error = 'Ingresa el efectivo contado con máximo dos decimales.');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar caja central'),
        content: Text('Se registrará el efectivo contado de ${_money(amount)}. Esta operación cierra la caja central. ¿Deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar caja')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await _runOperation(() async {
      final result = await context.read<AzulApiClient>().postJson(
        '/api/v1/cash/close',
        body: {'closingAmount': amount},
      );
      final reconciliation = result['reconciliation'];
      final expected = reconciliation is Map<String, dynamic> ? reconciliation['expectedCash'] : null;
      final difference = reconciliation is Map<String, dynamic> ? reconciliation['difference'] : null;
      setState(() {
        _cash = null;
        _closingAmount.clear();
        _notice = 'Caja cerrada. Efectivo esperado: ${_money(expected)} · Diferencia: ${_money(difference)}';
      });
      await _refresh();
    });
  }

  Future<void> _checkout() async {
    if (_cash == null) {
      setState(() => _error = 'Abre una caja central antes de cobrar.');
      return;
    }
    if (_cart.isEmpty || _total <= 0) {
      setState(() => _error = 'Agrega productos con importe mayor que cero a la venta.');
      return;
    }
    final items = _cart.entries.map((entry) => <String, Object?>{
      'productId': entry.key,
      'quantity': entry.value,
      'extraShot': false,
    }).toList(growable: false);
    List<Map<String, Object?>>? payments;
    if (_mixedPayment) {
      final amount1 = double.tryParse(_mixedAmount1.text.trim());
      final amount2 = double.tryParse(_mixedAmount2.text.trim());
      if (amount1 == null || amount2 == null ||
          !amount1.isFinite || !amount2.isFinite ||
          amount1 <= 0 || amount2 <= 0 ||
          (amount1 * 100).roundToDouble() != amount1 * 100 ||
          (amount2 * 100).roundToDouble() != amount2 * 100) {
        setState(() => _error = 'En el pago mixto, ambos importes deben ser positivos y tener máximo dos decimales.');
        return;
      }
      if (_mixedMethod1 == _mixedMethod2) {
        setState(() => _error = 'Selecciona dos medios de pago diferentes.');
        return;
      }
      if (((amount1 + amount2) * 100).round() != (_total * 100).round()) {
        setState(() => _error = 'El pago mixto debe sumar exactamente ${_money(_total)}.');
        return;
      }
      payments = [
        <String, Object?>{'method': _mixedMethod1, 'amount': amount1},
        <String, Object?>{'method': _mixedMethod2, 'amount': amount2},
      ];
    }
    final key = _pendingSaleKey ??= AzulApiClient.newIdempotencyKey();
    await _runOperation(() async {
      final result = await context.read<AzulApiClient>().postJson(
        '/api/v1/sales',
        idempotencyKey: key,
        body: {
          'items': items,
          if (_mixedPayment) 'paymentMethod': 'Mixto' else 'paymentMethod': _paymentMethod,
          if (payments != null) 'payments': payments,
          'discount': 0,
        },
      );
      final sale = result['sale'];
      if (sale is! Map<String, dynamic>) {
        throw const FormatException('La API no devolvió el comprobante de venta.');
      }
      final number = _text(sale['number']);
      final total = sale['total'];
      setState(() {
        _cart.clear();
        _pendingSaleKey = null;
        _notice = 'Venta central ${number} registrada por ${_money(total)}.';
      });
      await _refresh();
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
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is AzulApiException) {
      switch (error.code) {
        case 'NO_OPEN_CASH_REGISTER':
          return 'No hay caja central abierta. Abre una caja y vuelve a intentar.';
        case 'INSUFFICIENT_STOCK':
          return error.message;
        case 'PRODUCT_UNAVAILABLE':
          return 'Un producto ya no está disponible en el catálogo central. Actualiza la lista.';
        case 'PAYMENT_TOTAL_MISMATCH':
          return 'El desglose de pago no coincide con el total.';
        case 'IDEMPOTENCY_CONFLICT':
          return 'La clave de esta operación ya se usó con datos distintos. No repitas el cobro; verifica el historial central.';
        default:
          return 'API ${error.statusCode}: ${error.message}';
      }
    }
    if (error is FormatException) return error.message;
    if (error is StateError) return error.message;
    return 'No se pudo completar la operación. Verifica la conexión antes de volver a cobrar.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AZUL OS · Caja y ventas centrales'),
        actions: [
          IconButton(
            tooltip: 'Inventario central',
            onPressed: _working ? null : () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const ApiCentralInventoryScreen(),
              ));
            },
            icon: const Icon(Icons.inventory_2),
          ),
          IconButton(
            tooltip: 'Historial de ventas centrales',
            onPressed: _working ? null : _showSalesHistory,
            icon: const Icon(Icons.receipt_long),
          ),
          IconButton(
            tooltip: 'Actualizar estado central',
            onPressed: _working ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) _banner(_error!, isError: true),
                      if (_notice != null) _banner(_notice!),
                      _cashPanel(),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 820) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 3, child: _productPanel()),
                            SizedBox(width: 360, child: _cartPanel()),
                          ],
                        );
                      }
                      return ListView(
                        children: [
                          SizedBox(height: 420, child: _productPanel()),
                          SizedBox(height: 440, child: _cartPanel()),
                        ],
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Modo central de pruebas: no modifica ventas históricas ni la base SQLite local. No emite comprobantes SUNAT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _cashPanel() {
    final cash = _cash;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: cash == null
            ? Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.point_of_sale, size: 30),
                  const Text('No hay caja central abierta', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _openingAmount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monto inicial S/', isDense: true),
                    ),
                  ),
                  FilledButton(
                    onPressed: _working ? null : _openCash,
                    child: const Text('Abrir caja'),
                  ),
                ],
              )
            : Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.lock_open, color: Colors.green, size: 30),
                  Text('Caja abierta · Inicial ${_money(cash['openingAmount'])}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Apertura: ${_text(cash['openedAt'])}'),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _closingAmount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Efectivo contado S/', isDense: true),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _working || _pendingSaleKey != null ? null : _closeCash,
                    child: const Text('Cerrar caja'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _productPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _refresh(),
            decoration: InputDecoration(
              labelText: 'Buscar producto central',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Buscar',
                onPressed: _working ? null : _refresh,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        Expanded(
          child: _products.isEmpty
              ? const Center(child: Text('No hay productos activos en el catálogo central.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final id = product['id']?.toString() ?? '';
                    final quantity = _cart[id] ?? 0;
                    return Card(
                      child: ListTile(
                        leading: Text(_text(product['emoji'], '📦'), style: const TextStyle(fontSize: 25)),
                        title: Text(_text(product['name'])),
                        subtitle: Text('${_text(product['code'])} · ${_money(product['salePrice'])}'),
                        trailing: IconButton(
                          tooltip: 'Agregar al carrito',
                          onPressed: _working || _pendingSaleKey != null || _cash == null || id.isEmpty
                              ? null
                              : () => setState(() => _cart[id] = quantity + 1),
                          icon: const Icon(Icons.add_shopping_cart),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _cartPanel() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Venta central · ${_cart.values.fold<int>(0, (sum, quantity) => sum + quantity)} unidades',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            Expanded(
              child: _cartProducts.isEmpty
                  ? const Center(child: Text('Agrega productos desde el catálogo.'))
                  : ListView(
                      children: _cartProducts.map((product) {
                        final id = product['id'].toString();
                        final quantity = _cart[id] ?? 0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_text(product['name'])),
                          subtitle: Text('${quantity} × ${_money(product['salePrice'])}'),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Quitar una unidad',
                                onPressed: _working || _pendingSaleKey != null ? null : () => setState(() {
                                  if (quantity <= 1) {
                                    _cart.remove(id);
                                  } else {
                                    _cart[id] = quantity - 1;
                                  }
                                }),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              IconButton(
                                tooltip: 'Eliminar producto',
                                onPressed: _working || _pendingSaleKey != null ? null : () => setState(() => _cart.remove(id)),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total estimado', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_money(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pago mixto'),
              subtitle: const Text('Divide el total entre dos medios de pago.'),
              value: _mixedPayment,
              onChanged: _working || _pendingSaleKey != null ? null : (value) {
                setState(() {
                  _mixedPayment = value;
                  _error = null;
                  if (value) {
                    final firstAmount = ((_total * 100) / 2).round() / 100;
                    _mixedAmount1.text = (_total / 2).toStringAsFixed(2);
                    _mixedAmount2.text = (_total - firstAmount).toStringAsFixed(2);
                  }
                });
              },
            ),
            if (!_mixedPayment)
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Medio de pago', isDense: true),
                items: _paymentMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                onChanged: _working || _pendingSaleKey != null ? null : (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              )
            else ...[
              DropdownButtonFormField<String>(
                value: _mixedMethod1,
                decoration: const InputDecoration(labelText: 'Primer medio', isDense: true),
                items: _paymentMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                onChanged: _working || _pendingSaleKey != null ? null : (value) {
                  if (value != null) setState(() => _mixedMethod1 = value);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mixedAmount1,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Importe $_mixedMethod1', isDense: true),
                enabled: !_working && _pendingSaleKey == null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mixedMethod2,
                decoration: const InputDecoration(labelText: 'Segundo medio', isDense: true),
                items: _paymentMethods.map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                onChanged: _working || _pendingSaleKey != null ? null : (value) {
                  if (value != null) setState(() => _mixedMethod2 = value);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mixedAmount2,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Importe $_mixedMethod2', isDense: true),
                enabled: !_working && _pendingSaleKey == null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text('Distribuido: ${_money(_number(_mixedAmount1.text) + _number(_mixedAmount2.text))} de ${_money(_total)}'),
            ],
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _working || _cash == null || _cart.isEmpty ? null : _checkout,
              icon: _working
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.point_of_sale),
              label: Text(_working ? 'PROCESANDO...' : 'REGISTRAR VENTA CENTRAL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner(String message, {bool isError = false}) => Container(
        margin: const EdgeInsets.only(bottom: 8),
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
      );
}
