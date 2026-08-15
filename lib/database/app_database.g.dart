// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _codigoBarrasMeta = const VerificationMeta(
    'codigoBarras',
  );
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
    'codigo_barras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<double> costo = GeneratedColumn<double>(
    'costo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tipoInventarioMeta = const VerificationMeta(
    'tipoInventario',
  );
  @override
  late final GeneratedColumn<String> tipoInventario = GeneratedColumn<String>(
    'tipo_inventario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('receta'),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📦'),
  );
  static const VerificationMeta _imagenMeta = const VerificationMeta('imagen');
  @override
  late final GeneratedColumn<String> imagen = GeneratedColumn<String>(
    'imagen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>(
        'fecha_creacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    codigoBarras,
    nombre,
    descripcion,
    categoriaId,
    costo,
    precioVenta,
    stock,
    stockMinimo,
    tipoInventario,
    emoji,
    imagen,
    activo,
    fechaCreacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
        _codigoBarrasMeta,
        codigoBarras.isAcceptableOrUnknown(
          data['codigo_barras']!,
          _codigoBarrasMeta,
        ),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    } else if (isInserting) {
      context.missing(_costoMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('tipo_inventario')) {
      context.handle(
        _tipoInventarioMeta,
        tipoInventario.isAcceptableOrUnknown(
          data['tipo_inventario']!,
          _tipoInventarioMeta,
        ),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('imagen')) {
      context.handle(
        _imagenMeta,
        imagen.isAcceptableOrUnknown(data['imagen']!, _imagenMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      codigoBarras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_barras'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_minimo'],
      )!,
      tipoInventario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_inventario'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      imagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_creacion'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final int id;
  final String codigo;
  final String? codigoBarras;
  final String nombre;
  final String descripcion;
  final int categoriaId;
  final double costo;
  final double precioVenta;
  final int stock;
  final int stockMinimo;
  final String tipoInventario;
  final String emoji;
  final String imagen;
  final bool activo;
  final DateTime fechaCreacion;
  const Producto({
    required this.id,
    required this.codigo,
    this.codigoBarras,
    required this.nombre,
    required this.descripcion,
    required this.categoriaId,
    required this.costo,
    required this.precioVenta,
    required this.stock,
    required this.stockMinimo,
    required this.tipoInventario,
    required this.emoji,
    required this.imagen,
    required this.activo,
    required this.fechaCreacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['nombre'] = Variable<String>(nombre);
    map['descripcion'] = Variable<String>(descripcion);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['costo'] = Variable<double>(costo);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['stock'] = Variable<int>(stock);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    map['tipo_inventario'] = Variable<String>(tipoInventario);
    map['emoji'] = Variable<String>(emoji);
    map['imagen'] = Variable<String>(imagen);
    map['activo'] = Variable<bool>(activo);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      categoriaId: Value(categoriaId),
      costo: Value(costo),
      precioVenta: Value(precioVenta),
      stock: Value(stock),
      stockMinimo: Value(stockMinimo),
      tipoInventario: Value(tipoInventario),
      emoji: Value(emoji),
      imagen: Value(imagen),
      activo: Value(activo),
      fechaCreacion: Value(fechaCreacion),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      costo: serializer.fromJson<double>(json['costo']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      stock: serializer.fromJson<int>(json['stock']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      tipoInventario: serializer.fromJson<String>(json['tipoInventario']),
      emoji: serializer.fromJson<String>(json['emoji']),
      imagen: serializer.fromJson<String>(json['imagen']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String>(descripcion),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'costo': serializer.toJson<double>(costo),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'stock': serializer.toJson<int>(stock),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'tipoInventario': serializer.toJson<String>(tipoInventario),
      'emoji': serializer.toJson<String>(emoji),
      'imagen': serializer.toJson<String>(imagen),
      'activo': serializer.toJson<bool>(activo),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
    };
  }

  Producto copyWith({
    int? id,
    String? codigo,
    Value<String?> codigoBarras = const Value.absent(),
    String? nombre,
    String? descripcion,
    int? categoriaId,
    double? costo,
    double? precioVenta,
    int? stock,
    int? stockMinimo,
    String? tipoInventario,
    String? emoji,
    String? imagen,
    bool? activo,
    DateTime? fechaCreacion,
  }) => Producto(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    codigoBarras: codigoBarras.present ? codigoBarras.value : this.codigoBarras,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    categoriaId: categoriaId ?? this.categoriaId,
    costo: costo ?? this.costo,
    precioVenta: precioVenta ?? this.precioVenta,
    stock: stock ?? this.stock,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    tipoInventario: tipoInventario ?? this.tipoInventario,
    emoji: emoji ?? this.emoji,
    imagen: imagen ?? this.imagen,
    activo: activo ?? this.activo,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      costo: data.costo.present ? data.costo.value : this.costo,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      stock: data.stock.present ? data.stock.value : this.stock,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      tipoInventario: data.tipoInventario.present
          ? data.tipoInventario.value
          : this.tipoInventario,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      imagen: data.imagen.present ? data.imagen.value : this.imagen,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('costo: $costo, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('tipoInventario: $tipoInventario, ')
          ..write('emoji: $emoji, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    codigoBarras,
    nombre,
    descripcion,
    categoriaId,
    costo,
    precioVenta,
    stock,
    stockMinimo,
    tipoInventario,
    emoji,
    imagen,
    activo,
    fechaCreacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.codigoBarras == this.codigoBarras &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.categoriaId == this.categoriaId &&
          other.costo == this.costo &&
          other.precioVenta == this.precioVenta &&
          other.stock == this.stock &&
          other.stockMinimo == this.stockMinimo &&
          other.tipoInventario == this.tipoInventario &&
          other.emoji == this.emoji &&
          other.imagen == this.imagen &&
          other.activo == this.activo &&
          other.fechaCreacion == this.fechaCreacion);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String?> codigoBarras;
  final Value<String> nombre;
  final Value<String> descripcion;
  final Value<int> categoriaId;
  final Value<double> costo;
  final Value<double> precioVenta;
  final Value<int> stock;
  final Value<int> stockMinimo;
  final Value<String> tipoInventario;
  final Value<String> emoji;
  final Value<String> imagen;
  final Value<bool> activo;
  final Value<DateTime> fechaCreacion;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.costo = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.tipoInventario = const Value.absent(),
    this.emoji = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    this.codigoBarras = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
    required int categoriaId,
    required double costo,
    required double precioVenta,
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.tipoInventario = const Value.absent(),
    this.emoji = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre),
       categoriaId = Value(categoriaId),
       costo = Value(costo),
       precioVenta = Value(precioVenta);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? codigoBarras,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<int>? categoriaId,
    Expression<double>? costo,
    Expression<double>? precioVenta,
    Expression<int>? stock,
    Expression<int>? stockMinimo,
    Expression<String>? tipoInventario,
    Expression<String>? emoji,
    Expression<String>? imagen,
    Expression<bool>? activo,
    Expression<DateTime>? fechaCreacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (costo != null) 'costo': costo,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (stock != null) 'stock': stock,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (tipoInventario != null) 'tipo_inventario': tipoInventario,
      if (emoji != null) 'emoji': emoji,
      if (imagen != null) 'imagen': imagen,
      if (activo != null) 'activo': activo,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
    });
  }

  ProductosCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String?>? codigoBarras,
    Value<String>? nombre,
    Value<String>? descripcion,
    Value<int>? categoriaId,
    Value<double>? costo,
    Value<double>? precioVenta,
    Value<int>? stock,
    Value<int>? stockMinimo,
    Value<String>? tipoInventario,
    Value<String>? emoji,
    Value<String>? imagen,
    Value<bool>? activo,
    Value<DateTime>? fechaCreacion,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      costo: costo ?? this.costo,
      precioVenta: precioVenta ?? this.precioVenta,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      tipoInventario: tipoInventario ?? this.tipoInventario,
      emoji: emoji ?? this.emoji,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (costo.present) {
      map['costo'] = Variable<double>(costo.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (tipoInventario.present) {
      map['tipo_inventario'] = Variable<String>(tipoInventario.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (imagen.present) {
      map['imagen'] = Variable<String>(imagen.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('costo: $costo, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('tipoInventario: $tipoInventario, ')
          ..write('emoji: $emoji, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _iconoMeta = const VerificationMeta('icono');
  @override
  late final GeneratedColumn<String> icono = GeneratedColumn<String>(
    'icono',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📦'),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, icono, orden, activo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('icono')) {
      context.handle(
        _iconoMeta,
        icono.isAcceptableOrUnknown(data['icono']!, _iconoMeta),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      icono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icono'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;
  final String icono;
  final int orden;
  final bool activo;
  const Categoria({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.orden,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['icono'] = Variable<String>(icono);
    map['orden'] = Variable<int>(orden);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      icono: Value(icono),
      orden: Value(orden),
      activo: Value(activo),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      icono: serializer.fromJson<String>(json['icono']),
      orden: serializer.fromJson<int>(json['orden']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'icono': serializer.toJson<String>(icono),
      'orden': serializer.toJson<int>(orden),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    String? icono,
    int? orden,
    bool? activo,
  }) => Categoria(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    icono: icono ?? this.icono,
    orden: orden ?? this.orden,
    activo: activo ?? this.activo,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      icono: data.icono.present ? data.icono.value : this.icono,
      orden: data.orden.present ? data.orden.value : this.orden,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('icono: $icono, ')
          ..write('orden: $orden, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, icono, orden, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.icono == this.icono &&
          other.orden == this.orden &&
          other.activo == this.activo);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> icono;
  final Value<int> orden;
  final Value<bool> activo;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.icono = const Value.absent(),
    this.orden = const Value.absent(),
    this.activo = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.icono = const Value.absent(),
    this.orden = const Value.absent(),
    this.activo = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? icono,
    Expression<int>? orden,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (icono != null) 'icono': icono,
      if (orden != null) 'orden': orden,
      if (activo != null) 'activo': activo,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? icono,
    Value<int>? orden,
    Value<bool>? activo,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (icono.present) {
      map['icono'] = Variable<String>(icono.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('icono: $icono, ')
          ..write('orden: $orden, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $InsumosTable extends Insumos with TableInfo<$InsumosTable, Insumo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsumosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadMedidaMeta = const VerificationMeta(
    'unidadMedida',
  );
  @override
  late final GeneratedColumn<String> unidadMedida = GeneratedColumn<String>(
    'unidad_medida',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<double> stockMinimo = GeneratedColumn<double>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costoCompraMeta = const VerificationMeta(
    'costoCompra',
  );
  @override
  late final GeneratedColumn<double> costoCompra = GeneratedColumn<double>(
    'costo_compra',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📦'),
  );
  static const VerificationMeta _imagenMeta = const VerificationMeta('imagen');
  @override
  late final GeneratedColumn<String> imagen = GeneratedColumn<String>(
    'imagen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>(
        'fecha_creacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigo,
    nombre,
    descripcion,
    categoriaId,
    unidadMedida,
    stock,
    stockMinimo,
    costoCompra,
    emoji,
    imagen,
    activo,
    fechaCreacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insumos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Insumo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('unidad_medida')) {
      context.handle(
        _unidadMedidaMeta,
        unidadMedida.isAcceptableOrUnknown(
          data['unidad_medida']!,
          _unidadMedidaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unidadMedidaMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('costo_compra')) {
      context.handle(
        _costoCompraMeta,
        costoCompra.isAcceptableOrUnknown(
          data['costo_compra']!,
          _costoCompraMeta,
        ),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('imagen')) {
      context.handle(
        _imagenMeta,
        imagen.isAcceptableOrUnknown(data['imagen']!, _imagenMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Insumo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Insumo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      unidadMedida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad_medida'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_minimo'],
      )!,
      costoCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_compra'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      imagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_creacion'],
      )!,
    );
  }

  @override
  $InsumosTable createAlias(String alias) {
    return $InsumosTable(attachedDatabase, alias);
  }
}

class Insumo extends DataClass implements Insertable<Insumo> {
  final int id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final int categoriaId;
  final String unidadMedida;
  final double stock;
  final double stockMinimo;
  final double costoCompra;
  final String emoji;
  final String imagen;
  final bool activo;
  final DateTime fechaCreacion;
  const Insumo({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.categoriaId,
    required this.unidadMedida,
    required this.stock,
    required this.stockMinimo,
    required this.costoCompra,
    required this.emoji,
    required this.imagen,
    required this.activo,
    required this.fechaCreacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['nombre'] = Variable<String>(nombre);
    map['descripcion'] = Variable<String>(descripcion);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['unidad_medida'] = Variable<String>(unidadMedida);
    map['stock'] = Variable<double>(stock);
    map['stock_minimo'] = Variable<double>(stockMinimo);
    map['costo_compra'] = Variable<double>(costoCompra);
    map['emoji'] = Variable<String>(emoji);
    map['imagen'] = Variable<String>(imagen);
    map['activo'] = Variable<bool>(activo);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    return map;
  }

  InsumosCompanion toCompanion(bool nullToAbsent) {
    return InsumosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      categoriaId: Value(categoriaId),
      unidadMedida: Value(unidadMedida),
      stock: Value(stock),
      stockMinimo: Value(stockMinimo),
      costoCompra: Value(costoCompra),
      emoji: Value(emoji),
      imagen: Value(imagen),
      activo: Value(activo),
      fechaCreacion: Value(fechaCreacion),
    );
  }

  factory Insumo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Insumo(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      unidadMedida: serializer.fromJson<String>(json['unidadMedida']),
      stock: serializer.fromJson<double>(json['stock']),
      stockMinimo: serializer.fromJson<double>(json['stockMinimo']),
      costoCompra: serializer.fromJson<double>(json['costoCompra']),
      emoji: serializer.fromJson<String>(json['emoji']),
      imagen: serializer.fromJson<String>(json['imagen']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String>(descripcion),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'unidadMedida': serializer.toJson<String>(unidadMedida),
      'stock': serializer.toJson<double>(stock),
      'stockMinimo': serializer.toJson<double>(stockMinimo),
      'costoCompra': serializer.toJson<double>(costoCompra),
      'emoji': serializer.toJson<String>(emoji),
      'imagen': serializer.toJson<String>(imagen),
      'activo': serializer.toJson<bool>(activo),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
    };
  }

  Insumo copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    int? categoriaId,
    String? unidadMedida,
    double? stock,
    double? stockMinimo,
    double? costoCompra,
    String? emoji,
    String? imagen,
    bool? activo,
    DateTime? fechaCreacion,
  }) => Insumo(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    categoriaId: categoriaId ?? this.categoriaId,
    unidadMedida: unidadMedida ?? this.unidadMedida,
    stock: stock ?? this.stock,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    costoCompra: costoCompra ?? this.costoCompra,
    emoji: emoji ?? this.emoji,
    imagen: imagen ?? this.imagen,
    activo: activo ?? this.activo,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
  );
  Insumo copyWithCompanion(InsumosCompanion data) {
    return Insumo(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      unidadMedida: data.unidadMedida.present
          ? data.unidadMedida.value
          : this.unidadMedida,
      stock: data.stock.present ? data.stock.value : this.stock,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      costoCompra: data.costoCompra.present
          ? data.costoCompra.value
          : this.costoCompra,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      imagen: data.imagen.present ? data.imagen.value : this.imagen,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Insumo(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('costoCompra: $costoCompra, ')
          ..write('emoji: $emoji, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigo,
    nombre,
    descripcion,
    categoriaId,
    unidadMedida,
    stock,
    stockMinimo,
    costoCompra,
    emoji,
    imagen,
    activo,
    fechaCreacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insumo &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.categoriaId == this.categoriaId &&
          other.unidadMedida == this.unidadMedida &&
          other.stock == this.stock &&
          other.stockMinimo == this.stockMinimo &&
          other.costoCompra == this.costoCompra &&
          other.emoji == this.emoji &&
          other.imagen == this.imagen &&
          other.activo == this.activo &&
          other.fechaCreacion == this.fechaCreacion);
}

class InsumosCompanion extends UpdateCompanion<Insumo> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<String> nombre;
  final Value<String> descripcion;
  final Value<int> categoriaId;
  final Value<String> unidadMedida;
  final Value<double> stock;
  final Value<double> stockMinimo;
  final Value<double> costoCompra;
  final Value<String> emoji;
  final Value<String> imagen;
  final Value<bool> activo;
  final Value<DateTime> fechaCreacion;
  const InsumosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.unidadMedida = const Value.absent(),
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.costoCompra = const Value.absent(),
    this.emoji = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  });
  InsumosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required String nombre,
    this.descripcion = const Value.absent(),
    required int categoriaId,
    required String unidadMedida,
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.costoCompra = const Value.absent(),
    this.emoji = const Value.absent(),
    this.imagen = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  }) : codigo = Value(codigo),
       nombre = Value(nombre),
       categoriaId = Value(categoriaId),
       unidadMedida = Value(unidadMedida);
  static Insertable<Insumo> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<int>? categoriaId,
    Expression<String>? unidadMedida,
    Expression<double>? stock,
    Expression<double>? stockMinimo,
    Expression<double>? costoCompra,
    Expression<String>? emoji,
    Expression<String>? imagen,
    Expression<bool>? activo,
    Expression<DateTime>? fechaCreacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
      if (stock != null) 'stock': stock,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (costoCompra != null) 'costo_compra': costoCompra,
      if (emoji != null) 'emoji': emoji,
      if (imagen != null) 'imagen': imagen,
      if (activo != null) 'activo': activo,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
    });
  }

  InsumosCompanion copyWith({
    Value<int>? id,
    Value<String>? codigo,
    Value<String>? nombre,
    Value<String>? descripcion,
    Value<int>? categoriaId,
    Value<String>? unidadMedida,
    Value<double>? stock,
    Value<double>? stockMinimo,
    Value<double>? costoCompra,
    Value<String>? emoji,
    Value<String>? imagen,
    Value<bool>? activo,
    Value<DateTime>? fechaCreacion,
  }) {
    return InsumosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      costoCompra: costoCompra ?? this.costoCompra,
      emoji: emoji ?? this.emoji,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (unidadMedida.present) {
      map['unidad_medida'] = Variable<String>(unidadMedida.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<double>(stockMinimo.value);
    }
    if (costoCompra.present) {
      map['costo_compra'] = Variable<double>(costoCompra.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (imagen.present) {
      map['imagen'] = Variable<String>(imagen.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsumosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('costoCompra: $costoCompra, ')
          ..write('emoji: $emoji, ')
          ..write('imagen: $imagen, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }
}

class $RecetasTable extends Recetas with TableInfo<$RecetasTable, Receta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>(
        'fecha_creacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productoId,
    nombre,
    activo,
    fechaCreacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recetas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Receta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_creacion'],
      )!,
    );
  }

  @override
  $RecetasTable createAlias(String alias) {
    return $RecetasTable(attachedDatabase, alias);
  }
}

class Receta extends DataClass implements Insertable<Receta> {
  final int id;
  final int productoId;
  final String nombre;
  final bool activo;
  final DateTime fechaCreacion;
  const Receta({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.activo,
    required this.fechaCreacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre'] = Variable<String>(nombre);
    map['activo'] = Variable<bool>(activo);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    return map;
  }

  RecetasCompanion toCompanion(bool nullToAbsent) {
    return RecetasCompanion(
      id: Value(id),
      productoId: Value(productoId),
      nombre: Value(nombre),
      activo: Value(activo),
      fechaCreacion: Value(fechaCreacion),
    );
  }

  factory Receta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receta(
      id: serializer.fromJson<int>(json['id']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productoId': serializer.toJson<int>(productoId),
      'nombre': serializer.toJson<String>(nombre),
      'activo': serializer.toJson<bool>(activo),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
    };
  }

  Receta copyWith({
    int? id,
    int? productoId,
    String? nombre,
    bool? activo,
    DateTime? fechaCreacion,
  }) => Receta(
    id: id ?? this.id,
    productoId: productoId ?? this.productoId,
    nombre: nombre ?? this.nombre,
    activo: activo ?? this.activo,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
  );
  Receta copyWithCompanion(RecetasCompanion data) {
    return Receta(
      id: data.id.present ? data.id.value : this.id,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receta(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productoId, nombre, activo, fechaCreacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receta &&
          other.id == this.id &&
          other.productoId == this.productoId &&
          other.nombre == this.nombre &&
          other.activo == this.activo &&
          other.fechaCreacion == this.fechaCreacion);
}

class RecetasCompanion extends UpdateCompanion<Receta> {
  final Value<int> id;
  final Value<int> productoId;
  final Value<String> nombre;
  final Value<bool> activo;
  final Value<DateTime> fechaCreacion;
  const RecetasCompanion({
    this.id = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  });
  RecetasCompanion.insert({
    this.id = const Value.absent(),
    required int productoId,
    required String nombre,
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  }) : productoId = Value(productoId),
       nombre = Value(nombre);
  static Insertable<Receta> custom({
    Expression<int>? id,
    Expression<int>? productoId,
    Expression<String>? nombre,
    Expression<bool>? activo,
    Expression<DateTime>? fechaCreacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productoId != null) 'producto_id': productoId,
      if (nombre != null) 'nombre': nombre,
      if (activo != null) 'activo': activo,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
    });
  }

  RecetasCompanion copyWith({
    Value<int>? id,
    Value<int>? productoId,
    Value<String>? nombre,
    Value<bool>? activo,
    Value<DateTime>? fechaCreacion,
  }) {
    return RecetasCompanion(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecetasCompanion(')
          ..write('id: $id, ')
          ..write('productoId: $productoId, ')
          ..write('nombre: $nombre, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }
}

class $RecetaDetalleTable extends RecetaDetalle
    with TableInfo<$RecetaDetalleTable, RecetaDetalleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecetaDetalleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recetaIdMeta = const VerificationMeta(
    'recetaId',
  );
  @override
  late final GeneratedColumn<int> recetaId = GeneratedColumn<int>(
    'receta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insumoIdMeta = const VerificationMeta(
    'insumoId',
  );
  @override
  late final GeneratedColumn<int> insumoId = GeneratedColumn<int>(
    'insumo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unidadMeta = const VerificationMeta('unidad');
  @override
  late final GeneratedColumn<String> unidad = GeneratedColumn<String>(
    'unidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unid'),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recetaId,
    insumoId,
    cantidad,
    unidad,
    orden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receta_detalle';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecetaDetalleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receta_id')) {
      context.handle(
        _recetaIdMeta,
        recetaId.isAcceptableOrUnknown(data['receta_id']!, _recetaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recetaIdMeta);
    }
    if (data.containsKey('insumo_id')) {
      context.handle(
        _insumoIdMeta,
        insumoId.isAcceptableOrUnknown(data['insumo_id']!, _insumoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_insumoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    }
    if (data.containsKey('unidad')) {
      context.handle(
        _unidadMeta,
        unidad.isAcceptableOrUnknown(data['unidad']!, _unidadMeta),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecetaDetalleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecetaDetalleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recetaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receta_id'],
      )!,
      insumoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}insumo_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      unidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $RecetaDetalleTable createAlias(String alias) {
    return $RecetaDetalleTable(attachedDatabase, alias);
  }
}

class RecetaDetalleData extends DataClass
    implements Insertable<RecetaDetalleData> {
  final int id;
  final int recetaId;
  final int insumoId;
  final double cantidad;
  final String unidad;
  final int orden;
  const RecetaDetalleData({
    required this.id,
    required this.recetaId,
    required this.insumoId,
    required this.cantidad,
    required this.unidad,
    required this.orden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receta_id'] = Variable<int>(recetaId);
    map['insumo_id'] = Variable<int>(insumoId);
    map['cantidad'] = Variable<double>(cantidad);
    map['unidad'] = Variable<String>(unidad);
    map['orden'] = Variable<int>(orden);
    return map;
  }

  RecetaDetalleCompanion toCompanion(bool nullToAbsent) {
    return RecetaDetalleCompanion(
      id: Value(id),
      recetaId: Value(recetaId),
      insumoId: Value(insumoId),
      cantidad: Value(cantidad),
      unidad: Value(unidad),
      orden: Value(orden),
    );
  }

  factory RecetaDetalleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecetaDetalleData(
      id: serializer.fromJson<int>(json['id']),
      recetaId: serializer.fromJson<int>(json['recetaId']),
      insumoId: serializer.fromJson<int>(json['insumoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      unidad: serializer.fromJson<String>(json['unidad']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recetaId': serializer.toJson<int>(recetaId),
      'insumoId': serializer.toJson<int>(insumoId),
      'cantidad': serializer.toJson<double>(cantidad),
      'unidad': serializer.toJson<String>(unidad),
      'orden': serializer.toJson<int>(orden),
    };
  }

  RecetaDetalleData copyWith({
    int? id,
    int? recetaId,
    int? insumoId,
    double? cantidad,
    String? unidad,
    int? orden,
  }) => RecetaDetalleData(
    id: id ?? this.id,
    recetaId: recetaId ?? this.recetaId,
    insumoId: insumoId ?? this.insumoId,
    cantidad: cantidad ?? this.cantidad,
    unidad: unidad ?? this.unidad,
    orden: orden ?? this.orden,
  );
  RecetaDetalleData copyWithCompanion(RecetaDetalleCompanion data) {
    return RecetaDetalleData(
      id: data.id.present ? data.id.value : this.id,
      recetaId: data.recetaId.present ? data.recetaId.value : this.recetaId,
      insumoId: data.insumoId.present ? data.insumoId.value : this.insumoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecetaDetalleData(')
          ..write('id: $id, ')
          ..write('recetaId: $recetaId, ')
          ..write('insumoId: $insumoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('unidad: $unidad, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recetaId, insumoId, cantidad, unidad, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecetaDetalleData &&
          other.id == this.id &&
          other.recetaId == this.recetaId &&
          other.insumoId == this.insumoId &&
          other.cantidad == this.cantidad &&
          other.unidad == this.unidad &&
          other.orden == this.orden);
}

class RecetaDetalleCompanion extends UpdateCompanion<RecetaDetalleData> {
  final Value<int> id;
  final Value<int> recetaId;
  final Value<int> insumoId;
  final Value<double> cantidad;
  final Value<String> unidad;
  final Value<int> orden;
  const RecetaDetalleCompanion({
    this.id = const Value.absent(),
    this.recetaId = const Value.absent(),
    this.insumoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.unidad = const Value.absent(),
    this.orden = const Value.absent(),
  });
  RecetaDetalleCompanion.insert({
    this.id = const Value.absent(),
    required int recetaId,
    required int insumoId,
    this.cantidad = const Value.absent(),
    this.unidad = const Value.absent(),
    this.orden = const Value.absent(),
  }) : recetaId = Value(recetaId),
       insumoId = Value(insumoId);
  static Insertable<RecetaDetalleData> custom({
    Expression<int>? id,
    Expression<int>? recetaId,
    Expression<int>? insumoId,
    Expression<double>? cantidad,
    Expression<String>? unidad,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recetaId != null) 'receta_id': recetaId,
      if (insumoId != null) 'insumo_id': insumoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (unidad != null) 'unidad': unidad,
      if (orden != null) 'orden': orden,
    });
  }

  RecetaDetalleCompanion copyWith({
    Value<int>? id,
    Value<int>? recetaId,
    Value<int>? insumoId,
    Value<double>? cantidad,
    Value<String>? unidad,
    Value<int>? orden,
  }) {
    return RecetaDetalleCompanion(
      id: id ?? this.id,
      recetaId: recetaId ?? this.recetaId,
      insumoId: insumoId ?? this.insumoId,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recetaId.present) {
      map['receta_id'] = Variable<int>(recetaId.value);
    }
    if (insumoId.present) {
      map['insumo_id'] = Variable<int>(insumoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(unidad.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecetaDetalleCompanion(')
          ..write('id: $id, ')
          ..write('recetaId: $recetaId, ')
          ..write('insumoId: $insumoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('unidad: $unidad, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<String> numero = GeneratedColumn<String>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tipoDocumentoMeta = const VerificationMeta(
    'tipoDocumento',
  );
  @override
  late final GeneratedColumn<String> tipoDocumento = GeneratedColumn<String>(
    'tipo_documento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Nota de Venta'),
  );
  static const VerificationMeta _dniMeta = const VerificationMeta('dni');
  @override
  late final GeneratedColumn<String> dni = GeneratedColumn<String>(
    'dni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
    'ruc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreClienteMeta = const VerificationMeta(
    'nombreCliente',
  );
  @override
  late final GeneratedColumn<String> nombreCliente = GeneratedColumn<String>(
    'nombre_cliente',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _razonSocialMeta = const VerificationMeta(
    'razonSocial',
  );
  @override
  late final GeneratedColumn<String> razonSocial = GeneratedColumn<String>(
    'razon_social',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionFiscalMeta = const VerificationMeta(
    'direccionFiscal',
  );
  @override
  late final GeneratedColumn<String> direccionFiscal = GeneratedColumn<String>(
    'direccion_fiscal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _igvMeta = const VerificationMeta('igv');
  @override
  late final GeneratedColumn<double> igv = GeneratedColumn<double>(
    'igv',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descuentoMeta = const VerificationMeta(
    'descuento',
  );
  @override
  late final GeneratedColumn<double> descuento = GeneratedColumn<double>(
    'descuento',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metodoPagoMeta = const VerificationMeta(
    'metodoPago',
  );
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
    'metodo_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Efectivo'),
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    numero,
    fecha,
    tipoDocumento,
    dni,
    ruc,
    nombreCliente,
    razonSocial,
    direccionFiscal,
    subtotal,
    igv,
    descuento,
    total,
    metodoPago,
    observaciones,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Venta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('tipo_documento')) {
      context.handle(
        _tipoDocumentoMeta,
        tipoDocumento.isAcceptableOrUnknown(
          data['tipo_documento']!,
          _tipoDocumentoMeta,
        ),
      );
    }
    if (data.containsKey('dni')) {
      context.handle(
        _dniMeta,
        dni.isAcceptableOrUnknown(data['dni']!, _dniMeta),
      );
    }
    if (data.containsKey('ruc')) {
      context.handle(
        _rucMeta,
        ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta),
      );
    }
    if (data.containsKey('nombre_cliente')) {
      context.handle(
        _nombreClienteMeta,
        nombreCliente.isAcceptableOrUnknown(
          data['nombre_cliente']!,
          _nombreClienteMeta,
        ),
      );
    }
    if (data.containsKey('razon_social')) {
      context.handle(
        _razonSocialMeta,
        razonSocial.isAcceptableOrUnknown(
          data['razon_social']!,
          _razonSocialMeta,
        ),
      );
    }
    if (data.containsKey('direccion_fiscal')) {
      context.handle(
        _direccionFiscalMeta,
        direccionFiscal.isAcceptableOrUnknown(
          data['direccion_fiscal']!,
          _direccionFiscalMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('igv')) {
      context.handle(
        _igvMeta,
        igv.isAcceptableOrUnknown(data['igv']!, _igvMeta),
      );
    }
    if (data.containsKey('descuento')) {
      context.handle(
        _descuentoMeta,
        descuento.isAcceptableOrUnknown(data['descuento']!, _descuentoMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
        _metodoPagoMeta,
        metodoPago.isAcceptableOrUnknown(data['metodo_pago']!, _metodoPagoMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipoDocumento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_documento'],
      )!,
      dni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dni'],
      ),
      ruc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruc'],
      ),
      nombreCliente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_cliente'],
      ),
      razonSocial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}razon_social'],
      ),
      direccionFiscal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion_fiscal'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      igv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igv'],
      )!,
      descuento: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}descuento'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      metodoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo_pago'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }
}

class Venta extends DataClass implements Insertable<Venta> {
  final int id;
  final String numero;
  final DateTime fecha;
  final String tipoDocumento;
  final String? dni;
  final String? ruc;
  final String? nombreCliente;
  final String? razonSocial;
  final String? direccionFiscal;
  final double subtotal;
  final double igv;
  final double descuento;
  final double total;
  final String metodoPago;
  final String? observaciones;
  const Venta({
    required this.id,
    required this.numero,
    required this.fecha,
    required this.tipoDocumento,
    this.dni,
    this.ruc,
    this.nombreCliente,
    this.razonSocial,
    this.direccionFiscal,
    required this.subtotal,
    required this.igv,
    required this.descuento,
    required this.total,
    required this.metodoPago,
    this.observaciones,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['numero'] = Variable<String>(numero);
    map['fecha'] = Variable<DateTime>(fecha);
    map['tipo_documento'] = Variable<String>(tipoDocumento);
    if (!nullToAbsent || dni != null) {
      map['dni'] = Variable<String>(dni);
    }
    if (!nullToAbsent || ruc != null) {
      map['ruc'] = Variable<String>(ruc);
    }
    if (!nullToAbsent || nombreCliente != null) {
      map['nombre_cliente'] = Variable<String>(nombreCliente);
    }
    if (!nullToAbsent || razonSocial != null) {
      map['razon_social'] = Variable<String>(razonSocial);
    }
    if (!nullToAbsent || direccionFiscal != null) {
      map['direccion_fiscal'] = Variable<String>(direccionFiscal);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['igv'] = Variable<double>(igv);
    map['descuento'] = Variable<double>(descuento);
    map['total'] = Variable<double>(total);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      numero: Value(numero),
      fecha: Value(fecha),
      tipoDocumento: Value(tipoDocumento),
      dni: dni == null && nullToAbsent ? const Value.absent() : Value(dni),
      ruc: ruc == null && nullToAbsent ? const Value.absent() : Value(ruc),
      nombreCliente: nombreCliente == null && nullToAbsent
          ? const Value.absent()
          : Value(nombreCliente),
      razonSocial: razonSocial == null && nullToAbsent
          ? const Value.absent()
          : Value(razonSocial),
      direccionFiscal: direccionFiscal == null && nullToAbsent
          ? const Value.absent()
          : Value(direccionFiscal),
      subtotal: Value(subtotal),
      igv: Value(igv),
      descuento: Value(descuento),
      total: Value(total),
      metodoPago: Value(metodoPago),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory Venta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<int>(json['id']),
      numero: serializer.fromJson<String>(json['numero']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipoDocumento: serializer.fromJson<String>(json['tipoDocumento']),
      dni: serializer.fromJson<String?>(json['dni']),
      ruc: serializer.fromJson<String?>(json['ruc']),
      nombreCliente: serializer.fromJson<String?>(json['nombreCliente']),
      razonSocial: serializer.fromJson<String?>(json['razonSocial']),
      direccionFiscal: serializer.fromJson<String?>(json['direccionFiscal']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      igv: serializer.fromJson<double>(json['igv']),
      descuento: serializer.fromJson<double>(json['descuento']),
      total: serializer.fromJson<double>(json['total']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numero': serializer.toJson<String>(numero),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipoDocumento': serializer.toJson<String>(tipoDocumento),
      'dni': serializer.toJson<String?>(dni),
      'ruc': serializer.toJson<String?>(ruc),
      'nombreCliente': serializer.toJson<String?>(nombreCliente),
      'razonSocial': serializer.toJson<String?>(razonSocial),
      'direccionFiscal': serializer.toJson<String?>(direccionFiscal),
      'subtotal': serializer.toJson<double>(subtotal),
      'igv': serializer.toJson<double>(igv),
      'descuento': serializer.toJson<double>(descuento),
      'total': serializer.toJson<double>(total),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  Venta copyWith({
    int? id,
    String? numero,
    DateTime? fecha,
    String? tipoDocumento,
    Value<String?> dni = const Value.absent(),
    Value<String?> ruc = const Value.absent(),
    Value<String?> nombreCliente = const Value.absent(),
    Value<String?> razonSocial = const Value.absent(),
    Value<String?> direccionFiscal = const Value.absent(),
    double? subtotal,
    double? igv,
    double? descuento,
    double? total,
    String? metodoPago,
    Value<String?> observaciones = const Value.absent(),
  }) => Venta(
    id: id ?? this.id,
    numero: numero ?? this.numero,
    fecha: fecha ?? this.fecha,
    tipoDocumento: tipoDocumento ?? this.tipoDocumento,
    dni: dni.present ? dni.value : this.dni,
    ruc: ruc.present ? ruc.value : this.ruc,
    nombreCliente: nombreCliente.present
        ? nombreCliente.value
        : this.nombreCliente,
    razonSocial: razonSocial.present ? razonSocial.value : this.razonSocial,
    direccionFiscal: direccionFiscal.present
        ? direccionFiscal.value
        : this.direccionFiscal,
    subtotal: subtotal ?? this.subtotal,
    igv: igv ?? this.igv,
    descuento: descuento ?? this.descuento,
    total: total ?? this.total,
    metodoPago: metodoPago ?? this.metodoPago,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
  );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipoDocumento: data.tipoDocumento.present
          ? data.tipoDocumento.value
          : this.tipoDocumento,
      dni: data.dni.present ? data.dni.value : this.dni,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      nombreCliente: data.nombreCliente.present
          ? data.nombreCliente.value
          : this.nombreCliente,
      razonSocial: data.razonSocial.present
          ? data.razonSocial.value
          : this.razonSocial,
      direccionFiscal: data.direccionFiscal.present
          ? data.direccionFiscal.value
          : this.direccionFiscal,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      igv: data.igv.present ? data.igv.value : this.igv,
      descuento: data.descuento.present ? data.descuento.value : this.descuento,
      total: data.total.present ? data.total.value : this.total,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('fecha: $fecha, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('dni: $dni, ')
          ..write('ruc: $ruc, ')
          ..write('nombreCliente: $nombreCliente, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('direccionFiscal: $direccionFiscal, ')
          ..write('subtotal: $subtotal, ')
          ..write('igv: $igv, ')
          ..write('descuento: $descuento, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    numero,
    fecha,
    tipoDocumento,
    dni,
    ruc,
    nombreCliente,
    razonSocial,
    direccionFiscal,
    subtotal,
    igv,
    descuento,
    total,
    metodoPago,
    observaciones,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.fecha == this.fecha &&
          other.tipoDocumento == this.tipoDocumento &&
          other.dni == this.dni &&
          other.ruc == this.ruc &&
          other.nombreCliente == this.nombreCliente &&
          other.razonSocial == this.razonSocial &&
          other.direccionFiscal == this.direccionFiscal &&
          other.subtotal == this.subtotal &&
          other.igv == this.igv &&
          other.descuento == this.descuento &&
          other.total == this.total &&
          other.metodoPago == this.metodoPago &&
          other.observaciones == this.observaciones);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<int> id;
  final Value<String> numero;
  final Value<DateTime> fecha;
  final Value<String> tipoDocumento;
  final Value<String?> dni;
  final Value<String?> ruc;
  final Value<String?> nombreCliente;
  final Value<String?> razonSocial;
  final Value<String?> direccionFiscal;
  final Value<double> subtotal;
  final Value<double> igv;
  final Value<double> descuento;
  final Value<double> total;
  final Value<String> metodoPago;
  final Value<String?> observaciones;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.dni = const Value.absent(),
    this.ruc = const Value.absent(),
    this.nombreCliente = const Value.absent(),
    this.razonSocial = const Value.absent(),
    this.direccionFiscal = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.igv = const Value.absent(),
    this.descuento = const Value.absent(),
    this.total = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  VentasCompanion.insert({
    this.id = const Value.absent(),
    required String numero,
    this.fecha = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.dni = const Value.absent(),
    this.ruc = const Value.absent(),
    this.nombreCliente = const Value.absent(),
    this.razonSocial = const Value.absent(),
    this.direccionFiscal = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.igv = const Value.absent(),
    this.descuento = const Value.absent(),
    this.total = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.observaciones = const Value.absent(),
  }) : numero = Value(numero);
  static Insertable<Venta> custom({
    Expression<int>? id,
    Expression<String>? numero,
    Expression<DateTime>? fecha,
    Expression<String>? tipoDocumento,
    Expression<String>? dni,
    Expression<String>? ruc,
    Expression<String>? nombreCliente,
    Expression<String>? razonSocial,
    Expression<String>? direccionFiscal,
    Expression<double>? subtotal,
    Expression<double>? igv,
    Expression<double>? descuento,
    Expression<double>? total,
    Expression<String>? metodoPago,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (fecha != null) 'fecha': fecha,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (dni != null) 'dni': dni,
      if (ruc != null) 'ruc': ruc,
      if (nombreCliente != null) 'nombre_cliente': nombreCliente,
      if (razonSocial != null) 'razon_social': razonSocial,
      if (direccionFiscal != null) 'direccion_fiscal': direccionFiscal,
      if (subtotal != null) 'subtotal': subtotal,
      if (igv != null) 'igv': igv,
      if (descuento != null) 'descuento': descuento,
      if (total != null) 'total': total,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  VentasCompanion copyWith({
    Value<int>? id,
    Value<String>? numero,
    Value<DateTime>? fecha,
    Value<String>? tipoDocumento,
    Value<String?>? dni,
    Value<String?>? ruc,
    Value<String?>? nombreCliente,
    Value<String?>? razonSocial,
    Value<String?>? direccionFiscal,
    Value<double>? subtotal,
    Value<double>? igv,
    Value<double>? descuento,
    Value<double>? total,
    Value<String>? metodoPago,
    Value<String?>? observaciones,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      fecha: fecha ?? this.fecha,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      dni: dni ?? this.dni,
      ruc: ruc ?? this.ruc,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      razonSocial: razonSocial ?? this.razonSocial,
      direccionFiscal: direccionFiscal ?? this.direccionFiscal,
      subtotal: subtotal ?? this.subtotal,
      igv: igv ?? this.igv,
      descuento: descuento ?? this.descuento,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<String>(numero.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipoDocumento.present) {
      map['tipo_documento'] = Variable<String>(tipoDocumento.value);
    }
    if (dni.present) {
      map['dni'] = Variable<String>(dni.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (nombreCliente.present) {
      map['nombre_cliente'] = Variable<String>(nombreCliente.value);
    }
    if (razonSocial.present) {
      map['razon_social'] = Variable<String>(razonSocial.value);
    }
    if (direccionFiscal.present) {
      map['direccion_fiscal'] = Variable<String>(direccionFiscal.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (igv.present) {
      map['igv'] = Variable<double>(igv.value);
    }
    if (descuento.present) {
      map['descuento'] = Variable<double>(descuento.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('fecha: $fecha, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('dni: $dni, ')
          ..write('ruc: $ruc, ')
          ..write('nombreCliente: $nombreCliente, ')
          ..write('razonSocial: $razonSocial, ')
          ..write('direccionFiscal: $direccionFiscal, ')
          ..write('subtotal: $subtotal, ')
          ..write('igv: $igv, ')
          ..write('descuento: $descuento, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $DetalleVentasTable extends DetalleVentas
    with TableInfo<$DetalleVentasTable, DetalleVenta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetalleVentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tamanoMeta = const VerificationMeta('tamano');
  @override
  late final GeneratedColumn<String> tamano = GeneratedColumn<String>(
    'tamano',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoLecheMeta = const VerificationMeta(
    'tipoLeche',
  );
  @override
  late final GeneratedColumn<String> tipoLeche = GeneratedColumn<String>(
    'tipo_leche',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endulzanteMeta = const VerificationMeta(
    'endulzante',
  );
  @override
  late final GeneratedColumn<String> endulzante = GeneratedColumn<String>(
    'endulzante',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _infusionMeta = const VerificationMeta(
    'infusion',
  );
  @override
  late final GeneratedColumn<String> infusion = GeneratedColumn<String>(
    'infusion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraShotMeta = const VerificationMeta(
    'extraShot',
  );
  @override
  late final GeneratedColumn<bool> extraShot = GeneratedColumn<bool>(
    'extra_shot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("extra_shot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
    subtotal,
    tamano,
    tipoLeche,
    endulzante,
    infusion,
    extraShot,
    observaciones,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalle_ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetalleVenta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('tamano')) {
      context.handle(
        _tamanoMeta,
        tamano.isAcceptableOrUnknown(data['tamano']!, _tamanoMeta),
      );
    }
    if (data.containsKey('tipo_leche')) {
      context.handle(
        _tipoLecheMeta,
        tipoLeche.isAcceptableOrUnknown(data['tipo_leche']!, _tipoLecheMeta),
      );
    }
    if (data.containsKey('endulzante')) {
      context.handle(
        _endulzanteMeta,
        endulzante.isAcceptableOrUnknown(data['endulzante']!, _endulzanteMeta),
      );
    }
    if (data.containsKey('infusion')) {
      context.handle(
        _infusionMeta,
        infusion.isAcceptableOrUnknown(data['infusion']!, _infusionMeta),
      );
    }
    if (data.containsKey('extra_shot')) {
      context.handle(
        _extraShotMeta,
        extraShot.isAcceptableOrUnknown(data['extra_shot']!, _extraShotMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetalleVenta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetalleVenta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tamano: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tamano'],
      ),
      tipoLeche: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_leche'],
      ),
      endulzante: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endulzante'],
      ),
      infusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}infusion'],
      ),
      extraShot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}extra_shot'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
    );
  }

  @override
  $DetalleVentasTable createAlias(String alias) {
    return $DetalleVentasTable(attachedDatabase, alias);
  }
}

class DetalleVenta extends DataClass implements Insertable<DetalleVenta> {
  final int id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? tamano;
  final String? tipoLeche;
  final String? endulzante;
  final String? infusion;
  final bool extraShot;
  final String? observaciones;
  const DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.tamano,
    this.tipoLeche,
    this.endulzante,
    this.infusion,
    required this.extraShot,
    this.observaciones,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['subtotal'] = Variable<double>(subtotal);
    if (!nullToAbsent || tamano != null) {
      map['tamano'] = Variable<String>(tamano);
    }
    if (!nullToAbsent || tipoLeche != null) {
      map['tipo_leche'] = Variable<String>(tipoLeche);
    }
    if (!nullToAbsent || endulzante != null) {
      map['endulzante'] = Variable<String>(endulzante);
    }
    if (!nullToAbsent || infusion != null) {
      map['infusion'] = Variable<String>(infusion);
    }
    map['extra_shot'] = Variable<bool>(extraShot);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  DetalleVentasCompanion toCompanion(bool nullToAbsent) {
    return DetalleVentasCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      nombreProducto: Value(nombreProducto),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      subtotal: Value(subtotal),
      tamano: tamano == null && nullToAbsent
          ? const Value.absent()
          : Value(tamano),
      tipoLeche: tipoLeche == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoLeche),
      endulzante: endulzante == null && nullToAbsent
          ? const Value.absent()
          : Value(endulzante),
      infusion: infusion == null && nullToAbsent
          ? const Value.absent()
          : Value(infusion),
      extraShot: Value(extraShot),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory DetalleVenta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetalleVenta(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tamano: serializer.fromJson<String?>(json['tamano']),
      tipoLeche: serializer.fromJson<String?>(json['tipoLeche']),
      endulzante: serializer.fromJson<String?>(json['endulzante']),
      infusion: serializer.fromJson<String?>(json['infusion']),
      extraShot: serializer.fromJson<bool>(json['extraShot']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'productoId': serializer.toJson<int>(productoId),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'subtotal': serializer.toJson<double>(subtotal),
      'tamano': serializer.toJson<String?>(tamano),
      'tipoLeche': serializer.toJson<String?>(tipoLeche),
      'endulzante': serializer.toJson<String?>(endulzante),
      'infusion': serializer.toJson<String?>(infusion),
      'extraShot': serializer.toJson<bool>(extraShot),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  DetalleVenta copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    Value<String?> tamano = const Value.absent(),
    Value<String?> tipoLeche = const Value.absent(),
    Value<String?> endulzante = const Value.absent(),
    Value<String?> infusion = const Value.absent(),
    bool? extraShot,
    Value<String?> observaciones = const Value.absent(),
  }) => DetalleVenta(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId ?? this.productoId,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    subtotal: subtotal ?? this.subtotal,
    tamano: tamano.present ? tamano.value : this.tamano,
    tipoLeche: tipoLeche.present ? tipoLeche.value : this.tipoLeche,
    endulzante: endulzante.present ? endulzante.value : this.endulzante,
    infusion: infusion.present ? infusion.value : this.infusion,
    extraShot: extraShot ?? this.extraShot,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
  );
  DetalleVenta copyWithCompanion(DetalleVentasCompanion data) {
    return DetalleVenta(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tamano: data.tamano.present ? data.tamano.value : this.tamano,
      tipoLeche: data.tipoLeche.present ? data.tipoLeche.value : this.tipoLeche,
      endulzante: data.endulzante.present
          ? data.endulzante.value
          : this.endulzante,
      infusion: data.infusion.present ? data.infusion.value : this.infusion,
      extraShot: data.extraShot.present ? data.extraShot.value : this.extraShot,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetalleVenta(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('tamano: $tamano, ')
          ..write('tipoLeche: $tipoLeche, ')
          ..write('endulzante: $endulzante, ')
          ..write('infusion: $infusion, ')
          ..write('extraShot: $extraShot, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
    subtotal,
    tamano,
    tipoLeche,
    endulzante,
    infusion,
    extraShot,
    observaciones,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetalleVenta &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.nombreProducto == this.nombreProducto &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.subtotal == this.subtotal &&
          other.tamano == this.tamano &&
          other.tipoLeche == this.tipoLeche &&
          other.endulzante == this.endulzante &&
          other.infusion == this.infusion &&
          other.extraShot == this.extraShot &&
          other.observaciones == this.observaciones);
}

class DetalleVentasCompanion extends UpdateCompanion<DetalleVenta> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> productoId;
  final Value<String> nombreProducto;
  final Value<int> cantidad;
  final Value<double> precioUnitario;
  final Value<double> subtotal;
  final Value<String?> tamano;
  final Value<String?> tipoLeche;
  final Value<String?> endulzante;
  final Value<String?> infusion;
  final Value<bool> extraShot;
  final Value<String?> observaciones;
  const DetalleVentasCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tamano = const Value.absent(),
    this.tipoLeche = const Value.absent(),
    this.endulzante = const Value.absent(),
    this.infusion = const Value.absent(),
    this.extraShot = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  DetalleVentasCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int productoId,
    required String nombreProducto,
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tamano = const Value.absent(),
    this.tipoLeche = const Value.absent(),
    this.endulzante = const Value.absent(),
    this.infusion = const Value.absent(),
    this.extraShot = const Value.absent(),
    this.observaciones = const Value.absent(),
  }) : ventaId = Value(ventaId),
       productoId = Value(productoId),
       nombreProducto = Value(nombreProducto);
  static Insertable<DetalleVenta> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? productoId,
    Expression<String>? nombreProducto,
    Expression<int>? cantidad,
    Expression<double>? precioUnitario,
    Expression<double>? subtotal,
    Expression<String>? tamano,
    Expression<String>? tipoLeche,
    Expression<String>? endulzante,
    Expression<String>? infusion,
    Expression<bool>? extraShot,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (subtotal != null) 'subtotal': subtotal,
      if (tamano != null) 'tamano': tamano,
      if (tipoLeche != null) 'tipo_leche': tipoLeche,
      if (endulzante != null) 'endulzante': endulzante,
      if (infusion != null) 'infusion': infusion,
      if (extraShot != null) 'extra_shot': extraShot,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  DetalleVentasCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaId,
    Value<int>? productoId,
    Value<String>? nombreProducto,
    Value<int>? cantidad,
    Value<double>? precioUnitario,
    Value<double>? subtotal,
    Value<String?>? tamano,
    Value<String?>? tipoLeche,
    Value<String?>? endulzante,
    Value<String?>? infusion,
    Value<bool>? extraShot,
    Value<String?>? observaciones,
  }) {
    return DetalleVentasCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      tamano: tamano ?? this.tamano,
      tipoLeche: tipoLeche ?? this.tipoLeche,
      endulzante: endulzante ?? this.endulzante,
      infusion: infusion ?? this.infusion,
      extraShot: extraShot ?? this.extraShot,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tamano.present) {
      map['tamano'] = Variable<String>(tamano.value);
    }
    if (tipoLeche.present) {
      map['tipo_leche'] = Variable<String>(tipoLeche.value);
    }
    if (endulzante.present) {
      map['endulzante'] = Variable<String>(endulzante.value);
    }
    if (infusion.present) {
      map['infusion'] = Variable<String>(infusion.value);
    }
    if (extraShot.present) {
      map['extra_shot'] = Variable<bool>(extraShot.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetalleVentasCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('subtotal: $subtotal, ')
          ..write('tamano: $tamano, ')
          ..write('tipoLeche: $tipoLeche, ')
          ..write('endulzante: $endulzante, ')
          ..write('infusion: $infusion, ')
          ..write('extraShot: $extraShot, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dniMeta = const VerificationMeta('dni');
  @override
  late final GeneratedColumn<String> dni = GeneratedColumn<String>(
    'dni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
    'ruc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correoMeta = const VerificationMeta('correo');
  @override
  late final GeneratedColumn<String> correo = GeneratedColumn<String>(
    'correo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaRegistroMeta = const VerificationMeta(
    'fechaRegistro',
  );
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>(
        'fecha_registro',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _ultimaVisitaMeta = const VerificationMeta(
    'ultimaVisita',
  );
  @override
  late final GeneratedColumn<DateTime> ultimaVisita = GeneratedColumn<DateTime>(
    'ultima_visita',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalGastadoMeta = const VerificationMeta(
    'totalGastado',
  );
  @override
  late final GeneratedColumn<double> totalGastado = GeneratedColumn<double>(
    'total_gastado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cantidadComprasMeta = const VerificationMeta(
    'cantidadCompras',
  );
  @override
  late final GeneratedColumn<int> cantidadCompras = GeneratedColumn<int>(
    'cantidad_compras',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    dni,
    ruc,
    telefono,
    correo,
    direccion,
    fechaRegistro,
    ultimaVisita,
    totalGastado,
    cantidadCompras,
    observaciones,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('dni')) {
      context.handle(
        _dniMeta,
        dni.isAcceptableOrUnknown(data['dni']!, _dniMeta),
      );
    }
    if (data.containsKey('ruc')) {
      context.handle(
        _rucMeta,
        ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('correo')) {
      context.handle(
        _correoMeta,
        correo.isAcceptableOrUnknown(data['correo']!, _correoMeta),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
        _fechaRegistroMeta,
        fechaRegistro.isAcceptableOrUnknown(
          data['fecha_registro']!,
          _fechaRegistroMeta,
        ),
      );
    }
    if (data.containsKey('ultima_visita')) {
      context.handle(
        _ultimaVisitaMeta,
        ultimaVisita.isAcceptableOrUnknown(
          data['ultima_visita']!,
          _ultimaVisitaMeta,
        ),
      );
    }
    if (data.containsKey('total_gastado')) {
      context.handle(
        _totalGastadoMeta,
        totalGastado.isAcceptableOrUnknown(
          data['total_gastado']!,
          _totalGastadoMeta,
        ),
      );
    }
    if (data.containsKey('cantidad_compras')) {
      context.handle(
        _cantidadComprasMeta,
        cantidadCompras.isAcceptableOrUnknown(
          data['cantidad_compras']!,
          _cantidadComprasMeta,
        ),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      dni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dni'],
      ),
      ruc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruc'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      correo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correo'],
      ),
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      fechaRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_registro'],
      )!,
      ultimaVisita: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_visita'],
      ),
      totalGastado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_gastado'],
      )!,
      cantidadCompras: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad_compras'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nombre;
  final String? dni;
  final String? ruc;
  final String? telefono;
  final String? correo;
  final String? direccion;
  final DateTime fechaRegistro;
  final DateTime? ultimaVisita;
  final double totalGastado;
  final int cantidadCompras;
  final String? observaciones;
  const Cliente({
    required this.id,
    required this.nombre,
    this.dni,
    this.ruc,
    this.telefono,
    this.correo,
    this.direccion,
    required this.fechaRegistro,
    this.ultimaVisita,
    required this.totalGastado,
    required this.cantidadCompras,
    this.observaciones,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || dni != null) {
      map['dni'] = Variable<String>(dni);
    }
    if (!nullToAbsent || ruc != null) {
      map['ruc'] = Variable<String>(ruc);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || correo != null) {
      map['correo'] = Variable<String>(correo);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    if (!nullToAbsent || ultimaVisita != null) {
      map['ultima_visita'] = Variable<DateTime>(ultimaVisita);
    }
    map['total_gastado'] = Variable<double>(totalGastado);
    map['cantidad_compras'] = Variable<int>(cantidadCompras);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      dni: dni == null && nullToAbsent ? const Value.absent() : Value(dni),
      ruc: ruc == null && nullToAbsent ? const Value.absent() : Value(ruc),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      correo: correo == null && nullToAbsent
          ? const Value.absent()
          : Value(correo),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      fechaRegistro: Value(fechaRegistro),
      ultimaVisita: ultimaVisita == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaVisita),
      totalGastado: Value(totalGastado),
      cantidadCompras: Value(cantidadCompras),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      dni: serializer.fromJson<String?>(json['dni']),
      ruc: serializer.fromJson<String?>(json['ruc']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      correo: serializer.fromJson<String?>(json['correo']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
      ultimaVisita: serializer.fromJson<DateTime?>(json['ultimaVisita']),
      totalGastado: serializer.fromJson<double>(json['totalGastado']),
      cantidadCompras: serializer.fromJson<int>(json['cantidadCompras']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'dni': serializer.toJson<String?>(dni),
      'ruc': serializer.toJson<String?>(ruc),
      'telefono': serializer.toJson<String?>(telefono),
      'correo': serializer.toJson<String?>(correo),
      'direccion': serializer.toJson<String?>(direccion),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
      'ultimaVisita': serializer.toJson<DateTime?>(ultimaVisita),
      'totalGastado': serializer.toJson<double>(totalGastado),
      'cantidadCompras': serializer.toJson<int>(cantidadCompras),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  Cliente copyWith({
    int? id,
    String? nombre,
    Value<String?> dni = const Value.absent(),
    Value<String?> ruc = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    Value<String?> correo = const Value.absent(),
    Value<String?> direccion = const Value.absent(),
    DateTime? fechaRegistro,
    Value<DateTime?> ultimaVisita = const Value.absent(),
    double? totalGastado,
    int? cantidadCompras,
    Value<String?> observaciones = const Value.absent(),
  }) => Cliente(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    dni: dni.present ? dni.value : this.dni,
    ruc: ruc.present ? ruc.value : this.ruc,
    telefono: telefono.present ? telefono.value : this.telefono,
    correo: correo.present ? correo.value : this.correo,
    direccion: direccion.present ? direccion.value : this.direccion,
    fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    ultimaVisita: ultimaVisita.present ? ultimaVisita.value : this.ultimaVisita,
    totalGastado: totalGastado ?? this.totalGastado,
    cantidadCompras: cantidadCompras ?? this.cantidadCompras,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      dni: data.dni.present ? data.dni.value : this.dni,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      correo: data.correo.present ? data.correo.value : this.correo,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      ultimaVisita: data.ultimaVisita.present
          ? data.ultimaVisita.value
          : this.ultimaVisita,
      totalGastado: data.totalGastado.present
          ? data.totalGastado.value
          : this.totalGastado,
      cantidadCompras: data.cantidadCompras.present
          ? data.cantidadCompras.value
          : this.cantidadCompras,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('dni: $dni, ')
          ..write('ruc: $ruc, ')
          ..write('telefono: $telefono, ')
          ..write('correo: $correo, ')
          ..write('direccion: $direccion, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('ultimaVisita: $ultimaVisita, ')
          ..write('totalGastado: $totalGastado, ')
          ..write('cantidadCompras: $cantidadCompras, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    dni,
    ruc,
    telefono,
    correo,
    direccion,
    fechaRegistro,
    ultimaVisita,
    totalGastado,
    cantidadCompras,
    observaciones,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.dni == this.dni &&
          other.ruc == this.ruc &&
          other.telefono == this.telefono &&
          other.correo == this.correo &&
          other.direccion == this.direccion &&
          other.fechaRegistro == this.fechaRegistro &&
          other.ultimaVisita == this.ultimaVisita &&
          other.totalGastado == this.totalGastado &&
          other.cantidadCompras == this.cantidadCompras &&
          other.observaciones == this.observaciones);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> dni;
  final Value<String?> ruc;
  final Value<String?> telefono;
  final Value<String?> correo;
  final Value<String?> direccion;
  final Value<DateTime> fechaRegistro;
  final Value<DateTime?> ultimaVisita;
  final Value<double> totalGastado;
  final Value<int> cantidadCompras;
  final Value<String?> observaciones;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.dni = const Value.absent(),
    this.ruc = const Value.absent(),
    this.telefono = const Value.absent(),
    this.correo = const Value.absent(),
    this.direccion = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.ultimaVisita = const Value.absent(),
    this.totalGastado = const Value.absent(),
    this.cantidadCompras = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.dni = const Value.absent(),
    this.ruc = const Value.absent(),
    this.telefono = const Value.absent(),
    this.correo = const Value.absent(),
    this.direccion = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.ultimaVisita = const Value.absent(),
    this.totalGastado = const Value.absent(),
    this.cantidadCompras = const Value.absent(),
    this.observaciones = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? dni,
    Expression<String>? ruc,
    Expression<String>? telefono,
    Expression<String>? correo,
    Expression<String>? direccion,
    Expression<DateTime>? fechaRegistro,
    Expression<DateTime>? ultimaVisita,
    Expression<double>? totalGastado,
    Expression<int>? cantidadCompras,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (dni != null) 'dni': dni,
      if (ruc != null) 'ruc': ruc,
      if (telefono != null) 'telefono': telefono,
      if (correo != null) 'correo': correo,
      if (direccion != null) 'direccion': direccion,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (ultimaVisita != null) 'ultima_visita': ultimaVisita,
      if (totalGastado != null) 'total_gastado': totalGastado,
      if (cantidadCompras != null) 'cantidad_compras': cantidadCompras,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? dni,
    Value<String?>? ruc,
    Value<String?>? telefono,
    Value<String?>? correo,
    Value<String?>? direccion,
    Value<DateTime>? fechaRegistro,
    Value<DateTime?>? ultimaVisita,
    Value<double>? totalGastado,
    Value<int>? cantidadCompras,
    Value<String?>? observaciones,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      ruc: ruc ?? this.ruc,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaVisita: ultimaVisita ?? this.ultimaVisita,
      totalGastado: totalGastado ?? this.totalGastado,
      cantidadCompras: cantidadCompras ?? this.cantidadCompras,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (dni.present) {
      map['dni'] = Variable<String>(dni.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (correo.present) {
      map['correo'] = Variable<String>(correo.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    if (ultimaVisita.present) {
      map['ultima_visita'] = Variable<DateTime>(ultimaVisita.value);
    }
    if (totalGastado.present) {
      map['total_gastado'] = Variable<double>(totalGastado.value);
    }
    if (cantidadCompras.present) {
      map['cantidad_compras'] = Variable<int>(cantidadCompras.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('dni: $dni, ')
          ..write('ruc: $ruc, ')
          ..write('telefono: $telefono, ')
          ..write('correo: $correo, ')
          ..write('direccion: $direccion, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('ultimaVisita: $ultimaVisita, ')
          ..write('totalGastado: $totalGastado, ')
          ..write('cantidadCompras: $cantidadCompras, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $MovimientosInventarioTable extends MovimientosInventario
    with TableInfo<$MovimientosInventarioTable, MovimientosInventarioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosInventarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreItemMeta = const VerificationMeta(
    'nombreItem',
  );
  @override
  late final GeneratedColumn<String> nombreItem = GeneratedColumn<String>(
    'nombre_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📦'),
  );
  static const VerificationMeta _unidadMeta = const VerificationMeta('unidad');
  @override
  late final GeneratedColumn<String> unidad = GeneratedColumn<String>(
    'unidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _referenciaIdMeta = const VerificationMeta(
    'referenciaId',
  );
  @override
  late final GeneratedColumn<int> referenciaId = GeneratedColumn<int>(
    'referencia_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insumoIdMeta = const VerificationMeta(
    'insumoId',
  );
  @override
  late final GeneratedColumn<int> insumoId = GeneratedColumn<int>(
    'insumo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signoMeta = const VerificationMeta('signo');
  @override
  late final GeneratedColumn<int> signo = GeneratedColumn<int>(
    'signo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    tipo,
    nombreItem,
    emoji,
    unidad,
    referenciaId,
    insumoId,
    productoId,
    cantidad,
    signo,
    observacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_inventario';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimientosInventarioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nombre_item')) {
      context.handle(
        _nombreItemMeta,
        nombreItem.isAcceptableOrUnknown(data['nombre_item']!, _nombreItemMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('unidad')) {
      context.handle(
        _unidadMeta,
        unidad.isAcceptableOrUnknown(data['unidad']!, _unidadMeta),
      );
    }
    if (data.containsKey('referencia_id')) {
      context.handle(
        _referenciaIdMeta,
        referenciaId.isAcceptableOrUnknown(
          data['referencia_id']!,
          _referenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('insumo_id')) {
      context.handle(
        _insumoIdMeta,
        insumoId.isAcceptableOrUnknown(data['insumo_id']!, _insumoIdMeta),
      );
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('signo')) {
      context.handle(
        _signoMeta,
        signo.isAcceptableOrUnknown(data['signo']!, _signoMeta),
      );
    } else if (isInserting) {
      context.missing(_signoMeta);
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientosInventarioData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosInventarioData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nombreItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_item'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      unidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad'],
      )!,
      referenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}referencia_id'],
      ),
      insumoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}insumo_id'],
      ),
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      ),
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      signo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signo'],
      )!,
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
    );
  }

  @override
  $MovimientosInventarioTable createAlias(String alias) {
    return $MovimientosInventarioTable(attachedDatabase, alias);
  }
}

class MovimientosInventarioData extends DataClass
    implements Insertable<MovimientosInventarioData> {
  final int id;
  final DateTime fecha;
  final String tipo;
  final String nombreItem;
  final String emoji;
  final String unidad;
  final int? referenciaId;
  final int? insumoId;
  final int? productoId;
  final double cantidad;
  final int signo;
  final String? observacion;
  const MovimientosInventarioData({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.nombreItem,
    required this.emoji,
    required this.unidad,
    this.referenciaId,
    this.insumoId,
    this.productoId,
    required this.cantidad,
    required this.signo,
    this.observacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['tipo'] = Variable<String>(tipo);
    map['nombre_item'] = Variable<String>(nombreItem);
    map['emoji'] = Variable<String>(emoji);
    map['unidad'] = Variable<String>(unidad);
    if (!nullToAbsent || referenciaId != null) {
      map['referencia_id'] = Variable<int>(referenciaId);
    }
    if (!nullToAbsent || insumoId != null) {
      map['insumo_id'] = Variable<int>(insumoId);
    }
    if (!nullToAbsent || productoId != null) {
      map['producto_id'] = Variable<int>(productoId);
    }
    map['cantidad'] = Variable<double>(cantidad);
    map['signo'] = Variable<int>(signo);
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    return map;
  }

  MovimientosInventarioCompanion toCompanion(bool nullToAbsent) {
    return MovimientosInventarioCompanion(
      id: Value(id),
      fecha: Value(fecha),
      tipo: Value(tipo),
      nombreItem: Value(nombreItem),
      emoji: Value(emoji),
      unidad: Value(unidad),
      referenciaId: referenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaId),
      insumoId: insumoId == null && nullToAbsent
          ? const Value.absent()
          : Value(insumoId),
      productoId: productoId == null && nullToAbsent
          ? const Value.absent()
          : Value(productoId),
      cantidad: Value(cantidad),
      signo: Value(signo),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
    );
  }

  factory MovimientosInventarioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosInventarioData(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nombreItem: serializer.fromJson<String>(json['nombreItem']),
      emoji: serializer.fromJson<String>(json['emoji']),
      unidad: serializer.fromJson<String>(json['unidad']),
      referenciaId: serializer.fromJson<int?>(json['referenciaId']),
      insumoId: serializer.fromJson<int?>(json['insumoId']),
      productoId: serializer.fromJson<int?>(json['productoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      signo: serializer.fromJson<int>(json['signo']),
      observacion: serializer.fromJson<String?>(json['observacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<String>(tipo),
      'nombreItem': serializer.toJson<String>(nombreItem),
      'emoji': serializer.toJson<String>(emoji),
      'unidad': serializer.toJson<String>(unidad),
      'referenciaId': serializer.toJson<int?>(referenciaId),
      'insumoId': serializer.toJson<int?>(insumoId),
      'productoId': serializer.toJson<int?>(productoId),
      'cantidad': serializer.toJson<double>(cantidad),
      'signo': serializer.toJson<int>(signo),
      'observacion': serializer.toJson<String?>(observacion),
    };
  }

  MovimientosInventarioData copyWith({
    int? id,
    DateTime? fecha,
    String? tipo,
    String? nombreItem,
    String? emoji,
    String? unidad,
    Value<int?> referenciaId = const Value.absent(),
    Value<int?> insumoId = const Value.absent(),
    Value<int?> productoId = const Value.absent(),
    double? cantidad,
    int? signo,
    Value<String?> observacion = const Value.absent(),
  }) => MovimientosInventarioData(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    nombreItem: nombreItem ?? this.nombreItem,
    emoji: emoji ?? this.emoji,
    unidad: unidad ?? this.unidad,
    referenciaId: referenciaId.present ? referenciaId.value : this.referenciaId,
    insumoId: insumoId.present ? insumoId.value : this.insumoId,
    productoId: productoId.present ? productoId.value : this.productoId,
    cantidad: cantidad ?? this.cantidad,
    signo: signo ?? this.signo,
    observacion: observacion.present ? observacion.value : this.observacion,
  );
  MovimientosInventarioData copyWithCompanion(
    MovimientosInventarioCompanion data,
  ) {
    return MovimientosInventarioData(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nombreItem: data.nombreItem.present
          ? data.nombreItem.value
          : this.nombreItem,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
      referenciaId: data.referenciaId.present
          ? data.referenciaId.value
          : this.referenciaId,
      insumoId: data.insumoId.present ? data.insumoId.value : this.insumoId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      signo: data.signo.present ? data.signo.value : this.signo,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioData(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('nombreItem: $nombreItem, ')
          ..write('emoji: $emoji, ')
          ..write('unidad: $unidad, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('insumoId: $insumoId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('signo: $signo, ')
          ..write('observacion: $observacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    tipo,
    nombreItem,
    emoji,
    unidad,
    referenciaId,
    insumoId,
    productoId,
    cantidad,
    signo,
    observacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosInventarioData &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.nombreItem == this.nombreItem &&
          other.emoji == this.emoji &&
          other.unidad == this.unidad &&
          other.referenciaId == this.referenciaId &&
          other.insumoId == this.insumoId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.signo == this.signo &&
          other.observacion == this.observacion);
}

class MovimientosInventarioCompanion
    extends UpdateCompanion<MovimientosInventarioData> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<String> tipo;
  final Value<String> nombreItem;
  final Value<String> emoji;
  final Value<String> unidad;
  final Value<int?> referenciaId;
  final Value<int?> insumoId;
  final Value<int?> productoId;
  final Value<double> cantidad;
  final Value<int> signo;
  final Value<String?> observacion;
  const MovimientosInventarioCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nombreItem = const Value.absent(),
    this.emoji = const Value.absent(),
    this.unidad = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.insumoId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.signo = const Value.absent(),
    this.observacion = const Value.absent(),
  });
  MovimientosInventarioCompanion.insert({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    required String tipo,
    this.nombreItem = const Value.absent(),
    this.emoji = const Value.absent(),
    this.unidad = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.insumoId = const Value.absent(),
    this.productoId = const Value.absent(),
    required double cantidad,
    required int signo,
    this.observacion = const Value.absent(),
  }) : tipo = Value(tipo),
       cantidad = Value(cantidad),
       signo = Value(signo);
  static Insertable<MovimientosInventarioData> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<String>? tipo,
    Expression<String>? nombreItem,
    Expression<String>? emoji,
    Expression<String>? unidad,
    Expression<int>? referenciaId,
    Expression<int>? insumoId,
    Expression<int>? productoId,
    Expression<double>? cantidad,
    Expression<int>? signo,
    Expression<String>? observacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (nombreItem != null) 'nombre_item': nombreItem,
      if (emoji != null) 'emoji': emoji,
      if (unidad != null) 'unidad': unidad,
      if (referenciaId != null) 'referencia_id': referenciaId,
      if (insumoId != null) 'insumo_id': insumoId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (signo != null) 'signo': signo,
      if (observacion != null) 'observacion': observacion,
    });
  }

  MovimientosInventarioCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<String>? tipo,
    Value<String>? nombreItem,
    Value<String>? emoji,
    Value<String>? unidad,
    Value<int?>? referenciaId,
    Value<int?>? insumoId,
    Value<int?>? productoId,
    Value<double>? cantidad,
    Value<int>? signo,
    Value<String?>? observacion,
  }) {
    return MovimientosInventarioCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      nombreItem: nombreItem ?? this.nombreItem,
      emoji: emoji ?? this.emoji,
      unidad: unidad ?? this.unidad,
      referenciaId: referenciaId ?? this.referenciaId,
      insumoId: insumoId ?? this.insumoId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      signo: signo ?? this.signo,
      observacion: observacion ?? this.observacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nombreItem.present) {
      map['nombre_item'] = Variable<String>(nombreItem.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(unidad.value);
    }
    if (referenciaId.present) {
      map['referencia_id'] = Variable<int>(referenciaId.value);
    }
    if (insumoId.present) {
      map['insumo_id'] = Variable<int>(insumoId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (signo.present) {
      map['signo'] = Variable<int>(signo.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('nombreItem: $nombreItem, ')
          ..write('emoji: $emoji, ')
          ..write('unidad: $unidad, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('insumoId: $insumoId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('signo: $signo, ')
          ..write('observacion: $observacion')
          ..write(')'))
        .toString();
  }
}

class $EmpresaTable extends Empresa with TableInfo<$EmpresaTable, EmpresaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmpresaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rucMeta = const VerificationMeta('ruc');
  @override
  late final GeneratedColumn<String> ruc = GeneratedColumn<String>(
    'ruc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoContribuyenteMeta = const VerificationMeta(
    'tipoContribuyente',
  );
  @override
  late final GeneratedColumn<String> tipoContribuyente =
      GeneratedColumn<String>(
        'tipo_contribuyente',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('RUC10'),
      );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instagramMeta = const VerificationMeta(
    'instagram',
  );
  @override
  late final GeneratedColumn<String> instagram = GeneratedColumn<String>(
    'instagram',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serieBoletaMeta = const VerificationMeta(
    'serieBoleta',
  );
  @override
  late final GeneratedColumn<String> serieBoleta = GeneratedColumn<String>(
    'serie_boleta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('B001'),
  );
  static const VerificationMeta _serieFacturaMeta = const VerificationMeta(
    'serieFactura',
  );
  @override
  late final GeneratedColumn<String> serieFactura = GeneratedColumn<String>(
    'serie_factura',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('F001'),
  );
  static const VerificationMeta _correlativoBoletaMeta = const VerificationMeta(
    'correlativoBoleta',
  );
  @override
  late final GeneratedColumn<int> correlativoBoleta = GeneratedColumn<int>(
    'correlativo_boleta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _correlativoFacturaMeta =
      const VerificationMeta('correlativoFactura');
  @override
  late final GeneratedColumn<int> correlativoFactura = GeneratedColumn<int>(
    'correlativo_factura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _igvMeta = const VerificationMeta('igv');
  @override
  late final GeneratedColumn<double> igv = GeneratedColumn<double>(
    'igv',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(18),
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PEN'),
  );
  static const VerificationMeta _impresoraMeta = const VerificationMeta(
    'impresora',
  );
  @override
  late final GeneratedColumn<String> impresora = GeneratedColumn<String>(
    'impresora',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    ruc,
    tipoContribuyente,
    direccion,
    telefono,
    instagram,
    logo,
    serieBoleta,
    serieFactura,
    correlativoBoleta,
    correlativoFactura,
    igv,
    moneda,
    impresora,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empresa';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmpresaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('ruc')) {
      context.handle(
        _rucMeta,
        ruc.isAcceptableOrUnknown(data['ruc']!, _rucMeta),
      );
    } else if (isInserting) {
      context.missing(_rucMeta);
    }
    if (data.containsKey('tipo_contribuyente')) {
      context.handle(
        _tipoContribuyenteMeta,
        tipoContribuyente.isAcceptableOrUnknown(
          data['tipo_contribuyente']!,
          _tipoContribuyenteMeta,
        ),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('instagram')) {
      context.handle(
        _instagramMeta,
        instagram.isAcceptableOrUnknown(data['instagram']!, _instagramMeta),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('serie_boleta')) {
      context.handle(
        _serieBoletaMeta,
        serieBoleta.isAcceptableOrUnknown(
          data['serie_boleta']!,
          _serieBoletaMeta,
        ),
      );
    }
    if (data.containsKey('serie_factura')) {
      context.handle(
        _serieFacturaMeta,
        serieFactura.isAcceptableOrUnknown(
          data['serie_factura']!,
          _serieFacturaMeta,
        ),
      );
    }
    if (data.containsKey('correlativo_boleta')) {
      context.handle(
        _correlativoBoletaMeta,
        correlativoBoleta.isAcceptableOrUnknown(
          data['correlativo_boleta']!,
          _correlativoBoletaMeta,
        ),
      );
    }
    if (data.containsKey('correlativo_factura')) {
      context.handle(
        _correlativoFacturaMeta,
        correlativoFactura.isAcceptableOrUnknown(
          data['correlativo_factura']!,
          _correlativoFacturaMeta,
        ),
      );
    }
    if (data.containsKey('igv')) {
      context.handle(
        _igvMeta,
        igv.isAcceptableOrUnknown(data['igv']!, _igvMeta),
      );
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    }
    if (data.containsKey('impresora')) {
      context.handle(
        _impresoraMeta,
        impresora.isAcceptableOrUnknown(data['impresora']!, _impresoraMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmpresaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmpresaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      ruc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruc'],
      )!,
      tipoContribuyente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_contribuyente'],
      )!,
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      instagram: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instagram'],
      ),
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      serieBoleta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serie_boleta'],
      )!,
      serieFactura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serie_factura'],
      )!,
      correlativoBoleta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correlativo_boleta'],
      )!,
      correlativoFactura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correlativo_factura'],
      )!,
      igv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igv'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
      impresora: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impresora'],
      ),
    );
  }

  @override
  $EmpresaTable createAlias(String alias) {
    return $EmpresaTable(attachedDatabase, alias);
  }
}

class EmpresaData extends DataClass implements Insertable<EmpresaData> {
  final int id;
  final String nombre;
  final String ruc;
  final String tipoContribuyente;
  final String? direccion;
  final String? telefono;
  final String? instagram;
  final String? logo;
  final String serieBoleta;
  final String serieFactura;
  final int correlativoBoleta;
  final int correlativoFactura;
  final double igv;
  final String moneda;
  final String? impresora;
  const EmpresaData({
    required this.id,
    required this.nombre,
    required this.ruc,
    required this.tipoContribuyente,
    this.direccion,
    this.telefono,
    this.instagram,
    this.logo,
    required this.serieBoleta,
    required this.serieFactura,
    required this.correlativoBoleta,
    required this.correlativoFactura,
    required this.igv,
    required this.moneda,
    this.impresora,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['ruc'] = Variable<String>(ruc);
    map['tipo_contribuyente'] = Variable<String>(tipoContribuyente);
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || instagram != null) {
      map['instagram'] = Variable<String>(instagram);
    }
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    map['serie_boleta'] = Variable<String>(serieBoleta);
    map['serie_factura'] = Variable<String>(serieFactura);
    map['correlativo_boleta'] = Variable<int>(correlativoBoleta);
    map['correlativo_factura'] = Variable<int>(correlativoFactura);
    map['igv'] = Variable<double>(igv);
    map['moneda'] = Variable<String>(moneda);
    if (!nullToAbsent || impresora != null) {
      map['impresora'] = Variable<String>(impresora);
    }
    return map;
  }

  EmpresaCompanion toCompanion(bool nullToAbsent) {
    return EmpresaCompanion(
      id: Value(id),
      nombre: Value(nombre),
      ruc: Value(ruc),
      tipoContribuyente: Value(tipoContribuyente),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      instagram: instagram == null && nullToAbsent
          ? const Value.absent()
          : Value(instagram),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      serieBoleta: Value(serieBoleta),
      serieFactura: Value(serieFactura),
      correlativoBoleta: Value(correlativoBoleta),
      correlativoFactura: Value(correlativoFactura),
      igv: Value(igv),
      moneda: Value(moneda),
      impresora: impresora == null && nullToAbsent
          ? const Value.absent()
          : Value(impresora),
    );
  }

  factory EmpresaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmpresaData(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      ruc: serializer.fromJson<String>(json['ruc']),
      tipoContribuyente: serializer.fromJson<String>(json['tipoContribuyente']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      instagram: serializer.fromJson<String?>(json['instagram']),
      logo: serializer.fromJson<String?>(json['logo']),
      serieBoleta: serializer.fromJson<String>(json['serieBoleta']),
      serieFactura: serializer.fromJson<String>(json['serieFactura']),
      correlativoBoleta: serializer.fromJson<int>(json['correlativoBoleta']),
      correlativoFactura: serializer.fromJson<int>(json['correlativoFactura']),
      igv: serializer.fromJson<double>(json['igv']),
      moneda: serializer.fromJson<String>(json['moneda']),
      impresora: serializer.fromJson<String?>(json['impresora']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'ruc': serializer.toJson<String>(ruc),
      'tipoContribuyente': serializer.toJson<String>(tipoContribuyente),
      'direccion': serializer.toJson<String?>(direccion),
      'telefono': serializer.toJson<String?>(telefono),
      'instagram': serializer.toJson<String?>(instagram),
      'logo': serializer.toJson<String?>(logo),
      'serieBoleta': serializer.toJson<String>(serieBoleta),
      'serieFactura': serializer.toJson<String>(serieFactura),
      'correlativoBoleta': serializer.toJson<int>(correlativoBoleta),
      'correlativoFactura': serializer.toJson<int>(correlativoFactura),
      'igv': serializer.toJson<double>(igv),
      'moneda': serializer.toJson<String>(moneda),
      'impresora': serializer.toJson<String?>(impresora),
    };
  }

  EmpresaData copyWith({
    int? id,
    String? nombre,
    String? ruc,
    String? tipoContribuyente,
    Value<String?> direccion = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    Value<String?> instagram = const Value.absent(),
    Value<String?> logo = const Value.absent(),
    String? serieBoleta,
    String? serieFactura,
    int? correlativoBoleta,
    int? correlativoFactura,
    double? igv,
    String? moneda,
    Value<String?> impresora = const Value.absent(),
  }) => EmpresaData(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    ruc: ruc ?? this.ruc,
    tipoContribuyente: tipoContribuyente ?? this.tipoContribuyente,
    direccion: direccion.present ? direccion.value : this.direccion,
    telefono: telefono.present ? telefono.value : this.telefono,
    instagram: instagram.present ? instagram.value : this.instagram,
    logo: logo.present ? logo.value : this.logo,
    serieBoleta: serieBoleta ?? this.serieBoleta,
    serieFactura: serieFactura ?? this.serieFactura,
    correlativoBoleta: correlativoBoleta ?? this.correlativoBoleta,
    correlativoFactura: correlativoFactura ?? this.correlativoFactura,
    igv: igv ?? this.igv,
    moneda: moneda ?? this.moneda,
    impresora: impresora.present ? impresora.value : this.impresora,
  );
  EmpresaData copyWithCompanion(EmpresaCompanion data) {
    return EmpresaData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      ruc: data.ruc.present ? data.ruc.value : this.ruc,
      tipoContribuyente: data.tipoContribuyente.present
          ? data.tipoContribuyente.value
          : this.tipoContribuyente,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      instagram: data.instagram.present ? data.instagram.value : this.instagram,
      logo: data.logo.present ? data.logo.value : this.logo,
      serieBoleta: data.serieBoleta.present
          ? data.serieBoleta.value
          : this.serieBoleta,
      serieFactura: data.serieFactura.present
          ? data.serieFactura.value
          : this.serieFactura,
      correlativoBoleta: data.correlativoBoleta.present
          ? data.correlativoBoleta.value
          : this.correlativoBoleta,
      correlativoFactura: data.correlativoFactura.present
          ? data.correlativoFactura.value
          : this.correlativoFactura,
      igv: data.igv.present ? data.igv.value : this.igv,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      impresora: data.impresora.present ? data.impresora.value : this.impresora,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmpresaData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('ruc: $ruc, ')
          ..write('tipoContribuyente: $tipoContribuyente, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('instagram: $instagram, ')
          ..write('logo: $logo, ')
          ..write('serieBoleta: $serieBoleta, ')
          ..write('serieFactura: $serieFactura, ')
          ..write('correlativoBoleta: $correlativoBoleta, ')
          ..write('correlativoFactura: $correlativoFactura, ')
          ..write('igv: $igv, ')
          ..write('moneda: $moneda, ')
          ..write('impresora: $impresora')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    ruc,
    tipoContribuyente,
    direccion,
    telefono,
    instagram,
    logo,
    serieBoleta,
    serieFactura,
    correlativoBoleta,
    correlativoFactura,
    igv,
    moneda,
    impresora,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmpresaData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.ruc == this.ruc &&
          other.tipoContribuyente == this.tipoContribuyente &&
          other.direccion == this.direccion &&
          other.telefono == this.telefono &&
          other.instagram == this.instagram &&
          other.logo == this.logo &&
          other.serieBoleta == this.serieBoleta &&
          other.serieFactura == this.serieFactura &&
          other.correlativoBoleta == this.correlativoBoleta &&
          other.correlativoFactura == this.correlativoFactura &&
          other.igv == this.igv &&
          other.moneda == this.moneda &&
          other.impresora == this.impresora);
}

class EmpresaCompanion extends UpdateCompanion<EmpresaData> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> ruc;
  final Value<String> tipoContribuyente;
  final Value<String?> direccion;
  final Value<String?> telefono;
  final Value<String?> instagram;
  final Value<String?> logo;
  final Value<String> serieBoleta;
  final Value<String> serieFactura;
  final Value<int> correlativoBoleta;
  final Value<int> correlativoFactura;
  final Value<double> igv;
  final Value<String> moneda;
  final Value<String?> impresora;
  const EmpresaCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.ruc = const Value.absent(),
    this.tipoContribuyente = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.instagram = const Value.absent(),
    this.logo = const Value.absent(),
    this.serieBoleta = const Value.absent(),
    this.serieFactura = const Value.absent(),
    this.correlativoBoleta = const Value.absent(),
    this.correlativoFactura = const Value.absent(),
    this.igv = const Value.absent(),
    this.moneda = const Value.absent(),
    this.impresora = const Value.absent(),
  });
  EmpresaCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String ruc,
    this.tipoContribuyente = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.instagram = const Value.absent(),
    this.logo = const Value.absent(),
    this.serieBoleta = const Value.absent(),
    this.serieFactura = const Value.absent(),
    this.correlativoBoleta = const Value.absent(),
    this.correlativoFactura = const Value.absent(),
    this.igv = const Value.absent(),
    this.moneda = const Value.absent(),
    this.impresora = const Value.absent(),
  }) : nombre = Value(nombre),
       ruc = Value(ruc);
  static Insertable<EmpresaData> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? ruc,
    Expression<String>? tipoContribuyente,
    Expression<String>? direccion,
    Expression<String>? telefono,
    Expression<String>? instagram,
    Expression<String>? logo,
    Expression<String>? serieBoleta,
    Expression<String>? serieFactura,
    Expression<int>? correlativoBoleta,
    Expression<int>? correlativoFactura,
    Expression<double>? igv,
    Expression<String>? moneda,
    Expression<String>? impresora,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (ruc != null) 'ruc': ruc,
      if (tipoContribuyente != null) 'tipo_contribuyente': tipoContribuyente,
      if (direccion != null) 'direccion': direccion,
      if (telefono != null) 'telefono': telefono,
      if (instagram != null) 'instagram': instagram,
      if (logo != null) 'logo': logo,
      if (serieBoleta != null) 'serie_boleta': serieBoleta,
      if (serieFactura != null) 'serie_factura': serieFactura,
      if (correlativoBoleta != null) 'correlativo_boleta': correlativoBoleta,
      if (correlativoFactura != null) 'correlativo_factura': correlativoFactura,
      if (igv != null) 'igv': igv,
      if (moneda != null) 'moneda': moneda,
      if (impresora != null) 'impresora': impresora,
    });
  }

  EmpresaCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? ruc,
    Value<String>? tipoContribuyente,
    Value<String?>? direccion,
    Value<String?>? telefono,
    Value<String?>? instagram,
    Value<String?>? logo,
    Value<String>? serieBoleta,
    Value<String>? serieFactura,
    Value<int>? correlativoBoleta,
    Value<int>? correlativoFactura,
    Value<double>? igv,
    Value<String>? moneda,
    Value<String?>? impresora,
  }) {
    return EmpresaCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ruc: ruc ?? this.ruc,
      tipoContribuyente: tipoContribuyente ?? this.tipoContribuyente,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      instagram: instagram ?? this.instagram,
      logo: logo ?? this.logo,
      serieBoleta: serieBoleta ?? this.serieBoleta,
      serieFactura: serieFactura ?? this.serieFactura,
      correlativoBoleta: correlativoBoleta ?? this.correlativoBoleta,
      correlativoFactura: correlativoFactura ?? this.correlativoFactura,
      igv: igv ?? this.igv,
      moneda: moneda ?? this.moneda,
      impresora: impresora ?? this.impresora,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (ruc.present) {
      map['ruc'] = Variable<String>(ruc.value);
    }
    if (tipoContribuyente.present) {
      map['tipo_contribuyente'] = Variable<String>(tipoContribuyente.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (instagram.present) {
      map['instagram'] = Variable<String>(instagram.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (serieBoleta.present) {
      map['serie_boleta'] = Variable<String>(serieBoleta.value);
    }
    if (serieFactura.present) {
      map['serie_factura'] = Variable<String>(serieFactura.value);
    }
    if (correlativoBoleta.present) {
      map['correlativo_boleta'] = Variable<int>(correlativoBoleta.value);
    }
    if (correlativoFactura.present) {
      map['correlativo_factura'] = Variable<int>(correlativoFactura.value);
    }
    if (igv.present) {
      map['igv'] = Variable<double>(igv.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (impresora.present) {
      map['impresora'] = Variable<String>(impresora.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmpresaCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('ruc: $ruc, ')
          ..write('tipoContribuyente: $tipoContribuyente, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('instagram: $instagram, ')
          ..write('logo: $logo, ')
          ..write('serieBoleta: $serieBoleta, ')
          ..write('serieFactura: $serieFactura, ')
          ..write('correlativoBoleta: $correlativoBoleta, ')
          ..write('correlativoFactura: $correlativoFactura, ')
          ..write('igv: $igv, ')
          ..write('moneda: $moneda, ')
          ..write('impresora: $impresora')
          ..write(')'))
        .toString();
  }
}

class $CajasTable extends Cajas with TableInfo<$CajasTable, Caja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaAperturaMeta = const VerificationMeta(
    'fechaApertura',
  );
  @override
  late final GeneratedColumn<DateTime> fechaApertura =
      GeneratedColumn<DateTime>(
        'fecha_apertura',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _montoInicialMeta = const VerificationMeta(
    'montoInicial',
  );
  @override
  late final GeneratedColumn<double> montoInicial = GeneratedColumn<double>(
    'monto_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCierre = GeneratedColumn<DateTime>(
    'fecha_cierre',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoCierreMeta = const VerificationMeta(
    'montoCierre',
  );
  @override
  late final GeneratedColumn<double> montoCierre = GeneratedColumn<double>(
    'monto_cierre',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ABIERTA'),
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fechaApertura,
    montoInicial,
    fechaCierre,
    montoCierre,
    estado,
    observaciones,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cajas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Caja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
        _fechaAperturaMeta,
        fechaApertura.isAcceptableOrUnknown(
          data['fecha_apertura']!,
          _fechaAperturaMeta,
        ),
      );
    }
    if (data.containsKey('monto_inicial')) {
      context.handle(
        _montoInicialMeta,
        montoInicial.isAcceptableOrUnknown(
          data['monto_inicial']!,
          _montoInicialMeta,
        ),
      );
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    }
    if (data.containsKey('monto_cierre')) {
      context.handle(
        _montoCierreMeta,
        montoCierre.isAcceptableOrUnknown(
          data['monto_cierre']!,
          _montoCierreMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Caja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Caja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fechaApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_apertura'],
      )!,
      montoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_inicial'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_cierre'],
      ),
      montoCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_cierre'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
    );
  }

  @override
  $CajasTable createAlias(String alias) {
    return $CajasTable(attachedDatabase, alias);
  }
}

class Caja extends DataClass implements Insertable<Caja> {
  final int id;
  final DateTime fechaApertura;
  final double montoInicial;
  final DateTime? fechaCierre;
  final double? montoCierre;
  final String estado;
  final String? observaciones;
  const Caja({
    required this.id,
    required this.fechaApertura,
    required this.montoInicial,
    this.fechaCierre,
    this.montoCierre,
    required this.estado,
    this.observaciones,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha_apertura'] = Variable<DateTime>(fechaApertura);
    map['monto_inicial'] = Variable<double>(montoInicial);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre);
    }
    if (!nullToAbsent || montoCierre != null) {
      map['monto_cierre'] = Variable<double>(montoCierre);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  CajasCompanion toCompanion(bool nullToAbsent) {
    return CajasCompanion(
      id: Value(id),
      fechaApertura: Value(fechaApertura),
      montoInicial: Value(montoInicial),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      montoCierre: montoCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(montoCierre),
      estado: Value(estado),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory Caja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Caja(
      id: serializer.fromJson<int>(json['id']),
      fechaApertura: serializer.fromJson<DateTime>(json['fechaApertura']),
      montoInicial: serializer.fromJson<double>(json['montoInicial']),
      fechaCierre: serializer.fromJson<DateTime?>(json['fechaCierre']),
      montoCierre: serializer.fromJson<double?>(json['montoCierre']),
      estado: serializer.fromJson<String>(json['estado']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fechaApertura': serializer.toJson<DateTime>(fechaApertura),
      'montoInicial': serializer.toJson<double>(montoInicial),
      'fechaCierre': serializer.toJson<DateTime?>(fechaCierre),
      'montoCierre': serializer.toJson<double?>(montoCierre),
      'estado': serializer.toJson<String>(estado),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  Caja copyWith({
    int? id,
    DateTime? fechaApertura,
    double? montoInicial,
    Value<DateTime?> fechaCierre = const Value.absent(),
    Value<double?> montoCierre = const Value.absent(),
    String? estado,
    Value<String?> observaciones = const Value.absent(),
  }) => Caja(
    id: id ?? this.id,
    fechaApertura: fechaApertura ?? this.fechaApertura,
    montoInicial: montoInicial ?? this.montoInicial,
    fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
    montoCierre: montoCierre.present ? montoCierre.value : this.montoCierre,
    estado: estado ?? this.estado,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
  );
  Caja copyWithCompanion(CajasCompanion data) {
    return Caja(
      id: data.id.present ? data.id.value : this.id,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      montoInicial: data.montoInicial.present
          ? data.montoInicial.value
          : this.montoInicial,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      montoCierre: data.montoCierre.present
          ? data.montoCierre.value
          : this.montoCierre,
      estado: data.estado.present ? data.estado.value : this.estado,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Caja(')
          ..write('id: $id, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('montoInicial: $montoInicial, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoCierre: $montoCierre, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fechaApertura,
    montoInicial,
    fechaCierre,
    montoCierre,
    estado,
    observaciones,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Caja &&
          other.id == this.id &&
          other.fechaApertura == this.fechaApertura &&
          other.montoInicial == this.montoInicial &&
          other.fechaCierre == this.fechaCierre &&
          other.montoCierre == this.montoCierre &&
          other.estado == this.estado &&
          other.observaciones == this.observaciones);
}

class CajasCompanion extends UpdateCompanion<Caja> {
  final Value<int> id;
  final Value<DateTime> fechaApertura;
  final Value<double> montoInicial;
  final Value<DateTime?> fechaCierre;
  final Value<double?> montoCierre;
  final Value<String> estado;
  final Value<String?> observaciones;
  const CajasCompanion({
    this.id = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.montoInicial = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.montoCierre = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  CajasCompanion.insert({
    this.id = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.montoInicial = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.montoCierre = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  static Insertable<Caja> custom({
    Expression<int>? id,
    Expression<DateTime>? fechaApertura,
    Expression<double>? montoInicial,
    Expression<DateTime>? fechaCierre,
    Expression<double>? montoCierre,
    Expression<String>? estado,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (montoInicial != null) 'monto_inicial': montoInicial,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (montoCierre != null) 'monto_cierre': montoCierre,
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  CajasCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fechaApertura,
    Value<double>? montoInicial,
    Value<DateTime?>? fechaCierre,
    Value<double?>? montoCierre,
    Value<String>? estado,
    Value<String?>? observaciones,
  }) {
    return CajasCompanion(
      id: id ?? this.id,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      montoInicial: montoInicial ?? this.montoInicial,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      montoCierre: montoCierre ?? this.montoCierre,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<DateTime>(fechaApertura.value);
    }
    if (montoInicial.present) {
      map['monto_inicial'] = Variable<double>(montoInicial.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre.value);
    }
    if (montoCierre.present) {
      map['monto_cierre'] = Variable<double>(montoCierre.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajasCompanion(')
          ..write('id: $id, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('montoInicial: $montoInicial, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoCierre: $montoCierre, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $MovimientosCajaTable extends MovimientosCaja
    with TableInfo<$MovimientosCajaTable, MovimientosCajaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosCajaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
    'caja_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metodoPagoMeta = const VerificationMeta(
    'metodoPago',
  );
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
    'metodo_pago',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaMeta = const VerificationMeta(
    'referencia',
  );
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
    'referencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cajaId,
    fecha,
    tipo,
    concepto,
    monto,
    metodoPago,
    referencia,
    observacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_caja';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimientosCajaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('caja_id')) {
      context.handle(
        _cajaIdMeta,
        cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
        _metodoPagoMeta,
        metodoPago.isAcceptableOrUnknown(data['metodo_pago']!, _metodoPagoMeta),
      );
    }
    if (data.containsKey('referencia')) {
      context.handle(
        _referenciaMeta,
        referencia.isAcceptableOrUnknown(data['referencia']!, _referenciaMeta),
      );
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientosCajaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosCajaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caja_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      metodoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo_pago'],
      ),
      referencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia'],
      ),
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
    );
  }

  @override
  $MovimientosCajaTable createAlias(String alias) {
    return $MovimientosCajaTable(attachedDatabase, alias);
  }
}

class MovimientosCajaData extends DataClass
    implements Insertable<MovimientosCajaData> {
  final int id;
  final int cajaId;
  final DateTime fecha;
  final String tipo;
  final String concepto;
  final double monto;
  final String? metodoPago;
  final String? referencia;
  final String? observacion;
  const MovimientosCajaData({
    required this.id,
    required this.cajaId,
    required this.fecha,
    required this.tipo,
    required this.concepto,
    required this.monto,
    this.metodoPago,
    this.referencia,
    this.observacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['caja_id'] = Variable<int>(cajaId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['tipo'] = Variable<String>(tipo);
    map['concepto'] = Variable<String>(concepto);
    map['monto'] = Variable<double>(monto);
    if (!nullToAbsent || metodoPago != null) {
      map['metodo_pago'] = Variable<String>(metodoPago);
    }
    if (!nullToAbsent || referencia != null) {
      map['referencia'] = Variable<String>(referencia);
    }
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    return map;
  }

  MovimientosCajaCompanion toCompanion(bool nullToAbsent) {
    return MovimientosCajaCompanion(
      id: Value(id),
      cajaId: Value(cajaId),
      fecha: Value(fecha),
      tipo: Value(tipo),
      concepto: Value(concepto),
      monto: Value(monto),
      metodoPago: metodoPago == null && nullToAbsent
          ? const Value.absent()
          : Value(metodoPago),
      referencia: referencia == null && nullToAbsent
          ? const Value.absent()
          : Value(referencia),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
    );
  }

  factory MovimientosCajaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosCajaData(
      id: serializer.fromJson<int>(json['id']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: serializer.fromJson<String>(json['tipo']),
      concepto: serializer.fromJson<String>(json['concepto']),
      monto: serializer.fromJson<double>(json['monto']),
      metodoPago: serializer.fromJson<String?>(json['metodoPago']),
      referencia: serializer.fromJson<String?>(json['referencia']),
      observacion: serializer.fromJson<String?>(json['observacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cajaId': serializer.toJson<int>(cajaId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<String>(tipo),
      'concepto': serializer.toJson<String>(concepto),
      'monto': serializer.toJson<double>(monto),
      'metodoPago': serializer.toJson<String?>(metodoPago),
      'referencia': serializer.toJson<String?>(referencia),
      'observacion': serializer.toJson<String?>(observacion),
    };
  }

  MovimientosCajaData copyWith({
    int? id,
    int? cajaId,
    DateTime? fecha,
    String? tipo,
    String? concepto,
    double? monto,
    Value<String?> metodoPago = const Value.absent(),
    Value<String?> referencia = const Value.absent(),
    Value<String?> observacion = const Value.absent(),
  }) => MovimientosCajaData(
    id: id ?? this.id,
    cajaId: cajaId ?? this.cajaId,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    concepto: concepto ?? this.concepto,
    monto: monto ?? this.monto,
    metodoPago: metodoPago.present ? metodoPago.value : this.metodoPago,
    referencia: referencia.present ? referencia.value : this.referencia,
    observacion: observacion.present ? observacion.value : this.observacion,
  );
  MovimientosCajaData copyWithCompanion(MovimientosCajaCompanion data) {
    return MovimientosCajaData(
      id: data.id.present ? data.id.value : this.id,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      monto: data.monto.present ? data.monto.value : this.monto,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      referencia: data.referencia.present
          ? data.referencia.value
          : this.referencia,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCajaData(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('referencia: $referencia, ')
          ..write('observacion: $observacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cajaId,
    fecha,
    tipo,
    concepto,
    monto,
    metodoPago,
    referencia,
    observacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosCajaData &&
          other.id == this.id &&
          other.cajaId == this.cajaId &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.concepto == this.concepto &&
          other.monto == this.monto &&
          other.metodoPago == this.metodoPago &&
          other.referencia == this.referencia &&
          other.observacion == this.observacion);
}

class MovimientosCajaCompanion extends UpdateCompanion<MovimientosCajaData> {
  final Value<int> id;
  final Value<int> cajaId;
  final Value<DateTime> fecha;
  final Value<String> tipo;
  final Value<String> concepto;
  final Value<double> monto;
  final Value<String?> metodoPago;
  final Value<String?> referencia;
  final Value<String?> observacion;
  const MovimientosCajaCompanion({
    this.id = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.concepto = const Value.absent(),
    this.monto = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.referencia = const Value.absent(),
    this.observacion = const Value.absent(),
  });
  MovimientosCajaCompanion.insert({
    this.id = const Value.absent(),
    required int cajaId,
    this.fecha = const Value.absent(),
    required String tipo,
    required String concepto,
    required double monto,
    this.metodoPago = const Value.absent(),
    this.referencia = const Value.absent(),
    this.observacion = const Value.absent(),
  }) : cajaId = Value(cajaId),
       tipo = Value(tipo),
       concepto = Value(concepto),
       monto = Value(monto);
  static Insertable<MovimientosCajaData> custom({
    Expression<int>? id,
    Expression<int>? cajaId,
    Expression<DateTime>? fecha,
    Expression<String>? tipo,
    Expression<String>? concepto,
    Expression<double>? monto,
    Expression<String>? metodoPago,
    Expression<String>? referencia,
    Expression<String>? observacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cajaId != null) 'caja_id': cajaId,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (concepto != null) 'concepto': concepto,
      if (monto != null) 'monto': monto,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (referencia != null) 'referencia': referencia,
      if (observacion != null) 'observacion': observacion,
    });
  }

  MovimientosCajaCompanion copyWith({
    Value<int>? id,
    Value<int>? cajaId,
    Value<DateTime>? fecha,
    Value<String>? tipo,
    Value<String>? concepto,
    Value<double>? monto,
    Value<String?>? metodoPago,
    Value<String?>? referencia,
    Value<String?>? observacion,
  }) {
    return MovimientosCajaCompanion(
      id: id ?? this.id,
      cajaId: cajaId ?? this.cajaId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
      monto: monto ?? this.monto,
      metodoPago: metodoPago ?? this.metodoPago,
      referencia: referencia ?? this.referencia,
      observacion: observacion ?? this.observacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCajaCompanion(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto, ')
          ..write('monto: $monto, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('referencia: $referencia, ')
          ..write('observacion: $observacion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $InsumosTable insumos = $InsumosTable(this);
  late final $RecetasTable recetas = $RecetasTable(this);
  late final $RecetaDetalleTable recetaDetalle = $RecetaDetalleTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $DetalleVentasTable detalleVentas = $DetalleVentasTable(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $MovimientosInventarioTable movimientosInventario =
      $MovimientosInventarioTable(this);
  late final $EmpresaTable empresa = $EmpresaTable(this);
  late final $CajasTable cajas = $CajasTable(this);
  late final $MovimientosCajaTable movimientosCaja = $MovimientosCajaTable(
    this,
  );
  late final ProductosDao productosDao = ProductosDao(this as AppDatabase);
  late final InsumosDao insumosDao = InsumosDao(this as AppDatabase);
  late final RecetasDao recetasDao = RecetasDao(this as AppDatabase);
  late final RecetaDetalleDao recetaDetalleDao = RecetaDetalleDao(
    this as AppDatabase,
  );
  late final VentasDao ventasDao = VentasDao(this as AppDatabase);
  late final ClientesDao clientesDao = ClientesDao(this as AppDatabase);
  late final MovimientosInventarioDao movimientosInventarioDao =
      MovimientosInventarioDao(this as AppDatabase);
  late final EmpresaDao empresaDao = EmpresaDao(this as AppDatabase);
  late final CajasDao cajasDao = CajasDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productos,
    categorias,
    insumos,
    recetas,
    recetaDetalle,
    ventas,
    detalleVentas,
    clientes,
    movimientosInventario,
    empresa,
    cajas,
    movimientosCaja,
  ];
}

typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      required String codigo,
      Value<String?> codigoBarras,
      required String nombre,
      Value<String> descripcion,
      required int categoriaId,
      required double costo,
      required double precioVenta,
      Value<int> stock,
      Value<int> stockMinimo,
      Value<String> tipoInventario,
      Value<String> emoji,
      Value<String> imagen,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String?> codigoBarras,
      Value<String> nombre,
      Value<String> descripcion,
      Value<int> categoriaId,
      Value<double> costo,
      Value<double> precioVenta,
      Value<int> stock,
      Value<int> stockMinimo,
      Value<String> tipoInventario,
      Value<String> emoji,
      Value<String> imagen,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoInventario => $composableBuilder(
    column: $table.tipoInventario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoInventario => $composableBuilder(
    column: $table.tipoInventario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoInventario => $composableBuilder(
    column: $table.tipoInventario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get imagen =>
      $composableBuilder(column: $table.imagen, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
          Producto,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<double> costo = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> stockMinimo = const Value.absent(),
                Value<String> tipoInventario = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                codigo: codigo,
                codigoBarras: codigoBarras,
                nombre: nombre,
                descripcion: descripcion,
                categoriaId: categoriaId,
                costo: costo,
                precioVenta: precioVenta,
                stock: stock,
                stockMinimo: stockMinimo,
                tipoInventario: tipoInventario,
                emoji: emoji,
                imagen: imagen,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                Value<String?> codigoBarras = const Value.absent(),
                required String nombre,
                Value<String> descripcion = const Value.absent(),
                required int categoriaId,
                required double costo,
                required double precioVenta,
                Value<int> stock = const Value.absent(),
                Value<int> stockMinimo = const Value.absent(),
                Value<String> tipoInventario = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                codigo: codigo,
                codigoBarras: codigoBarras,
                nombre: nombre,
                descripcion: descripcion,
                categoriaId: categoriaId,
                costo: costo,
                precioVenta: precioVenta,
                stock: stock,
                stockMinimo: stockMinimo,
                tipoInventario: tipoInventario,
                emoji: emoji,
                imagen: imagen,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
      Producto,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String> icono,
      Value<int> orden,
      Value<bool> activo,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> icono,
      Value<int> orden,
      Value<bool> activo,
    });

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get icono =>
      $composableBuilder(column: $table.icono, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (
            Categoria,
            BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>,
          ),
          Categoria,
          PrefetchHooks Function()
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> icono = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nombre: nombre,
                icono: icono,
                orden: orden,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String> icono = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                icono: icono,
                orden: orden,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>),
      Categoria,
      PrefetchHooks Function()
    >;
typedef $$InsumosTableCreateCompanionBuilder =
    InsumosCompanion Function({
      Value<int> id,
      required String codigo,
      required String nombre,
      Value<String> descripcion,
      required int categoriaId,
      required String unidadMedida,
      Value<double> stock,
      Value<double> stockMinimo,
      Value<double> costoCompra,
      Value<String> emoji,
      Value<String> imagen,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });
typedef $$InsumosTableUpdateCompanionBuilder =
    InsumosCompanion Function({
      Value<int> id,
      Value<String> codigo,
      Value<String> nombre,
      Value<String> descripcion,
      Value<int> categoriaId,
      Value<String> unidadMedida,
      Value<double> stock,
      Value<double> stockMinimo,
      Value<double> costoCompra,
      Value<String> emoji,
      Value<String> imagen,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });

class $$InsumosTableFilterComposer
    extends Composer<_$AppDatabase, $InsumosTable> {
  $$InsumosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoCompra => $composableBuilder(
    column: $table.costoCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsumosTableOrderingComposer
    extends Composer<_$AppDatabase, $InsumosTable> {
  $$InsumosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoCompra => $composableBuilder(
    column: $table.costoCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagen => $composableBuilder(
    column: $table.imagen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsumosTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsumosTable> {
  $$InsumosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costoCompra => $composableBuilder(
    column: $table.costoCompra,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get imagen =>
      $composableBuilder(column: $table.imagen, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );
}

class $$InsumosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsumosTable,
          Insumo,
          $$InsumosTableFilterComposer,
          $$InsumosTableOrderingComposer,
          $$InsumosTableAnnotationComposer,
          $$InsumosTableCreateCompanionBuilder,
          $$InsumosTableUpdateCompanionBuilder,
          (Insumo, BaseReferences<_$AppDatabase, $InsumosTable, Insumo>),
          Insumo,
          PrefetchHooks Function()
        > {
  $$InsumosTableTableManager(_$AppDatabase db, $InsumosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsumosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsumosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsumosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<String> unidadMedida = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<double> costoCompra = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => InsumosCompanion(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                categoriaId: categoriaId,
                unidadMedida: unidadMedida,
                stock: stock,
                stockMinimo: stockMinimo,
                costoCompra: costoCompra,
                emoji: emoji,
                imagen: imagen,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigo,
                required String nombre,
                Value<String> descripcion = const Value.absent(),
                required int categoriaId,
                required String unidadMedida,
                Value<double> stock = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<double> costoCompra = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> imagen = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => InsumosCompanion.insert(
                id: id,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                categoriaId: categoriaId,
                unidadMedida: unidadMedida,
                stock: stock,
                stockMinimo: stockMinimo,
                costoCompra: costoCompra,
                emoji: emoji,
                imagen: imagen,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsumosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsumosTable,
      Insumo,
      $$InsumosTableFilterComposer,
      $$InsumosTableOrderingComposer,
      $$InsumosTableAnnotationComposer,
      $$InsumosTableCreateCompanionBuilder,
      $$InsumosTableUpdateCompanionBuilder,
      (Insumo, BaseReferences<_$AppDatabase, $InsumosTable, Insumo>),
      Insumo,
      PrefetchHooks Function()
    >;
typedef $$RecetasTableCreateCompanionBuilder =
    RecetasCompanion Function({
      Value<int> id,
      required int productoId,
      required String nombre,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });
typedef $$RecetasTableUpdateCompanionBuilder =
    RecetasCompanion Function({
      Value<int> id,
      Value<int> productoId,
      Value<String> nombre,
      Value<bool> activo,
      Value<DateTime> fechaCreacion,
    });

class $$RecetasTableFilterComposer
    extends Composer<_$AppDatabase, $RecetasTable> {
  $$RecetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecetasTableOrderingComposer
    extends Composer<_$AppDatabase, $RecetasTable> {
  $$RecetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecetasTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecetasTable> {
  $$RecetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );
}

class $$RecetasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecetasTable,
          Receta,
          $$RecetasTableFilterComposer,
          $$RecetasTableOrderingComposer,
          $$RecetasTableAnnotationComposer,
          $$RecetasTableCreateCompanionBuilder,
          $$RecetasTableUpdateCompanionBuilder,
          (Receta, BaseReferences<_$AppDatabase, $RecetasTable, Receta>),
          Receta,
          PrefetchHooks Function()
        > {
  $$RecetasTableTableManager(_$AppDatabase db, $RecetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => RecetasCompanion(
                id: id,
                productoId: productoId,
                nombre: nombre,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productoId,
                required String nombre,
                Value<bool> activo = const Value.absent(),
                Value<DateTime> fechaCreacion = const Value.absent(),
              }) => RecetasCompanion.insert(
                id: id,
                productoId: productoId,
                nombre: nombre,
                activo: activo,
                fechaCreacion: fechaCreacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecetasTable,
      Receta,
      $$RecetasTableFilterComposer,
      $$RecetasTableOrderingComposer,
      $$RecetasTableAnnotationComposer,
      $$RecetasTableCreateCompanionBuilder,
      $$RecetasTableUpdateCompanionBuilder,
      (Receta, BaseReferences<_$AppDatabase, $RecetasTable, Receta>),
      Receta,
      PrefetchHooks Function()
    >;
typedef $$RecetaDetalleTableCreateCompanionBuilder =
    RecetaDetalleCompanion Function({
      Value<int> id,
      required int recetaId,
      required int insumoId,
      Value<double> cantidad,
      Value<String> unidad,
      Value<int> orden,
    });
typedef $$RecetaDetalleTableUpdateCompanionBuilder =
    RecetaDetalleCompanion Function({
      Value<int> id,
      Value<int> recetaId,
      Value<int> insumoId,
      Value<double> cantidad,
      Value<String> unidad,
      Value<int> orden,
    });

class $$RecetaDetalleTableFilterComposer
    extends Composer<_$AppDatabase, $RecetaDetalleTable> {
  $$RecetaDetalleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recetaId => $composableBuilder(
    column: $table.recetaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get insumoId => $composableBuilder(
    column: $table.insumoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecetaDetalleTableOrderingComposer
    extends Composer<_$AppDatabase, $RecetaDetalleTable> {
  $$RecetaDetalleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recetaId => $composableBuilder(
    column: $table.recetaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get insumoId => $composableBuilder(
    column: $table.insumoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecetaDetalleTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecetaDetalleTable> {
  $$RecetaDetalleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get recetaId =>
      $composableBuilder(column: $table.recetaId, builder: (column) => column);

  GeneratedColumn<int> get insumoId =>
      $composableBuilder(column: $table.insumoId, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);
}

class $$RecetaDetalleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecetaDetalleTable,
          RecetaDetalleData,
          $$RecetaDetalleTableFilterComposer,
          $$RecetaDetalleTableOrderingComposer,
          $$RecetaDetalleTableAnnotationComposer,
          $$RecetaDetalleTableCreateCompanionBuilder,
          $$RecetaDetalleTableUpdateCompanionBuilder,
          (
            RecetaDetalleData,
            BaseReferences<
              _$AppDatabase,
              $RecetaDetalleTable,
              RecetaDetalleData
            >,
          ),
          RecetaDetalleData,
          PrefetchHooks Function()
        > {
  $$RecetaDetalleTableTableManager(_$AppDatabase db, $RecetaDetalleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecetaDetalleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecetaDetalleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecetaDetalleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recetaId = const Value.absent(),
                Value<int> insumoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => RecetaDetalleCompanion(
                id: id,
                recetaId: recetaId,
                insumoId: insumoId,
                cantidad: cantidad,
                unidad: unidad,
                orden: orden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recetaId,
                required int insumoId,
                Value<double> cantidad = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => RecetaDetalleCompanion.insert(
                id: id,
                recetaId: recetaId,
                insumoId: insumoId,
                cantidad: cantidad,
                unidad: unidad,
                orden: orden,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecetaDetalleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecetaDetalleTable,
      RecetaDetalleData,
      $$RecetaDetalleTableFilterComposer,
      $$RecetaDetalleTableOrderingComposer,
      $$RecetaDetalleTableAnnotationComposer,
      $$RecetaDetalleTableCreateCompanionBuilder,
      $$RecetaDetalleTableUpdateCompanionBuilder,
      (
        RecetaDetalleData,
        BaseReferences<_$AppDatabase, $RecetaDetalleTable, RecetaDetalleData>,
      ),
      RecetaDetalleData,
      PrefetchHooks Function()
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      Value<int> id,
      required String numero,
      Value<DateTime> fecha,
      Value<String> tipoDocumento,
      Value<String?> dni,
      Value<String?> ruc,
      Value<String?> nombreCliente,
      Value<String?> razonSocial,
      Value<String?> direccionFiscal,
      Value<double> subtotal,
      Value<double> igv,
      Value<double> descuento,
      Value<double> total,
      Value<String> metodoPago,
      Value<String?> observaciones,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<int> id,
      Value<String> numero,
      Value<DateTime> fecha,
      Value<String> tipoDocumento,
      Value<String?> dni,
      Value<String?> ruc,
      Value<String?> nombreCliente,
      Value<String?> razonSocial,
      Value<String?> direccionFiscal,
      Value<double> subtotal,
      Value<double> igv,
      Value<double> descuento,
      Value<double> total,
      Value<String> metodoPago,
      Value<String?> observaciones,
    });

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoDocumento => $composableBuilder(
    column: $table.tipoDocumento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreCliente => $composableBuilder(
    column: $table.nombreCliente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccionFiscal => $composableBuilder(
    column: $table.direccionFiscal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igv => $composableBuilder(
    column: $table.igv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get descuento => $composableBuilder(
    column: $table.descuento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoDocumento => $composableBuilder(
    column: $table.tipoDocumento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreCliente => $composableBuilder(
    column: $table.nombreCliente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccionFiscal => $composableBuilder(
    column: $table.direccionFiscal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igv => $composableBuilder(
    column: $table.igv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get descuento => $composableBuilder(
    column: $table.descuento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipoDocumento => $composableBuilder(
    column: $table.tipoDocumento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dni =>
      $composableBuilder(column: $table.dni, builder: (column) => column);

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get nombreCliente => $composableBuilder(
    column: $table.nombreCliente,
    builder: (column) => column,
  );

  GeneratedColumn<String> get razonSocial => $composableBuilder(
    column: $table.razonSocial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direccionFiscal => $composableBuilder(
    column: $table.direccionFiscal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get igv =>
      $composableBuilder(column: $table.igv, builder: (column) => column);

  GeneratedColumn<double> get descuento =>
      $composableBuilder(column: $table.descuento, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasTable,
          Venta,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (Venta, BaseReferences<_$AppDatabase, $VentasTable, Venta>),
          Venta,
          PrefetchHooks Function()
        > {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> numero = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> tipoDocumento = const Value.absent(),
                Value<String?> dni = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> nombreCliente = const Value.absent(),
                Value<String?> razonSocial = const Value.absent(),
                Value<String?> direccionFiscal = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> igv = const Value.absent(),
                Value<double> descuento = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                numero: numero,
                fecha: fecha,
                tipoDocumento: tipoDocumento,
                dni: dni,
                ruc: ruc,
                nombreCliente: nombreCliente,
                razonSocial: razonSocial,
                direccionFiscal: direccionFiscal,
                subtotal: subtotal,
                igv: igv,
                descuento: descuento,
                total: total,
                metodoPago: metodoPago,
                observaciones: observaciones,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String numero,
                Value<DateTime> fecha = const Value.absent(),
                Value<String> tipoDocumento = const Value.absent(),
                Value<String?> dni = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> nombreCliente = const Value.absent(),
                Value<String?> razonSocial = const Value.absent(),
                Value<String?> direccionFiscal = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> igv = const Value.absent(),
                Value<double> descuento = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                numero: numero,
                fecha: fecha,
                tipoDocumento: tipoDocumento,
                dni: dni,
                ruc: ruc,
                nombreCliente: nombreCliente,
                razonSocial: razonSocial,
                direccionFiscal: direccionFiscal,
                subtotal: subtotal,
                igv: igv,
                descuento: descuento,
                total: total,
                metodoPago: metodoPago,
                observaciones: observaciones,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasTable,
      Venta,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (Venta, BaseReferences<_$AppDatabase, $VentasTable, Venta>),
      Venta,
      PrefetchHooks Function()
    >;
typedef $$DetalleVentasTableCreateCompanionBuilder =
    DetalleVentasCompanion Function({
      Value<int> id,
      required int ventaId,
      required int productoId,
      required String nombreProducto,
      Value<int> cantidad,
      Value<double> precioUnitario,
      Value<double> subtotal,
      Value<String?> tamano,
      Value<String?> tipoLeche,
      Value<String?> endulzante,
      Value<String?> infusion,
      Value<bool> extraShot,
      Value<String?> observaciones,
    });
typedef $$DetalleVentasTableUpdateCompanionBuilder =
    DetalleVentasCompanion Function({
      Value<int> id,
      Value<int> ventaId,
      Value<int> productoId,
      Value<String> nombreProducto,
      Value<int> cantidad,
      Value<double> precioUnitario,
      Value<double> subtotal,
      Value<String?> tamano,
      Value<String?> tipoLeche,
      Value<String?> endulzante,
      Value<String?> infusion,
      Value<bool> extraShot,
      Value<String?> observaciones,
    });

class $$DetalleVentasTableFilterComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tamano => $composableBuilder(
    column: $table.tamano,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoLeche => $composableBuilder(
    column: $table.tipoLeche,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endulzante => $composableBuilder(
    column: $table.endulzante,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infusion => $composableBuilder(
    column: $table.infusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get extraShot => $composableBuilder(
    column: $table.extraShot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DetalleVentasTableOrderingComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tamano => $composableBuilder(
    column: $table.tamano,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoLeche => $composableBuilder(
    column: $table.tipoLeche,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endulzante => $composableBuilder(
    column: $table.endulzante,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infusion => $composableBuilder(
    column: $table.infusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get extraShot => $composableBuilder(
    column: $table.extraShot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DetalleVentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetalleVentasTable> {
  $$DetalleVentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get tamano =>
      $composableBuilder(column: $table.tamano, builder: (column) => column);

  GeneratedColumn<String> get tipoLeche =>
      $composableBuilder(column: $table.tipoLeche, builder: (column) => column);

  GeneratedColumn<String> get endulzante => $composableBuilder(
    column: $table.endulzante,
    builder: (column) => column,
  );

  GeneratedColumn<String> get infusion =>
      $composableBuilder(column: $table.infusion, builder: (column) => column);

  GeneratedColumn<bool> get extraShot =>
      $composableBuilder(column: $table.extraShot, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );
}

class $$DetalleVentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetalleVentasTable,
          DetalleVenta,
          $$DetalleVentasTableFilterComposer,
          $$DetalleVentasTableOrderingComposer,
          $$DetalleVentasTableAnnotationComposer,
          $$DetalleVentasTableCreateCompanionBuilder,
          $$DetalleVentasTableUpdateCompanionBuilder,
          (
            DetalleVenta,
            BaseReferences<_$AppDatabase, $DetalleVentasTable, DetalleVenta>,
          ),
          DetalleVenta,
          PrefetchHooks Function()
        > {
  $$DetalleVentasTableTableManager(_$AppDatabase db, $DetalleVentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetalleVentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetalleVentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetalleVentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String?> tamano = const Value.absent(),
                Value<String?> tipoLeche = const Value.absent(),
                Value<String?> endulzante = const Value.absent(),
                Value<String?> infusion = const Value.absent(),
                Value<bool> extraShot = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => DetalleVentasCompanion(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
                tamano: tamano,
                tipoLeche: tipoLeche,
                endulzante: endulzante,
                infusion: infusion,
                extraShot: extraShot,
                observaciones: observaciones,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaId,
                required int productoId,
                required String nombreProducto,
                Value<int> cantidad = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String?> tamano = const Value.absent(),
                Value<String?> tipoLeche = const Value.absent(),
                Value<String?> endulzante = const Value.absent(),
                Value<String?> infusion = const Value.absent(),
                Value<bool> extraShot = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => DetalleVentasCompanion.insert(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                subtotal: subtotal,
                tamano: tamano,
                tipoLeche: tipoLeche,
                endulzante: endulzante,
                infusion: infusion,
                extraShot: extraShot,
                observaciones: observaciones,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DetalleVentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetalleVentasTable,
      DetalleVenta,
      $$DetalleVentasTableFilterComposer,
      $$DetalleVentasTableOrderingComposer,
      $$DetalleVentasTableAnnotationComposer,
      $$DetalleVentasTableCreateCompanionBuilder,
      $$DetalleVentasTableUpdateCompanionBuilder,
      (
        DetalleVenta,
        BaseReferences<_$AppDatabase, $DetalleVentasTable, DetalleVenta>,
      ),
      DetalleVenta,
      PrefetchHooks Function()
    >;
typedef $$ClientesTableCreateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> dni,
      Value<String?> ruc,
      Value<String?> telefono,
      Value<String?> correo,
      Value<String?> direccion,
      Value<DateTime> fechaRegistro,
      Value<DateTime?> ultimaVisita,
      Value<double> totalGastado,
      Value<int> cantidadCompras,
      Value<String?> observaciones,
    });
typedef $$ClientesTableUpdateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> dni,
      Value<String?> ruc,
      Value<String?> telefono,
      Value<String?> correo,
      Value<String?> direccion,
      Value<DateTime> fechaRegistro,
      Value<DateTime?> ultimaVisita,
      Value<double> totalGastado,
      Value<int> cantidadCompras,
      Value<String?> observaciones,
    });

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correo => $composableBuilder(
    column: $table.correo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimaVisita => $composableBuilder(
    column: $table.ultimaVisita,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalGastado => $composableBuilder(
    column: $table.totalGastado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidadCompras => $composableBuilder(
    column: $table.cantidadCompras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correo => $composableBuilder(
    column: $table.correo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimaVisita => $composableBuilder(
    column: $table.ultimaVisita,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalGastado => $composableBuilder(
    column: $table.totalGastado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidadCompras => $composableBuilder(
    column: $table.cantidadCompras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get dni =>
      $composableBuilder(column: $table.dni, builder: (column) => column);

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get correo =>
      $composableBuilder(column: $table.correo, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ultimaVisita => $composableBuilder(
    column: $table.ultimaVisita,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalGastado => $composableBuilder(
    column: $table.totalGastado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidadCompras => $composableBuilder(
    column: $table.cantidadCompras,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
          Cliente,
          PrefetchHooks Function()
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> dni = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> correo = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<DateTime> fechaRegistro = const Value.absent(),
                Value<DateTime?> ultimaVisita = const Value.absent(),
                Value<double> totalGastado = const Value.absent(),
                Value<int> cantidadCompras = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nombre: nombre,
                dni: dni,
                ruc: ruc,
                telefono: telefono,
                correo: correo,
                direccion: direccion,
                fechaRegistro: fechaRegistro,
                ultimaVisita: ultimaVisita,
                totalGastado: totalGastado,
                cantidadCompras: cantidadCompras,
                observaciones: observaciones,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> dni = const Value.absent(),
                Value<String?> ruc = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> correo = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<DateTime> fechaRegistro = const Value.absent(),
                Value<DateTime?> ultimaVisita = const Value.absent(),
                Value<double> totalGastado = const Value.absent(),
                Value<int> cantidadCompras = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nombre: nombre,
                dni: dni,
                ruc: ruc,
                telefono: telefono,
                correo: correo,
                direccion: direccion,
                fechaRegistro: fechaRegistro,
                ultimaVisita: ultimaVisita,
                totalGastado: totalGastado,
                cantidadCompras: cantidadCompras,
                observaciones: observaciones,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
      Cliente,
      PrefetchHooks Function()
    >;
typedef $$MovimientosInventarioTableCreateCompanionBuilder =
    MovimientosInventarioCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      required String tipo,
      Value<String> nombreItem,
      Value<String> emoji,
      Value<String> unidad,
      Value<int?> referenciaId,
      Value<int?> insumoId,
      Value<int?> productoId,
      required double cantidad,
      required int signo,
      Value<String?> observacion,
    });
typedef $$MovimientosInventarioTableUpdateCompanionBuilder =
    MovimientosInventarioCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<String> tipo,
      Value<String> nombreItem,
      Value<String> emoji,
      Value<String> unidad,
      Value<int?> referenciaId,
      Value<int?> insumoId,
      Value<int?> productoId,
      Value<double> cantidad,
      Value<int> signo,
      Value<String?> observacion,
    });

class $$MovimientosInventarioTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreItem => $composableBuilder(
    column: $table.nombreItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get insumoId => $composableBuilder(
    column: $table.insumoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signo => $composableBuilder(
    column: $table.signo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosInventarioTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreItem => $composableBuilder(
    column: $table.nombreItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get insumoId => $composableBuilder(
    column: $table.insumoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signo => $composableBuilder(
    column: $table.signo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosInventarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nombreItem => $composableBuilder(
    column: $table.nombreItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);

  GeneratedColumn<int> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get insumoId =>
      $composableBuilder(column: $table.insumoId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get signo =>
      $composableBuilder(column: $table.signo, builder: (column) => column);

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );
}

class $$MovimientosInventarioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosInventarioTable,
          MovimientosInventarioData,
          $$MovimientosInventarioTableFilterComposer,
          $$MovimientosInventarioTableOrderingComposer,
          $$MovimientosInventarioTableAnnotationComposer,
          $$MovimientosInventarioTableCreateCompanionBuilder,
          $$MovimientosInventarioTableUpdateCompanionBuilder,
          (
            MovimientosInventarioData,
            BaseReferences<
              _$AppDatabase,
              $MovimientosInventarioTable,
              MovimientosInventarioData
            >,
          ),
          MovimientosInventarioData,
          PrefetchHooks Function()
        > {
  $$MovimientosInventarioTableTableManager(
    _$AppDatabase db,
    $MovimientosInventarioTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosInventarioTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MovimientosInventarioTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MovimientosInventarioTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nombreItem = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int?> referenciaId = const Value.absent(),
                Value<int?> insumoId = const Value.absent(),
                Value<int?> productoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<int> signo = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
              }) => MovimientosInventarioCompanion(
                id: id,
                fecha: fecha,
                tipo: tipo,
                nombreItem: nombreItem,
                emoji: emoji,
                unidad: unidad,
                referenciaId: referenciaId,
                insumoId: insumoId,
                productoId: productoId,
                cantidad: cantidad,
                signo: signo,
                observacion: observacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                required String tipo,
                Value<String> nombreItem = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int?> referenciaId = const Value.absent(),
                Value<int?> insumoId = const Value.absent(),
                Value<int?> productoId = const Value.absent(),
                required double cantidad,
                required int signo,
                Value<String?> observacion = const Value.absent(),
              }) => MovimientosInventarioCompanion.insert(
                id: id,
                fecha: fecha,
                tipo: tipo,
                nombreItem: nombreItem,
                emoji: emoji,
                unidad: unidad,
                referenciaId: referenciaId,
                insumoId: insumoId,
                productoId: productoId,
                cantidad: cantidad,
                signo: signo,
                observacion: observacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosInventarioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosInventarioTable,
      MovimientosInventarioData,
      $$MovimientosInventarioTableFilterComposer,
      $$MovimientosInventarioTableOrderingComposer,
      $$MovimientosInventarioTableAnnotationComposer,
      $$MovimientosInventarioTableCreateCompanionBuilder,
      $$MovimientosInventarioTableUpdateCompanionBuilder,
      (
        MovimientosInventarioData,
        BaseReferences<
          _$AppDatabase,
          $MovimientosInventarioTable,
          MovimientosInventarioData
        >,
      ),
      MovimientosInventarioData,
      PrefetchHooks Function()
    >;
typedef $$EmpresaTableCreateCompanionBuilder =
    EmpresaCompanion Function({
      Value<int> id,
      required String nombre,
      required String ruc,
      Value<String> tipoContribuyente,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<String?> instagram,
      Value<String?> logo,
      Value<String> serieBoleta,
      Value<String> serieFactura,
      Value<int> correlativoBoleta,
      Value<int> correlativoFactura,
      Value<double> igv,
      Value<String> moneda,
      Value<String?> impresora,
    });
typedef $$EmpresaTableUpdateCompanionBuilder =
    EmpresaCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String> ruc,
      Value<String> tipoContribuyente,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<String?> instagram,
      Value<String?> logo,
      Value<String> serieBoleta,
      Value<String> serieFactura,
      Value<int> correlativoBoleta,
      Value<int> correlativoFactura,
      Value<double> igv,
      Value<String> moneda,
      Value<String?> impresora,
    });

class $$EmpresaTableFilterComposer
    extends Composer<_$AppDatabase, $EmpresaTable> {
  $$EmpresaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoContribuyente => $composableBuilder(
    column: $table.tipoContribuyente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instagram => $composableBuilder(
    column: $table.instagram,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serieBoleta => $composableBuilder(
    column: $table.serieBoleta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serieFactura => $composableBuilder(
    column: $table.serieFactura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correlativoBoleta => $composableBuilder(
    column: $table.correlativoBoleta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correlativoFactura => $composableBuilder(
    column: $table.correlativoFactura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igv => $composableBuilder(
    column: $table.igv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impresora => $composableBuilder(
    column: $table.impresora,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmpresaTableOrderingComposer
    extends Composer<_$AppDatabase, $EmpresaTable> {
  $$EmpresaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruc => $composableBuilder(
    column: $table.ruc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoContribuyente => $composableBuilder(
    column: $table.tipoContribuyente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instagram => $composableBuilder(
    column: $table.instagram,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serieBoleta => $composableBuilder(
    column: $table.serieBoleta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serieFactura => $composableBuilder(
    column: $table.serieFactura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correlativoBoleta => $composableBuilder(
    column: $table.correlativoBoleta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correlativoFactura => $composableBuilder(
    column: $table.correlativoFactura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igv => $composableBuilder(
    column: $table.igv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impresora => $composableBuilder(
    column: $table.impresora,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmpresaTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmpresaTable> {
  $$EmpresaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get ruc =>
      $composableBuilder(column: $table.ruc, builder: (column) => column);

  GeneratedColumn<String> get tipoContribuyente => $composableBuilder(
    column: $table.tipoContribuyente,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get instagram =>
      $composableBuilder(column: $table.instagram, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<String> get serieBoleta => $composableBuilder(
    column: $table.serieBoleta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serieFactura => $composableBuilder(
    column: $table.serieFactura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correlativoBoleta => $composableBuilder(
    column: $table.correlativoBoleta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correlativoFactura => $composableBuilder(
    column: $table.correlativoFactura,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igv =>
      $composableBuilder(column: $table.igv, builder: (column) => column);

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<String> get impresora =>
      $composableBuilder(column: $table.impresora, builder: (column) => column);
}

class $$EmpresaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmpresaTable,
          EmpresaData,
          $$EmpresaTableFilterComposer,
          $$EmpresaTableOrderingComposer,
          $$EmpresaTableAnnotationComposer,
          $$EmpresaTableCreateCompanionBuilder,
          $$EmpresaTableUpdateCompanionBuilder,
          (
            EmpresaData,
            BaseReferences<_$AppDatabase, $EmpresaTable, EmpresaData>,
          ),
          EmpresaData,
          PrefetchHooks Function()
        > {
  $$EmpresaTableTableManager(_$AppDatabase db, $EmpresaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmpresaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmpresaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmpresaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> ruc = const Value.absent(),
                Value<String> tipoContribuyente = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> instagram = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String> serieBoleta = const Value.absent(),
                Value<String> serieFactura = const Value.absent(),
                Value<int> correlativoBoleta = const Value.absent(),
                Value<int> correlativoFactura = const Value.absent(),
                Value<double> igv = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<String?> impresora = const Value.absent(),
              }) => EmpresaCompanion(
                id: id,
                nombre: nombre,
                ruc: ruc,
                tipoContribuyente: tipoContribuyente,
                direccion: direccion,
                telefono: telefono,
                instagram: instagram,
                logo: logo,
                serieBoleta: serieBoleta,
                serieFactura: serieFactura,
                correlativoBoleta: correlativoBoleta,
                correlativoFactura: correlativoFactura,
                igv: igv,
                moneda: moneda,
                impresora: impresora,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required String ruc,
                Value<String> tipoContribuyente = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> instagram = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String> serieBoleta = const Value.absent(),
                Value<String> serieFactura = const Value.absent(),
                Value<int> correlativoBoleta = const Value.absent(),
                Value<int> correlativoFactura = const Value.absent(),
                Value<double> igv = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<String?> impresora = const Value.absent(),
              }) => EmpresaCompanion.insert(
                id: id,
                nombre: nombre,
                ruc: ruc,
                tipoContribuyente: tipoContribuyente,
                direccion: direccion,
                telefono: telefono,
                instagram: instagram,
                logo: logo,
                serieBoleta: serieBoleta,
                serieFactura: serieFactura,
                correlativoBoleta: correlativoBoleta,
                correlativoFactura: correlativoFactura,
                igv: igv,
                moneda: moneda,
                impresora: impresora,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmpresaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmpresaTable,
      EmpresaData,
      $$EmpresaTableFilterComposer,
      $$EmpresaTableOrderingComposer,
      $$EmpresaTableAnnotationComposer,
      $$EmpresaTableCreateCompanionBuilder,
      $$EmpresaTableUpdateCompanionBuilder,
      (EmpresaData, BaseReferences<_$AppDatabase, $EmpresaTable, EmpresaData>),
      EmpresaData,
      PrefetchHooks Function()
    >;
typedef $$CajasTableCreateCompanionBuilder =
    CajasCompanion Function({
      Value<int> id,
      Value<DateTime> fechaApertura,
      Value<double> montoInicial,
      Value<DateTime?> fechaCierre,
      Value<double?> montoCierre,
      Value<String> estado,
      Value<String?> observaciones,
    });
typedef $$CajasTableUpdateCompanionBuilder =
    CajasCompanion Function({
      Value<int> id,
      Value<DateTime> fechaApertura,
      Value<double> montoInicial,
      Value<DateTime?> fechaCierre,
      Value<double?> montoCierre,
      Value<String> estado,
      Value<String?> observaciones,
    });

class $$CajasTableFilterComposer extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoInicial => $composableBuilder(
    column: $table.montoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoCierre => $composableBuilder(
    column: $table.montoCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CajasTableOrderingComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoInicial => $composableBuilder(
    column: $table.montoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoCierre => $composableBuilder(
    column: $table.montoCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CajasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoInicial => $composableBuilder(
    column: $table.montoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoCierre => $composableBuilder(
    column: $table.montoCierre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );
}

class $$CajasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CajasTable,
          Caja,
          $$CajasTableFilterComposer,
          $$CajasTableOrderingComposer,
          $$CajasTableAnnotationComposer,
          $$CajasTableCreateCompanionBuilder,
          $$CajasTableUpdateCompanionBuilder,
          (Caja, BaseReferences<_$AppDatabase, $CajasTable, Caja>),
          Caja,
          PrefetchHooks Function()
        > {
  $$CajasTableTableManager(_$AppDatabase db, $CajasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fechaApertura = const Value.absent(),
                Value<double> montoInicial = const Value.absent(),
                Value<DateTime?> fechaCierre = const Value.absent(),
                Value<double?> montoCierre = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => CajasCompanion(
                id: id,
                fechaApertura: fechaApertura,
                montoInicial: montoInicial,
                fechaCierre: fechaCierre,
                montoCierre: montoCierre,
                estado: estado,
                observaciones: observaciones,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fechaApertura = const Value.absent(),
                Value<double> montoInicial = const Value.absent(),
                Value<DateTime?> fechaCierre = const Value.absent(),
                Value<double?> montoCierre = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => CajasCompanion.insert(
                id: id,
                fechaApertura: fechaApertura,
                montoInicial: montoInicial,
                fechaCierre: fechaCierre,
                montoCierre: montoCierre,
                estado: estado,
                observaciones: observaciones,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CajasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CajasTable,
      Caja,
      $$CajasTableFilterComposer,
      $$CajasTableOrderingComposer,
      $$CajasTableAnnotationComposer,
      $$CajasTableCreateCompanionBuilder,
      $$CajasTableUpdateCompanionBuilder,
      (Caja, BaseReferences<_$AppDatabase, $CajasTable, Caja>),
      Caja,
      PrefetchHooks Function()
    >;
typedef $$MovimientosCajaTableCreateCompanionBuilder =
    MovimientosCajaCompanion Function({
      Value<int> id,
      required int cajaId,
      Value<DateTime> fecha,
      required String tipo,
      required String concepto,
      required double monto,
      Value<String?> metodoPago,
      Value<String?> referencia,
      Value<String?> observacion,
    });
typedef $$MovimientosCajaTableUpdateCompanionBuilder =
    MovimientosCajaCompanion Function({
      Value<int> id,
      Value<int> cajaId,
      Value<DateTime> fecha,
      Value<String> tipo,
      Value<String> concepto,
      Value<double> monto,
      Value<String?> metodoPago,
      Value<String?> referencia,
      Value<String?> observacion,
    });

class $$MovimientosCajaTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosCajaTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosCajaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cajaId =>
      $composableBuilder(column: $table.cajaId, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referencia => $composableBuilder(
    column: $table.referencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacion => $composableBuilder(
    column: $table.observacion,
    builder: (column) => column,
  );
}

class $$MovimientosCajaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosCajaTable,
          MovimientosCajaData,
          $$MovimientosCajaTableFilterComposer,
          $$MovimientosCajaTableOrderingComposer,
          $$MovimientosCajaTableAnnotationComposer,
          $$MovimientosCajaTableCreateCompanionBuilder,
          $$MovimientosCajaTableUpdateCompanionBuilder,
          (
            MovimientosCajaData,
            BaseReferences<
              _$AppDatabase,
              $MovimientosCajaTable,
              MovimientosCajaData
            >,
          ),
          MovimientosCajaData,
          PrefetchHooks Function()
        > {
  $$MovimientosCajaTableTableManager(
    _$AppDatabase db,
    $MovimientosCajaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosCajaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosCajaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosCajaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cajaId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<String?> metodoPago = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
              }) => MovimientosCajaCompanion(
                id: id,
                cajaId: cajaId,
                fecha: fecha,
                tipo: tipo,
                concepto: concepto,
                monto: monto,
                metodoPago: metodoPago,
                referencia: referencia,
                observacion: observacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cajaId,
                Value<DateTime> fecha = const Value.absent(),
                required String tipo,
                required String concepto,
                required double monto,
                Value<String?> metodoPago = const Value.absent(),
                Value<String?> referencia = const Value.absent(),
                Value<String?> observacion = const Value.absent(),
              }) => MovimientosCajaCompanion.insert(
                id: id,
                cajaId: cajaId,
                fecha: fecha,
                tipo: tipo,
                concepto: concepto,
                monto: monto,
                metodoPago: metodoPago,
                referencia: referencia,
                observacion: observacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosCajaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosCajaTable,
      MovimientosCajaData,
      $$MovimientosCajaTableFilterComposer,
      $$MovimientosCajaTableOrderingComposer,
      $$MovimientosCajaTableAnnotationComposer,
      $$MovimientosCajaTableCreateCompanionBuilder,
      $$MovimientosCajaTableUpdateCompanionBuilder,
      (
        MovimientosCajaData,
        BaseReferences<
          _$AppDatabase,
          $MovimientosCajaTable,
          MovimientosCajaData
        >,
      ),
      MovimientosCajaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$InsumosTableTableManager get insumos =>
      $$InsumosTableTableManager(_db, _db.insumos);
  $$RecetasTableTableManager get recetas =>
      $$RecetasTableTableManager(_db, _db.recetas);
  $$RecetaDetalleTableTableManager get recetaDetalle =>
      $$RecetaDetalleTableTableManager(_db, _db.recetaDetalle);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$DetalleVentasTableTableManager get detalleVentas =>
      $$DetalleVentasTableTableManager(_db, _db.detalleVentas);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$MovimientosInventarioTableTableManager get movimientosInventario =>
      $$MovimientosInventarioTableTableManager(_db, _db.movimientosInventario);
  $$EmpresaTableTableManager get empresa =>
      $$EmpresaTableTableManager(_db, _db.empresa);
  $$CajasTableTableManager get cajas =>
      $$CajasTableTableManager(_db, _db.cajas);
  $$MovimientosCajaTableTableManager get movimientosCaja =>
      $$MovimientosCajaTableTableManager(_db, _db.movimientosCaja);
}
