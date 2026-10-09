# AZUL OS — Modelo de Datos Central

Este documento deriva del esquema Drift actual de AZUL OS y define su equivalente lógico para PostgreSQL/API. No modifica la base de producción.

## 1. Catálogos maestros

### categorias
- id UUID
- nombre
- icono
- orden
- activo

### productos
- id UUID
- codigo
- codigo_barras
- nombre
- descripcion
- categoria_id UUID
- costo
- precio_venta
- stock_minimo
- tipo_inventario
- tipo_afectacion_igv
- emoji
- imagen
- activo
- fecha_creacion
- fecha_actualizacion

El stock central no debe depender de un campo editable desde el cliente. El saldo debe derivarse del Kardex o mantenerse mediante una operación transaccional del backend.

### insumos
- id UUID
- codigo
- nombre
- descripcion
- categoria_id UUID
- unidad_medida
- stock_minimo
- costo_compra
- emoji
- imagen
- activo
- fecha_creacion
- fecha_actualizacion

## 2. Recetas

### recetas
- id UUID
- producto_id UUID UNIQUE
- nombre
- activo
- fecha_creacion
- fecha_actualizacion

### receta_detalle
- id UUID
- receta_id UUID
- insumo_id UUID
- cantidad
- unidad
- orden

Regla: un producto de tipo receta debe tener receta válida y detalles válidos antes de poder venderse.

## 3. Clientes

### clientes
- id UUID
- nombre
- dni
- ruc
- telefono
- correo
- direccion
- fecha_registro
- ultima_visita
- total_gastado
- cantidad_compras
- observaciones

Los totales del cliente son datos derivados y deben actualizarse de forma transaccional o reconstruible.

## 4. Ventas

### ventas
- id UUID
- numero
- usuario_id UUID
- caja_id UUID
- fecha
- tipo_documento
- cliente_id UUID nullable
- dni/ruc/nombre_cliente/razon_social/direccion_fiscal como snapshot fiscal
- subtotal
- igv
- descuento
- total
- metodo_pago
- observaciones
- dispositivo_id UUID
- idempotency_key
- fecha_creacion

### detalle_ventas
- id UUID
- venta_id UUID
- producto_id UUID
- nombre_producto snapshot
- cantidad
- precio_unitario
- subtotal
- personalizaciones
- tipo_afectacion_igv

Una venta confirmada no debe modificarse físicamente desde el cliente. Las correcciones fiscales deben utilizar los mecanismos correspondientes.

## 5. Inventario

### movimientos_inventario
- id UUID
- fecha
- tipo
- nombre_item snapshot
- unidad
- referencia_id UUID nullable
- insumo_id UUID nullable
- producto_id UUID nullable
- cantidad
- signo
- observacion
- usuario_id UUID
- dispositivo_id UUID
- idempotency_key

Tipos iniciales:
- ENTRADA
- VENTA
- AJUSTE
- PRODUCCION
- MERMA
- SALIDA

El Kardex es inmutable. No se elimina un movimiento; una corrección se registra como un nuevo movimiento compensatorio.

## 6. Caja

### cajas
- id UUID
- establecimiento_id UUID
- fecha_apertura
- monto_inicial
- fecha_cierre
- monto_cierre
- estado
- usuario_apertura_id UUID
- usuario_cierre_id UUID nullable
- dispositivo_apertura_id UUID
- dispositivo_cierre_id UUID nullable
- observaciones

### movimientos_caja
- id UUID
- caja_id UUID
- fecha
- tipo
- concepto
- monto
- metodo_pago
- referencia
- observacion
- usuario_id UUID
- dispositivo_id UUID
- idempotency_key

Regla: una caja abierta por jornada/establecimiento, salvo que el negocio defina explícitamente otro modelo.

## 7. Usuarios y permisos

### usuarios
- id UUID
- nombre
- pin_hash
- rol
- activo
- fecha_creacion
- fecha_actualizacion

El PIN no debe almacenarse en texto plano en el backend.

### permisos_usuario
- id UUID
- usuario_id UUID
- modulo
- permitido

El backend debe validar autorización, no solamente ocultar módulos en Flutter.

## 8. Pedidos

### pedidos
- id UUID
- numero
- ubicacion_id
- ubicacion_nombre
- es_mesa
- fecha_apertura
- estado
- numero_comanda
- observaciones
- total
- usuario_id UUID
- dispositivo_id UUID

### pedido_detalles
- id UUID
- pedido_id UUID
- producto_id UUID
- codigo_producto snapshot
- nombre_producto snapshot
- cantidad
- cantidad_comandada
- precio_unitario
- subtotal
- personalizaciones
- orden

## 9. Facturación electrónica

### comprobantes_electronicos
- id UUID
- venta_id UUID
- comprobante_relacionado_id UUID nullable
- tipo
- serie
- numero
- fecha_emision
- datos fiscales del adquirente
- subtotal
- igv
- total
- metodo_pago
- estado
- codigo_respuesta_sunat
- mensaje_respuesta_sunat
- cdr
- xml
- fecha_envio_sunat
- fecha_respuesta_sunat
- motivo de nota de crédito
- observaciones

El backend será el único responsable de firmar y enviar a SUNAT.

### correlativos
- id UUID
- clave UNIQUE
- ultimo_numero

La reserva debe ejecutarse dentro de una transacción/lock central.

### resumenes_diarios
- id UUID
- fecha_referencia
- correlativo
- nombre_archivo
- xml
- estado
- ticket_sunat
- codigo_respuesta_sunat
- mensaje_respuesta_sunat
- cdr
- fecha_envio_sunat
- fecha_respuesta_sunat
- observaciones

### resumenes_diarios_detalles
- id UUID
- resumen_diario_id UUID
- comprobante_electronico_id UUID
- line_id
- UNIQUE(resumen_diario_id, comprobante_electronico_id)

## 10. Entidades nuevas para multidispositivo

### establecimientos
Permite preparar la arquitectura para uno o más locales.

### dispositivos
- id UUID
- nombre
- plataforma
- activo
- ultimo_acceso
- usuario_actual_id UUID nullable
- establecimiento_id UUID

### sesiones
- id UUID
- usuario_id UUID
- dispositivo_id UUID
- fecha_inicio
- fecha_ultimo_acceso
- fecha_cierre
- estado

### auditoria
- id UUID
- fecha
- usuario_id UUID
- dispositivo_id UUID
- entidad
- entidad_id UUID
- accion
- datos_antes
- datos_despues
- ip/metadata cuando corresponda

### sync_cursors
- dispositivo_id UUID
- entidad
- cursor
- fecha_sincronizacion

## 11. Identificadores y compatibilidad

Durante la migración:

- los IDs SQLite actuales se mantienen para trazabilidad;
- cada registro central obtiene UUID;
- la relación temporal puede usar una tabla de correspondencia;
- no se renumeran comprobantes existentes;
- no se recalculan ventas históricas;
- no se reescribe el Kardex histórico.

## 12. Restricciones críticas

Nunca confiar en:
- stock enviado por el cliente;
- precio enviado por el cliente;
- correlativo enviado por el cliente;
- permiso enviado por el cliente;
- estado de caja enviado por el cliente.

El backend recalcula/valida estos valores con sus propios datos.
