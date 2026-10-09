# AZUL OS Backend

API central en desarrollo para compartir la operación de Estación Azul entre Windows, Redmi y tablet.

## Estado actual

Implementado en la rama de desarrollo:
- servidor Express con TypeScript estricto;
- validación de variables de entorno;
- pool de conexiones PostgreSQL;
- endpoints `GET /health/live` y `GET /health/ready`;
- login por usuario + PIN de cuatro dígitos, con hash bcrypt verificado;
- bloqueo temporal tras cinco intentos incorrectos;
- sesiones de 12 horas almacenadas como hash de token, con validación en servidor y cierre de sesión;
- middleware de permisos por módulo y excepción para el rol `CEO`;
- migración SQL inicial separada en `migrations/001_initial.sql`;
- pruebas automatizadas iniciales y workflow de CI.

**No está listo para producción.** Aún no se han ejecutado las pruebas en un entorno controlado con Node.js/PostgreSQL ni se ha verificado la migración contra PostgreSQL real. No hay endpoints empresariales ni conexión Flutter implementados.

## Requisitos

- Node.js 22 o superior
- PostgreSQL
- Extensión PostgreSQL `pgcrypto`

## Preparación local

1. Copia `.env.example` a `.env`.
2. Crea una base de datos exclusiva de desarrollo; no uses la base SQLite de producción.
3. Configura `DATABASE_URL`.
4. Genera un secreto propio para JWT de al menos 32 caracteres, por ejemplo con `openssl rand -base64 48`, y reemplaza el valor de ejemplo `JWT_SECRET`.
5. Instala dependencias con `npm install`.
6. Ejecuta `npm run typecheck`, `npm run build` y `npm test`.

## Endpoints disponibles

- `GET /health/live`: confirma que el proceso responde.
- `GET /health/ready`: confirma conexión a PostgreSQL.
- `POST /v1/auth/login`: requiere `establishmentId`, `username`, PIN de cuatro dígitos y `deviceId`.
- `GET /v1/auth/me`: devuelve el usuario de la sesión autenticada.
- `POST /v1/auth/logout`: revoca la sesión activa.

El inicio de sesión solo funciona si el usuario y el dispositivo ya existen en PostgreSQL, el PIN está almacenado como hash bcrypt y el dispositivo pertenece al establecimiento. Aún no existe un proceso de alta inicial de CEO ni de migración de usuarios desde SQLite.

## Seguridad y límites

- No subas `.env`, secretos, contraseñas ni certificados.
- No distribuyas el certificado SUNAT a los dispositivos.
- No expongas PostgreSQL directamente a internet.
- El backend aún no está desplegado ni conectado a Flutter.
- No ejecutar la migración inicial en producción; primero necesita revisión, pruebas de integración y una estrategia de migraciones versionadas.
- Los permisos se validan en servidor, pero todavía deben aplicarse a cada endpoint empresarial cuando se implementen.

## Próxima fase

1. Crear una inicialización segura del primer usuario CEO y del dispositivo autorizado.
2. Probar migración, autenticación, bloqueo, cierre de sesión y permisos con PostgreSQL real.
3. Implementar catálogo de productos e insumos con autorización.
4. Implementar inventario y ventas con transacciones e idempotencia.
5. Preparar sincronización Flutter sin afectar el funcionamiento local existente.
