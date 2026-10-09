# AZUL OS — API v1

## Estado

Este documento separa las rutas implementadas en la rama de desarrollo de las rutas previstas. El backend aún no está conectado a Flutter ni debe usarse en producción.

Base local: `http://127.0.0.1:8080`. En cualquier despliegue accesible desde una red, usar HTTPS.

## Rutas implementadas

### Salud

- `GET /health/live`: confirma que el proceso está activo.
- `GET /health/ready`: verifica conexión con PostgreSQL; devuelve `503` si no está disponible.

### Autenticación

#### `POST /api/v1/auth/login`

Request:

```json
{
  "establishmentId": "UUID",
  "username": "usuario",
  "pin": "1234",
  "deviceId": "UUID"
}
```

El PIN debe tener exactamente cuatro dígitos. El usuario y el dispositivo deben existir, estar activos y pertenecer al establecimiento indicado.

Respuesta correcta: token Bearer firmado, vencimiento y datos básicos del usuario. El token vence a las 12 horas; la sesión se almacena en PostgreSQL como hash para poder revocarla.

- `GET /api/v1/auth/me`: devuelve usuario, establecimiento y rol; requiere token.
- `POST /api/v1/auth/logout`: cierra la sesión; requiere token.
- Protección contra intentos repetidos: límite por IP y bloqueo temporal de la cuenta tras intentos fallidos.

Los errores de autenticación no deben revelar si existe un usuario concreto.

### Catálogos de solo lectura

Las rutas requieren autenticación y permiso de módulo; el rol CEO omite los permisos de módulo.

- `GET /api/v1/catalog/products?q=&categoryId=&limit=50&offset=0` — módulo `Productos`.
- `GET /api/v1/catalog/categories` — módulo `Productos`.
- `GET /api/v1/catalog/insumos?q=&categoryId=&limit=50&offset=0` — módulo `Inventario`.

Las respuestas incluyen una lista `items` y, en las rutas paginadas, `pagination.limit`, `pagination.offset` y `pagination.total`.

### Inventario de solo lectura

El stock se calcula sumando los movimientos de inventario; no se mantiene mediante una edición directa del saldo.

- `GET /api/v1/inventory/stock?itemType=todos&q=&lowStockOnly=false&limit=50&offset=0` — módulo `Inventario`.
- `GET /api/v1/inventory/movements?itemType=&itemId=&limit=50&offset=0` — módulo `Inventario`.

`itemType` acepta `producto`, `insumo` o `todos` para el endpoint de stock; el historial acepta `producto` o `insumo`. La paginación está limitada a 100 resultados por petición.

## Contrato previsto, todavía no implementado

Estas rutas describen fases futuras; no deben considerarse disponibles:

- escritura y administración de productos, insumos, recetas y clientes;
- entradas y ajustes de inventario con idempotencia y auditoría;
- apertura, movimientos y cierre de caja;
- pedidos y comandas;
- ventas con una sola transacción para venta, detalles, inventario, caja y correlativos;
- emisión y procesamiento de comprobantes SUNAT en el servidor;
- sincronización incremental y resolución de conflictos entre dispositivos.

Antes de implementar las escrituras se definirán las reglas de stock negativo, unidades, precios, permisos, claves de idempotencia y reversos. No se expondrá un endpoint que permita editar directamente el saldo de inventario.

## Pagos en ventas

La API de ventas acepta actualmente un solo medio por venta: `Efectivo`, `Yape`, `Plin` o `Tarjeta`. `Mixto` se rechaza con `400 VALIDATION_ERROR` hasta que exista un desglose explícito por medio de pago; esto evita que el cierre de caja atribuya incorrectamente el importe completo al efectivo o lo deje sin conciliación.

## Formato de error

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Datos inválidos."
  }
}
```

Ocultar un botón en Flutter nunca reemplaza la autorización del backend.

## Seguridad y producción

- No distribuir certificados ni credenciales SUNAT a los dispositivos.
- No guardar PIN en texto plano.
- Mantener `JWT_SECRET` fuera del repositorio y con al menos 32 caracteres aleatorios.
- No exponer PostgreSQL a internet.
- No ejecutar la migración inicial sobre la base SQLite de producción.
