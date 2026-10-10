# Inicio seguro del backend y creación del CEO

Este procedimiento es exclusivamente para una instalación nueva en una base PostgreSQL vacía de desarrollo o staging preparada para pruebas. No se ejecuta sobre SQLite de Windows ni sobre datos reales de Estación Azul.

## 1. Preparar entorno y base de datos

Desde la carpeta `backend`:

1. Instala Node.js 22 o superior y PostgreSQL 16 o compatible con `pgcrypto`.
2. Copia `.env.example` a `.env`.
3. Configura `DATABASE_URL` para una base PostgreSQL dedicada, nueva y vacía. Antes de continuar, confirma el host, puerto y nombre de la base.
4. Genera un secreto JWT privado desde Node.js:

   `node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"`

5. Guarda el secreto únicamente en `.env` como `JWT_SECRET`. No lo publiques ni lo envíes por chat.
6. Instala dependencias con `npm install`.

## 2. Aplicar migraciones versionadas

No ejecutes manualmente solo `migrations/001_initial.sql`: el esquema actual usa un runner versionado que aplica las migraciones en orden y registra el historial.

Primero verifica otra vez que `DATABASE_URL` apunta a la base vacía correcta. Luego, desde PowerShell:

```powershell
$env:MIGRATIONS_CONFIRM = "APPLY_AZUL_MIGRATIONS"
npm run migrate
```

El runner exige esa confirmación explícita, usa un bloqueo advisory y registra cada migración aplicada en `schema_migrations`. Si detecta tablas existentes sin historial de migraciones, se detiene en lugar de adoptar un esquema desconocido. No intentes saltarte esa protección.

## 3. Crear el CEO inicial y dispositivo

Configura estas variables de entorno en la terminal segura donde ejecutarás el comando:

- `BOOTSTRAP_ESTABLISHMENT_NAME`: nombre del establecimiento de desarrollo.
- `BOOTSTRAP_USERNAME`: identificador de acceso del CEO.
- `BOOTSTRAP_CEO_NAME`: nombre visible del CEO.
- `BOOTSTRAP_PIN`: PIN privado de cuatro dígitos; evita combinaciones obvias.
- `BOOTSTRAP_DEVICE_NAME`: nombre del dispositivo inicial.
- `BOOTSTRAP_DEVICE_PLATFORM`: `windows`, `android`, `ios`, `tablet` u `other`.
- `BOOTSTRAP_CONFIRM`: debe ser exactamente `CREATE_INITIAL_CEO_AND_DEVICE`.

Después de verificar que `DATABASE_URL` apunta a la base vacía de desarrollo correcta, ejecuta una sola vez:

```powershell
npm run bootstrap:ceo
```

El comando comprueba dentro de una transacción que no exista ya un establecimiento, genera un hash bcrypt del PIN y crea el establecimiento, el usuario CEO y el dispositivo. Si ya existe un establecimiento, se niega a continuar. El PIN no se imprime ni se almacena en texto plano. Guarda los identificadores resultantes en un lugar administrativo seguro.

No ejecutes este bootstrap contra producción ni vuelvas a ejecutarlo para reparar una instalación existente.

## 4. Validar sin conectar Flutter de producción

Desde `backend`:

```powershell
npm run typecheck
npm run build
npm test
```

También verifica `GET /health/live` y `GET /health/ready` en el entorno de desarrollo.

Las pruebas automatizadas no sustituyen la revisión de seguridad, staging ni la aceptación funcional en Windows, Android y tabletas. El backend no está aprobado para operar ventas reales: no conectes el SQLite de producción, no migres ventas históricas y no alteres caja, correlativos, comprobantes SUNAT ni la impresión local.
