# AZUL OS Backend

API central en desarrollo para compartir operación entre Windows, Redmi y tablet. Stack inicial: Node.js 22, TypeScript, Express y PostgreSQL.

## Implementado en esta rama

- Configuración de entorno validada.
- Pool PostgreSQL.
- Endpoints `GET /health/live` y `GET /health/ready`.
- Inicio de sesión por establecimiento, usuario, PIN de cuatro dígitos y dispositivo registrado.
- Hash de PIN mediante bcrypt; bloqueo temporal tras cinco intentos fallidos.
- Token firmado con expiración de 12 horas, emisor y audiencia validados.
- Sesiones persistidas como hash del token, con comprobación de revocación en cada petición.
- Cierre de sesión y perfil autenticado en `GET /v1/auth/me`.
- Permisos por módulo mediante `requirePermission`; el rol CEO puede acceder a todos los módulos.
- Migración SQL inicial y flujo CI para typecheck, build y pruebas.

## Endpoints actuales

- `POST /v1/auth/login`
- `POST /v1/auth/logout` (Bearer token)
- `GET /v1/auth/me` (Bearer token)
- `GET /health/live`
- `GET /health/ready`

El inicio de sesión necesita que el establecimiento, usuario con `pin_hash` bcrypt y dispositivo activo ya existan en PostgreSQL. El alta segura del CEO inicial y el enrolamiento de dispositivos aún deben implementarse antes de un despliegue real.

## Ejecutar en desarrollo

Requisitos: Node.js 22+ y PostgreSQL. La base debe ser una base de desarrollo, nunca la SQLite de producción.

1. Copiar `.env.example` a `.env`.
2. Crear una base PostgreSQL vacía y configurar `DATABASE_URL`.
3. Generar un secreto aleatorio de al menos 32 caracteres y configurar `JWT_SECRET`.
4. Instalar dependencias: `npm install`.
5. Ejecutar `npm run dev`.
6. Comprobar `GET /health/live` y `GET /health/ready`.

## Migraciones

`migrations/001_initial.sql` es un esquema inicial para revisión. No se ejecuta automáticamente y no debe aplicarse a la base SQLite local ni a la base de producción. Falta añadir un runner de migraciones versionado y validar el DDL con una instancia PostgreSQL antes de considerarlo aprobado.

## Seguridad y límites actuales

- No se incluyen secretos ni certificados reales en Git.
- En producción, usar HTTPS, secretos gestionados y PostgreSQL no expuesto públicamente.
- CORS y limitación de solicitudes aún deben configurarse antes de abrir acceso a clientes externos.
- Aún no están implementados los endpoints de catálogo, inventario, caja, ventas, sincronización ni SUNAT.
- No conectar todavía la app Flutter a este backend ni distribuir el certificado SUNAT.
- La implementación de autenticación necesita pruebas de integración contra PostgreSQL antes de aprobarse para uso real.

## Siguiente fase

1. Validar la migración con PostgreSQL limpio y corregir restricciones.
2. Crear el flujo de bootstrap del primer CEO y enrolamiento controlado de dispositivos.
3. Añadir limitación de intentos por IP/dispositivo y endurecimiento de autenticación.
4. Implementar catálogo de productos e insumos con autorización.
5. Implementar inventario con transacciones e idempotencia y pruebas de concurrencia.
