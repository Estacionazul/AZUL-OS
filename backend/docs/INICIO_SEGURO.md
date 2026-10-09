# Inicio seguro del backend y creación del CEO

Este procedimiento es solo para una base PostgreSQL **nueva y vacía**, en desarrollo o en un entorno preparado expresamente para la primera instalación. No se debe ejecutar sobre la SQLite de Windows ni sobre datos reales de la cafetería.

## 1. Preparar el entorno

Desde la carpeta `backend`:

1. Instala Node.js 22 o superior y PostgreSQL 16 o compatible.
2. Copia `.env.example` a `.env`.
3. Configura `DATABASE_URL` para una base dedicada a AZUL OS.
4. Genera un secreto JWT aleatorio y privado desde Node.js:

   `node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"`

5. Guarda ese valor únicamente en `.env` como `JWT_SECRET`. No lo publiques ni lo envíes por chat.
6. Instala dependencias con `npm install`.

## 2. Aplicar el esquema a la base vacía

Primero confirma que `DATABASE_URL` apunta a la base correcta. Después ejecuta la migración versionada:

`psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`

En PowerShell:

`psql $env:DATABASE_URL -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`

Revisa que el comando termine sin errores. No continúes si hay errores parciales; elimina y vuelve a crear la base de desarrollo vacía en lugar de improvisar correcciones sobre una instalación incierta.

## 3. Crear el CEO inicial (una sola vez)

Define estas variables de entorno solo en la terminal segura donde vas a ejecutar el proceso:

- `BOOTSTRAP_ESTABLISHMENT_NAME`: nombre del establecimiento.
- `BOOTSTRAP_USERNAME`: identificador de acceso del CEO.
- `BOOTSTRAP_CEO_NAME`: nombre que se mostrará en el sistema.
- `BOOTSTRAP_PIN`: PIN de cuatro dígitos.
- `BOOTSTRAP_DEVICE_NAME`: nombre del equipo inicial.
- `BOOTSTRAP_DEVICE_PLATFORM`: `windows`, `android`, `ios`, `tablet` u `other`.

Ejecuta `npm run bootstrap:ceo` una sola vez. El proceso comprueba que no exista ningún establecimiento, genera un hash bcrypt para el PIN y registra el establecimiento, el usuario CEO y un dispositivo inicial en una única transacción. Si ya existe un establecimiento, se niega a continuar.

Guarda los identificadores que imprime el proceso en un lugar administrativo seguro; se necesitan para el primer inicio de sesión. El PIN no se imprime ni se guarda en texto plano.

## 4. Verificar sin conectar todavía Flutter

- `npm run typecheck`
- `npm run build`
- `npm test`
- `GET /health/live` debe responder que el proceso está activo.
- `GET /health/ready` debe responder que PostgreSQL está disponible.

El backend aún no está listo para operar ventas reales. Antes de conectarlo a los equipos deben pasar las verificaciones de CI, completarse los endpoints empresariales y añadirse pruebas de integración de autenticación, permisos, inventario y ventas. No distribuir el secreto JWT a clientes y no desplegar sin HTTPS.
