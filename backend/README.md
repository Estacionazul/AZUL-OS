# AZUL OS Backend

Backend central en TypeScript, Express y PostgreSQL para preparar la operación multidispositivo de Estación Azul.

## Estado de implementación

En esta rama:
- configuración obligatoria por entorno y pool PostgreSQL;
- health checks: `GET /health/live` y `GET /health/ready`;
- login por establecimiento, usuario, PIN de cuatro dígitos y dispositivo registrado;
- PIN con hash bcrypt, bloqueo tras cinco intentos fallidos y límite de solicitudes;
- JWT firmado, sesión almacenada como hash, expiración de 12 horas y cierre revocable;
- autorización por rol y permisos de módulo;
- catálogo de productos/categorías y consulta de insumos, con búsqueda, paginación y permisos de módulo;
- migración inicial PostgreSQL y workflow CI con PostgreSQL para validar esquema, compilación y pruebas.

## Endpoints

- `GET /health/live`
- `GET /health/ready`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`
- `GET /api/v1/catalog/products?q=&categoryId=&limit=50&offset=0`
- `GET /api/v1/catalog/categories`
- `GET /api/v1/catalog/insumos?q=&categoryId=&limit=50&offset=0`
- `GET /api/v1/inventory/stock?itemType=todos&q=&lowStockOnly=false&limit=50&offset=0`
- `GET /api/v1/inventory/movements?itemId=&itemType=&limit=50&offset=0`
- `GET /api/v1/catalog/insumos?q=&categoryId=&limit=50&offset=0`

Las rutas protegidas requieren `Authorization: Bearer <token>`. El login requiere `establishmentId`, `username`, `pin` y `deviceId`; el usuario y el dispositivo deben existir y estar activos.

## Desarrollo local

Requisitos: Node.js 22+ y PostgreSQL 16 o compatible con `pgcrypto`. Utiliza una base de datos de desarrollo vacía, nunca la SQLite de producción.

1. Copia `.env.example` a `.env`.
2. Configura `DATABASE_URL` y genera un `JWT_SECRET` aleatorio de al menos 32 caracteres. No uses el valor de ejemplo.
3. Instala dependencias con `npm install`.
4. Valida la migración solo en la base vacía de desarrollo:
   - Bash: `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`
   - PowerShell: `psql $env:DATABASE_URL -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`
5. Para crear el primer CEO y un dispositivo en una base vacía, configura las seis variables `BOOTSTRAP_*` requeridas por `src/scripts/bootstrap-ceo.ts` en tu entorno local; no las subas al repositorio y ejecuta `npm run bootstrap:ceo`. El comando se niega a ejecutarse si ya existe un establecimiento y no imprime el PIN.
6. Ejecuta `npm run typecheck`, `npm run build` y `npm test`.

## Pendiente antes de producción

- Ejecutar y revisar el workflow CI y las pruebas de integración.
- Probar el esquema y el login contra PostgreSQL real.
- Añadir operaciones de escritura de inventario con transacciones e idempotencia, además de recetas, caja y ventas;
- Completar alta/baja administrativa de dispositivos y usuarios.
- Conectar Flutter y probar cada plataforma.
- Desplegar con HTTPS, secretos administrados y PostgreSQL no expuesto a internet.

No conectar aún este backend a la aplicación de producción. No ejecutar la migración sobre SQLite ni sobre datos reales de SUNAT. El certificado SUNAT no debe distribuirse a los dispositivos.
