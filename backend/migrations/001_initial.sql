CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE establecimientos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dispositivos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  establecimiento_id uuid NOT NULL REFERENCES establecimientos(id),
  nombre text NOT NULL,
  plataforma text NOT NULL,
  activo boolean NOT NULL DEFAULT true,
  ultimo_acceso timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE usuarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  establecimiento_id uuid NOT NULL REFERENCES establecimientos(id),
  usuario text NOT NULL,
  nombre text NOT NULL,
  pin_hash text NOT NULL,
  rol text NOT NULL DEFAULT 'CAJERO' CHECK (rol IN ('CEO','CAJERO')),
  intentos_fallidos integer NOT NULL DEFAULT 0 CHECK (intentos_fallidos >= 0),
  bloqueado_hasta timestamptz,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX ux_usuarios_establecimiento_usuario_lower
  ON usuarios (establecimiento_id, lower(usuario));

CREATE TABLE permisos_usuario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id uuid NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  modulo text NOT NULL,
  permitido boolean NOT NULL DEFAULT false,
  UNIQUE(usuario_id, modulo)
);

CREATE TABLE categorias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL UNIQUE,
  icono text NOT NULL DEFAULT '📦',
  orden integer NOT NULL DEFAULT 0,
  activo boolean NOT NULL DEFAULT true
);

CREATE TABLE productos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo text NOT NULL UNIQUE,
  codigo_barras text,
  nombre text NOT NULL,
  descripcion text NOT NULL DEFAULT '',
  categoria_id uuid NOT NULL REFERENCES categorias(id),
  costo numeric(12,2) NOT NULL DEFAULT 0,
  precio_venta numeric(12,2) NOT NULL DEFAULT 0,
  stock_minimo numeric(14,4) NOT NULL DEFAULT 0,
  tipo_inventario text NOT NULL DEFAULT 'producto',
  tipo_afectacion_igv text NOT NULL DEFAULT '10',
  emoji text NOT NULL DEFAULT '📦',
  imagen text NOT NULL DEFAULT '',
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (tipo_inventario IN ('producto','receta'))
);

CREATE TABLE insumos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo text NOT NULL UNIQUE,
  nombre text NOT NULL,
  descripcion text NOT NULL DEFAULT '',
  categoria_id uuid NOT NULL REFERENCES categorias(id),
  unidad_medida text NOT NULL,
  stock_minimo numeric(14,4) NOT NULL DEFAULT 0,
  costo_compra numeric(12,2) NOT NULL DEFAULT 0,
  emoji text NOT NULL DEFAULT '📦',
  imagen text NOT NULL DEFAULT '',
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE recetas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  producto_id uuid NOT NULL UNIQUE REFERENCES productos(id),
  nombre text NOT NULL,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE receta_detalle (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  receta_id uuid NOT NULL REFERENCES recetas(id) ON DELETE CASCADE,
  insumo_id uuid NOT NULL REFERENCES insumos(id),
  cantidad numeric(14,4) NOT NULL,
  unidad text NOT NULL DEFAULT 'unid',
  orden integer NOT NULL DEFAULT 0,
  CHECK (cantidad > 0)
);

CREATE TABLE clientes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  dni text,
  ruc text,
  telefono text,
  correo text,
  direccion text,
  fecha_registro timestamptz NOT NULL DEFAULT now(),
  ultima_visita timestamptz,
  total_gastado numeric(12,2) NOT NULL DEFAULT 0,
  cantidad_compras integer NOT NULL DEFAULT 0,
  observaciones text
);

CREATE TABLE cajas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  establecimiento_id uuid NOT NULL REFERENCES establecimientos(id),
  fecha_apertura timestamptz NOT NULL DEFAULT now(),
  monto_inicial numeric(12,2) NOT NULL DEFAULT 0,
  fecha_cierre timestamptz,
  monto_cierre numeric(12,2),
  estado text NOT NULL DEFAULT 'ABIERTA',
  usuario_apertura_id uuid NOT NULL REFERENCES usuarios(id),
  usuario_cierre_id uuid REFERENCES usuarios(id),
  dispositivo_apertura_id uuid NOT NULL REFERENCES dispositivos(id),
  dispositivo_cierre_id uuid REFERENCES dispositivos(id),
  observaciones text,
  CHECK (estado IN ('ABIERTA','CERRADA'))
);

CREATE TABLE ventas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero text NOT NULL UNIQUE,
  usuario_id uuid REFERENCES usuarios(id),
  caja_id uuid NOT NULL REFERENCES cajas(id),
  dispositivo_id uuid NOT NULL REFERENCES dispositivos(id),
  cliente_id uuid REFERENCES clientes(id),
  fecha timestamptz NOT NULL DEFAULT now(),
  tipo_documento text NOT NULL DEFAULT 'Nota de Venta',
  dni text,
  ruc text,
  nombre_cliente text,
  razon_social text,
  direccion_fiscal text,
  subtotal numeric(12,2) NOT NULL DEFAULT 0,
  igv numeric(12,2) NOT NULL DEFAULT 0,
  descuento numeric(12,2) NOT NULL DEFAULT 0,
  total numeric(12,2) NOT NULL DEFAULT 0,
  metodo_pago text NOT NULL DEFAULT 'Efectivo',
  observaciones text,
  idempotency_key uuid NOT NULL UNIQUE
);

CREATE TABLE detalle_ventas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venta_id uuid NOT NULL REFERENCES ventas(id) ON DELETE RESTRICT,
  producto_id uuid NOT NULL REFERENCES productos(id),
  nombre_producto text NOT NULL,
  cantidad integer NOT NULL DEFAULT 1 CHECK (cantidad > 0),
  precio_unitario numeric(12,2) NOT NULL DEFAULT 0,
  subtotal numeric(12,2) NOT NULL DEFAULT 0,
  tamano text,
  tipo_leche text,
  endulzante text,
  infusion text,
  extra_shot boolean NOT NULL DEFAULT false,
  observaciones text,
  tipo_afectacion_igv text NOT NULL DEFAULT '10'
);

CREATE TABLE movimientos_inventario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha timestamptz NOT NULL DEFAULT now(),
  tipo text NOT NULL,
  nombre_item text NOT NULL DEFAULT '',
  emoji text NOT NULL DEFAULT '📦',
  unidad text NOT NULL DEFAULT '',
  referencia_id uuid,
  insumo_id uuid REFERENCES insumos(id),
  producto_id uuid REFERENCES productos(id),
  cantidad numeric(14,4) NOT NULL CHECK (cantidad > 0),
  signo smallint NOT NULL CHECK (signo IN (-1,1)),
  observacion text,
  usuario_id uuid REFERENCES usuarios(id),
  dispositivo_id uuid REFERENCES dispositivos(id),
  idempotency_key uuid NOT NULL UNIQUE,
  CHECK ((insumo_id IS NOT NULL) <> (producto_id IS NOT NULL))
);

CREATE TABLE movimientos_caja (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  caja_id uuid NOT NULL REFERENCES cajas(id) ON DELETE RESTRICT,
  fecha timestamptz NOT NULL DEFAULT now(),
  tipo text NOT NULL,
  concepto text NOT NULL,
  monto numeric(12,2) NOT NULL,
  metodo_pago text,
  referencia text,
  observacion text,
  usuario_id uuid REFERENCES usuarios(id),
  dispositivo_id uuid REFERENCES dispositivos(id),
  idempotency_key uuid UNIQUE
);

CREATE TABLE pedidos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  numero text NOT NULL UNIQUE,
  ubicacion_id text NOT NULL,
  ubicacion_nombre text NOT NULL,
  es_mesa boolean NOT NULL DEFAULT true,
  fecha_apertura timestamptz NOT NULL DEFAULT now(),
  estado text NOT NULL DEFAULT 'abierto',
  numero_comanda integer NOT NULL DEFAULT 0,
  observaciones text NOT NULL DEFAULT '',
  total numeric(12,2) NOT NULL DEFAULT 0,
  usuario_id uuid REFERENCES usuarios(id),
  dispositivo_id uuid REFERENCES dispositivos(id)
);

CREATE TABLE pedido_detalles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id uuid NOT NULL REFERENCES pedidos(id) ON DELETE CASCADE,
  producto_id uuid NOT NULL REFERENCES productos(id),
  codigo_producto text NOT NULL,
  nombre_producto text NOT NULL,
  cantidad integer NOT NULL DEFAULT 1 CHECK (cantidad > 0),
  cantidad_comandada integer NOT NULL DEFAULT 0 CHECK (cantidad_comandada >= 0),
  precio_unitario numeric(12,2) NOT NULL DEFAULT 0,
  subtotal numeric(12,2) NOT NULL DEFAULT 0,
  tamano text,
  tipo_leche text,
  endulzante text,
  infusion text,
  extra_shot boolean NOT NULL DEFAULT false,
  observaciones text,
  orden integer NOT NULL DEFAULT 0
);

CREATE TABLE correlativos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clave text NOT NULL UNIQUE,
  ultimo_numero bigint NOT NULL DEFAULT 0
);

CREATE TABLE comprobantes_electronicos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  venta_id uuid REFERENCES ventas(id),
  comprobante_relacionado_id uuid REFERENCES comprobantes_electronicos(id),
  tipo text NOT NULL,
  serie text NOT NULL,
  numero bigint NOT NULL,
  fecha_emision timestamptz NOT NULL,
  dni text,
  ruc text,
  nombre_cliente text,
  direccion_fiscal text,
  razon_social text,
  subtotal numeric(12,2) NOT NULL,
  igv numeric(12,2) NOT NULL,
  total numeric(12,2) NOT NULL,
  metodo_pago text NOT NULL,
  estado text NOT NULL DEFAULT 'pendiente',
  codigo_respuesta_sunat text,
  mensaje_respuesta_sunat text,
  cdr text,
  xml text,
  fecha_envio_sunat timestamptz,
  fecha_respuesta_sunat timestamptz,
  codigo_motivo_nota_credito text,
  motivo_nota_credito text,
  observaciones text,
  UNIQUE(tipo, serie, numero)
);

CREATE TABLE resumenes_diarios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha_referencia date NOT NULL,
  correlativo bigint NOT NULL,
  nombre_archivo text NOT NULL,
  xml text,
  estado text NOT NULL DEFAULT 'pendiente',
  ticket_sunat text,
  codigo_respuesta_sunat text,
  mensaje_respuesta_sunat text,
  cdr text,
  fecha_envio_sunat timestamptz,
  fecha_respuesta_sunat timestamptz,
  observaciones text,
  UNIQUE(fecha_referencia, correlativo)
);

CREATE TABLE resumenes_diarios_detalles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resumen_diario_id uuid NOT NULL REFERENCES resumenes_diarios(id) ON DELETE CASCADE,
  comprobante_electronico_id uuid NOT NULL REFERENCES comprobantes_electronicos(id),
  line_id integer NOT NULL,
  UNIQUE(resumen_diario_id, comprobante_electronico_id)
);

CREATE TABLE sesiones (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id uuid NOT NULL REFERENCES usuarios(id),
  dispositivo_id uuid NOT NULL REFERENCES dispositivos(id),
  token_hash text NOT NULL UNIQUE,
  fecha_inicio timestamptz NOT NULL DEFAULT now(),
  fecha_ultimo_acceso timestamptz NOT NULL DEFAULT now(),
  fecha_cierre timestamptz,
  expira_en timestamptz NOT NULL,
  estado text NOT NULL DEFAULT 'ACTIVA',
  CHECK (estado IN ('ACTIVA','CERRADA','REVOCADA'))
);

CREATE TABLE auditoria (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fecha timestamptz NOT NULL DEFAULT now(),
  usuario_id uuid REFERENCES usuarios(id),
  dispositivo_id uuid REFERENCES dispositivos(id),
  entidad text NOT NULL,
  entidad_id uuid,
  accion text NOT NULL,
  datos_antes jsonb,
  datos_despues jsonb
);

CREATE TABLE sync_cursors (
  dispositivo_id uuid NOT NULL REFERENCES dispositivos(id) ON DELETE CASCADE,
  entidad text NOT NULL,
  cursor bigint NOT NULL DEFAULT 0,
  fecha_sincronizacion timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(dispositivo_id, entidad)
);

CREATE UNIQUE INDEX ux_caja_abierta_establecimiento
  ON cajas(establecimiento_id)
  WHERE estado = 'ABIERTA';
