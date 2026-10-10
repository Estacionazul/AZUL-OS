# AZUL OS Backend

Backend central en TypeScript, Express y PostgreSQL para preparar la operación multidispositivo de Estación Azul.

## Estado de implementación

Esta es una rama de desarrollo. Flutter incluye cliente API y pantallas aisladas para configurar la conexión, consultar catálogo, inventario, caja y ventas centrales. Estos flujos no sincronizan ni migran el SQLite local, no emiten comprobantes SUNAT y no están aprobados para producción. Las pruebas de CI no sustituyen la aceptación en dispositivos reales.

## Funcionalidad implementada en esta rama

- Configuración por entorno, pool PostgreSQL y health checks: `GET /health/live`, `GET /health/ready`.
- Autenticación por establecimiento, usuario, PIN de cuatro dígitos y dispositivo registrado.
- Hash bcrypt, bloqueo temporal tras intentos fallidos, limitación de solicitudes, JWT firmado y sesión revocable.
- Autorización por rol y permisos de módulo.
- Catálogo de productos, categorías, insumos, recetas y stock.
- Movimientos de inventario transaccionales e idempotentes, con protección contra stock negativo.
- Apertura, consulta y cierre de caja; los cierres admiten reintento idempotente.
- Ventas transaccionales con control de establecimiento, stock, correlativo, idempotencia y desglose de pagos mixtos.
- Administración protegida por CEO de dispositivos, cajeros, permisos, categorías, productos, insumos y recetas.
- API de clientes aislada por establecimiento.
- Runner de migraciones PostgreSQL versionadas con bloqueo advisory.
- CI con PostgreSQL para validar migraciones, compilación y pruebas de integración.

## Endpoints implementados

- Salud: `GET /health/live`, `GET /health/ready`
- Autenticación: `POST /api/v1/auth/login`, `GET /api/v1/auth/me`, `POST /api/v1/auth/logout`
- Catálogo: `GET /api/v1/catalog/products`, `GET /api/v1/catalog/categories`, `GET /api/v1/catalog/insumos`, `GET /api/v1/catalog/recipes`
- Inventario: `GET /api/v1/inventory/stock`, `GET /api/v1/inventory/movements`, `POST /api/v1/inventory/movements`
- Caja: `GET /api/v1/cash/current`, `POST /api/v1/cash/open`, `POST /api/v1/cash/close`, `GET/POST /api/v1/cash/movements`
- Ventas: `GET /api/v1/sales`, `GET /api/v1/sales/:id`, `POST /api/v1/sales`
- Administración CEO: rutas `/api/v1/admin/devices`, `/api/v1/admin/users` y `/api/v1/admin/catalog/*`
- Clientes: `GET/POST /api/v1/customers`, `PATCH /api/v1/customers/:id`

Las rutas protegidas requieren `Authorization: Bearer <token>` y los permisos correspondientes. Las escrituras de inventario, caja y ventas requieren `Idempotency-Key` UUID.

Consulta [API_V1.md](./API_V1.md) para contratos y limitaciones.

## Requisitos y desarrollo local

Requisitos: Node.js 22+ y PostgreSQL 16 o compatible con `pgcrypto`.

1. Copia `.env.example` a `.env`.
2. Configura `DATABASE_URL` para una base PostgreSQL **nueva y vacía** y genera un `JWT_SECRET` privado de al menos 32 caracteres. No uses los valores de ejemplo.
3. Instala dependencias con `npm install`.
4. Verifica cuidadosamente que `DATABASE_URL` apunta a la base de desarrollo correcta.
5. Aplica las migraciones versionadas únicamente a esa base vacía. El runner exige confirmación explícita:
   - PowerShell: `$env:MIGRATIONS_CONFIRM="APPLY_AZUL_MIGRATIONS"; npm run migrate`
   - Bash: `MIGRATIONS_CONFIRM=APPLY_AZUL_MIGRATIONS npm run migrate`

   El runner toma un bloqueo advisory, registra cada archivo en `schema_migrations` y se niega a adoptar una base que ya tenga tablas pero no historial de migraciones. No ejecutes este proceso sobre una base existente de propiedad incierta.
6. Para crear el CEO inicial y un dispositivo en esa base vacía, configura las seis variables `BOOTSTRAP_*` descritas en [Inicio seguro](./docs/INICIO_SEGURO.md), además de `BOOTSTRAP_CONFIRM=CREATE_INITIAL_CEO_AND_DEVICE`. Ejecuta `npm run bootstrap:ceo` una sola vez. El comando rechaza un establecimiento ya existente y no imprime el PIN.
7. Ejecuta `npm run typecheck`, `npm run build` y `npm test`.

## Seguridad y límites de producción

- No subir `.env`, contraseñas, PIN, claves, tokens ni certificados.
- Usar TLS/HTTPS en cualquier entorno accesible desde una red.
- No exponer PostgreSQL públicamente y restringir CORS a los orígenes necesarios.
- Gestionar secretos fuera del repositorio.
- No conectar aún el SQLite de producción ni alterar ventas históricas, notas, boletas, facturas, caja o correlativos.
- No desplegar ni ejecutar migraciones de producción sin revisión, staging, respaldos y aprobación explícita.
- La emisión, firma, envío y reconciliación de comprobantes SUNAT en el backend, sincronización incremental y resolución de conflictos aún requieren implementación y pruebas.
- Validar flujos completos en Windows, Android y tabletas antes de habilitar la operación multidispositivo.

El certificado SUNAT no debe distribuirse a los dispositivos. El funcionamiento actual de producción y la impresión local deben permanecer intactos.
