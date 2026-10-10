# AZUL OS Backend

Backend central en TypeScript, Express y PostgreSQL para preparar la operación multidispositivo de Estación Azul.

## Estado de implementación

Esta es una rama de desarrollo. Flutter incluye un cliente API seguro y una pantalla para configurar/probar conexión; las ventas y demás flujos operativos aún siguen en SQLite local y no están conectados al backend. Las pruebas CI no equivalen a aceptación en dispositivos reales.

En esta rama:
- configuración por entorno y pool PostgreSQL;
- health checks: `GET /health/live` y `GET /health/ready`;
- login por establecimiento, usuario, PIN de cuatro dígitos y dispositivo registrado;
- PIN con hash bcrypt, bloqueo temporal tras intentos fallidos y limitación de solicitudes;
- JWT firmado, sesión almacenada como hash, expiración de 12 horas y cierre revocable;
- autorización por rol y permisos de módulo;
- consultas de productos, categorías, insumos, recetas y stock;
- movimientos de inventario transaccionales e idempotentes, con protección contra stock negativo;
- apertura, consulta y cierre de caja;
- registro e historial de ventas transaccionales, con control de establecimiento, stock, correlativo e idempotencia;
- bootstrap controlado para el primer CEO y dispositivo;\n- administración protegida por CEO para registrar/desactivar dispositivos y crear/gestionar cajeros y permisos;
- operaciones de creación/edición/desactivación lógica de categorías, productos, insumos y recetas, restringidas al CEO;
- API de clientes con búsqueda, paginación, actualización y baja lógica, aislada por establecimiento;
- runner de migraciones PostgreSQL versionadas con bloqueo advisory;
- workflow CI con PostgreSQL para validar migraciones, compilación y pruebas de integración.

## Endpoints implementados

- Salud: `GET /health/live`, `GET /health/ready`
- Autenticación: `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, `POST /api/v1/auth/logout`
- Catálogo: `GET /api/v1/catalog/products`, `GET /api/v1/catalog/categories`, `GET /api/v1/catalog/insumos`, `GET /api/v1/catalog/recipes`
- Inventario: `GET /api/v1/inventory/stock`, `GET /api/v1/inventory/movements`, `POST /api/v1/inventory/movements`
- Caja: `GET /api/v1/cash/current`, `POST /api/v1/cash/open`, `POST /api/v1/cash/close`, `GET/POST /api/v1/cash/movements`
- Ventas: `GET /api/v1/sales`, `GET /api/v1/sales/:id`, `POST /api/v1/sales`\n- Administración CEO: `GET/POST /api/v1/admin/devices`, `PATCH /api/v1/admin/devices/:id`, `GET/POST /api/v1/admin/users`, `PATCH /api/v1/admin/users/:id`
- Catálogo administrativo CEO: `POST/PATCH /api/v1/admin/catalog/categories`, `POST/PATCH /api/v1/admin/catalog/products`, `POST/PATCH /api/v1/admin/catalog/insumos`, `POST/PATCH /api/v1/admin/catalog/recipes`
- Clientes: `GET/POST /api/v1/customers`, `PATCH /api/v1/customers/:id`

Las rutas protegidas requieren `Authorization: Bearer <token>` y permisos del módulo correspondiente. Las escrituras de inventario y ventas requieren `Idempotency-Key` con UUID. La API de ventas admite actualmente un único medio de pago por venta: `Efectivo`, `Yape`, `Plin` o `Tarjeta`; `Mixto` se rechaza hasta implementar su desglose.

Consulta [API_V1.md](./API_V1.md) para los parámetros, contratos y limitaciones de cada endpoint.

## Desarrollo local

Requisitos: Node.js 22+ y PostgreSQL 16 o compatible con `pgcrypto`. Utiliza una base de datos de desarrollo vacía, nunca la SQLite de producción.

1. Copia `.env.example` a `.env`.
2. Configura `DATABASE_URL` y genera un `JWT_SECRET` aleatorio de al menos 32 caracteres. No uses el valor de ejemplo.
3. Instala dependencias con `npm install`.
4. Aplica las migraciones versionadas solo a una base PostgreSQL vacía de desarrollo. El runner exige confirmación explícita:
   - Bash: `MIGRATIONS_CONFIRM=APPLY_AZUL_MIGRATIONS npm run migrate`
   - PowerShell: `$env:MIGRATIONS_CONFIRM="APPLY_AZUL_MIGRATIONS"; npm run migrate`

   El runner toma un bloqueo advisory, registra cada archivo aplicado en `schema_migrations` y se niega a adoptar una base que ya tenga tablas pero no posea historial de migraciones. No lo ejecutes contra producción.
5. Para crear el primer CEO y un dispositivo en una base vacía, configura las seis variables `BOOTSTRAP_*` requeridas por `src/scripts/bootstrap-ceo.ts` en tu entorno local; no las subas al repositorio y ejecuta `npm run bootstrap:ceo`. El comando se niega a ejecutarse si ya existe un establecimiento y no imprime el PIN.
6. Ejecuta `npm run typecheck`, `npm run build` y `npm test`.

## Pendiente antes de producción

- completar pedidos/comandas y pagos mixtos con desglose por medio de pago;
- implementar pedidos/comandas, desglose de pagos mixtos y movimientos manuales de caja;
- implementar en el backend la emisión, firma, envío, consulta y reconciliación de comprobantes SUNAT;
- diseñar y probar sincronización incremental y resolución de conflictos;
- integrar Flutter y validar los flujos completos en Windows, Android y tabletas;
- revisar aceptación funcional y seguridad en un entorno de staging;
- desplegar con HTTPS, secretos administrados, PostgreSQL no expuesto a internet, respaldos y monitoreo.

Los workflows de CI se están ejecutando para los cambios recientes; las pruebas automatizadas no sustituyen la integración y aceptación en dispositivos reales. El backend no debe conectarse aún a la aplicación de producción. No ejecutar migraciones sobre SQLite ni modificar las ventas, notas, boletas o facturas históricas. El certificado SUNAT no debe distribuirse a los dispositivos.
