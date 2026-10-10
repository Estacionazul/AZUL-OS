# AZUL OS — API v1

## Estado

Este documento separa las rutas implementadas en la rama de desarrollo de las rutas previstas. Flutter ya incluye un cliente API y una pantalla para configurar/probar la conexión, pero los flujos de negocio siguen operando con SQLite local y todavía no están conectados al backend. No usar en producción.

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

### Administración (solo CEO)

Estas rutas requieren sesión activa con rol `CEO`. El acceso se valida en el backend, no solo en la interfaz.

- `GET /api/v1/admin/devices`: lista dispositivos del establecimiento.
- `POST /api/v1/admin/devices`: registra dispositivo y devuelve su UUID para configurarlo en el equipo correspondiente. Acepta `windows`, `android`, `tablet`, `ios` o `other`.
- `PATCH /api/v1/admin/devices/:id`: activa o desactiva un dispositivo. Las sesiones de dispositivos desactivados dejan de autenticarse.
- `GET /api/v1/admin/users`: lista usuarios del establecimiento y permisos por módulo.
- `POST /api/v1/admin/users`: crea un cajero con PIN de cuatro dígitos y permisos explícitos. El PIN se guarda con hash y nunca se devuelve.
- `PATCH /api/v1/admin/users/:id`: permite cambiar nombre, activar/desactivar cajero, restablecer PIN o reemplazar permisos. Desactivar usuario o cambiar PIN revoca sus sesiones activas. Esta ruta no permite desactivar el CEO.

### Administración de catálogo (solo CEO)

Estas rutas requieren sesión activa con rol `CEO`. Los códigos y categorías se validan dentro del establecimiento; las desactivaciones son lógicas para conservar referencias históricas.

- `POST /api/v1/admin/catalog/categories`: crea categoría.
- `PATCH /api/v1/admin/catalog/categories/:id`: modifica nombre, icono, orden o estado activo.
- `POST /api/v1/admin/catalog/products`: crea producto, precio, costo, categoría, tipo de inventario y afectación IGV.
- `PATCH /api/v1/admin/catalog/products/:id`: modifica campos del producto o lo desactiva con `active: false`.
- `POST /api/v1/admin/catalog/insumos`: crea insumo y unidad de medida.
- `PATCH /api/v1/admin/catalog/insumos/:id`: modifica campos del insumo o lo desactiva con `active: false`.
- `POST /api/v1/admin/catalog/recipes`: crea una receta, valida que producto e insumos pertenezcan al establecimiento y guarda cabecera/detalles en una transacción.
- `PATCH /api/v1/admin/catalog/recipes/:id`: modifica nombre, estado o reemplaza los ingredientes de una receta de forma transaccional.

Las rutas de escritura devuelven `409` si el código/nombre ya existe en el establecimiento y `404` si la categoría indicada no pertenece a ese establecimiento o no está activa.

### Clientes

Las rutas requieren permiso `Clientes` y filtran siempre por establecimiento.

- `GET /api/v1/customers?q=&limit=50&offset=0&includeInactive=false`: busca clientes con paginación.
- `POST /api/v1/customers`: registra un cliente y valida DNI/RUC.
- `PATCH /api/v1/customers/:id`: actualiza datos o realiza baja lógica con `active: false`. No elimina físicamente clientes vinculados a ventas.

DNI y RUC no vacíos son únicos dentro del establecimiento; la migración 011 se niega a crear índices si encuentra duplicados previos.

### Catálogos de solo lectura

Las rutas requieren autenticación y permiso de módulo; el rol CEO omite los permisos de módulo.

- `GET /api/v1/catalog/products?q=&categoryId=&limit=50&offset=0` — módulo `Productos`.
- `GET /api/v1/catalog/categories` — módulo `Productos`.
- `GET /api/v1/catalog/insumos?q=&categoryId=&limit=50&offset=0` — módulo `Inventario`.

Las respuestas incluyen una lista `items` y, en las rutas paginadas, `pagination.limit`, `pagination.offset` y `pagination.total`.

### Inventario

El stock se calcula sumando los movimientos de inventario; no se mantiene mediante una edición directa del saldo.

- `GET /api/v1/inventory/stock?itemType=todos&q=&lowStockOnly=false&limit=50&offset=0` — módulo `Inventario`.
- `GET /api/v1/inventory/movements?itemType=&itemId=&limit=50&offset=0` — módulo `Inventario`.
- `POST /api/v1/inventory/movements` — módulo `Inventario`; requiere encabezado `Idempotency-Key` con UUID.

El movimiento acepta `itemType` (`producto` o `insumo`), `itemId` (UUID), `type` (`ENTRADA`, `SALIDA` o `AJUSTE`), `quantity` positiva con hasta cuatro decimales, `sign` para ajustes, y `referenceId`/`note` opcionales. Las entradas aumentan stock, las salidas lo reducen, los ajustes requieren signo, se rechaza stock negativo y los productos de receta no admiten movimientos manuales. La misma clave con datos diferentes devuelve conflicto. La paginación está limitada a 100 resultados por petición.

### Caja

Estas rutas requieren autenticación y permiso `Caja`:

- `GET /api/v1/cash/current`: consulta la caja abierta del establecimiento.
- `POST /api/v1/cash/open`: abre caja con `openingAmount` y `note` opcional.
- `POST /api/v1/cash/close`: cierra la caja abierta con `closingAmount` y `note` opcional; devuelve conciliación de efectivo y diferencia.

Todavía no existe una ruta API independiente para registrar movimientos manuales de caja (por ejemplo, gastos o ingresos distintos de ventas).

### Ventas

Estas rutas requieren autenticación y permiso `Ventas`:

- `GET /api/v1/sales?from=&to=&documentType=&limit=50&offset=0`: historial filtrado por establecimiento y rango de fechas.
- `GET /api/v1/sales/:id`: detalle y comprobantes de una venta del establecimiento.
- `POST /api/v1/sales`: registra una venta transaccional con detalles, movimientos de inventario, movimiento de caja y correlativo. Requiere `Idempotency-Key` con UUID. El backend rechaza productos/clientes de otro establecimiento y stock insuficiente.

La API de ventas admite un único medio de pago por venta: `Efectivo`, `Yape`, `Plin` o `Tarjeta`. `Mixto` se rechaza hasta implementar desglose por medio de pago.

## Pendiente antes de producción

Estas funciones aún no deben considerarse disponibles:

- altas, ediciones, bajas y administración completa de productos, insumos, categorías, recetas y clientes;
- pedidos y comandas;
- desglose de pagos mixtos y operaciones manuales de caja;
- emisión, firma, envío, consulta y reconciliación de comprobantes SUNAT desde el backend;
- sincronización incremental, resolución de conflictos y gestión administrativa de dispositivos/usuarios;
- integración con Flutter y validación en Windows, Android y tabletas;
- despliegue seguro con HTTPS, secretos administrados, respaldos y monitoreo.

No existe un endpoint que permita editar directamente el saldo de inventario. Este backend sigue siendo una rama de desarrollo y no debe conectarse a la operación de producción hasta completar la integración y las pruebas de aceptación.

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
