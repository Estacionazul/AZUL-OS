# AZUL OS — API v1

## Objetivo

Contrato inicial para que Windows, Redmi y tablet consuman la misma operación empresarial.

Base:
HTTPS + JSON.

## Autenticación

POST /api/v1/auth/login

Request:
- usuario
- pin
- dispositivo_id

Response:
- access_token
- refresh_token
- usuario
- permisos
- establecimiento
- dispositivo

El PIN se valida contra un hash del backend.

## Catálogos

GET /api/v1/categorias
GET /api/v1/productos
GET /api/v1/insumos
GET /api/v1/recetas

GET /api/v1/productos/{id}
GET /api/v1/insumos/{id}

POST /api/v1/productos
PATCH /api/v1/productos/{id}

Las operaciones administrativas requieren autorización backend.

## Clientes

GET /api/v1/clientes?search=
POST /api/v1/clientes
PATCH /api/v1/clientes/{id}

## Inventario

GET /api/v1/inventario/kardex
POST /api/v1/inventario/entradas
POST /api/v1/inventario/ajustes

No existe endpoint de edición directa de stock.

## Caja

GET /api/v1/cajas/actual
POST /api/v1/cajas/abrir
POST /api/v1/cajas/{id}/movimientos
POST /api/v1/cajas/{id}/cerrar

El backend impide aperturas/cierres incompatibles.

## Pedidos

GET /api/v1/pedidos/abiertos
POST /api/v1/pedidos
PATCH /api/v1/pedidos/{id}
POST /api/v1/pedidos/{id}/comandar
POST /api/v1/pedidos/{id}/cerrar

## Ventas

POST /api/v1/ventas

La petición debe incluir una idempotency_key única.

El backend ejecuta una única transacción:

1. autorización;
2. caja;
3. catálogo/precios;
4. inventario;
5. venta;
6. detalle;
7. caja;
8. correlativo;
9. facturación.

Response:
- venta_id
- numero
- estado
- comprobante_id cuando corresponda
- totales

GET /api/v1/ventas/{id}
GET /api/v1/ventas?desde=&hasta=

## Facturación

POST /api/v1/comprobantes/{id}/procesar
GET /api/v1/comprobantes/{id}
POST /api/v1/resumenes-diarios

Los clientes no envían certificados ni credenciales SUNAT.

## Sincronización

GET /api/v1/sync?cursor=

El servidor devuelve cambios posteriores al cursor.

POST /api/v1/sync/ack

La sincronización será incremental y auditable.

## Idempotencia

Todas las operaciones de escritura críticas aceptarán una idempotency_key.

Si una petición se repite con la misma clave, el backend devuelve el resultado original en lugar de duplicar la operación.

## Errores

Formato:

{
  "code": "STOCK_INSUFFICIENTE",
  "message": "No hay stock suficiente.",
  "details": {}
}

Códigos iniciales:
- AUTH_REQUIRED
- FORBIDDEN
- CAJA_NO_ABIERTA
- CAJA_YA_CERRADA
- STOCK_INSUFFICIENTE
- RECETA_INVALIDA
- PRODUCTO_NO_EXISTE
- CORRELATIVO_CONFLICTO
- IDEMPOTENCY_CONFLICT
- SUNAT_RECHAZADO
- VALIDATION_ERROR

## Regla de seguridad

Ocultar un botón en Flutter nunca reemplaza la autorización del backend.
