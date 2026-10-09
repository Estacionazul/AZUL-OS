# AZUL OS Backend

Backend central en TypeScript, Express y PostgreSQL para preparar la operación multidispositivo de Estación Azul.

## Estado de implementación

Implementado en esta rama:
- configuración obligatoria y validada por entorno;
- endpoints de salud `GET /health/live` y `GET /health/ready`;
- inicio de sesión por establecimiento, usuario, PIN de 4 dígitos y dispositivo previamente registrado;
- PIN almacenado como hash bcrypt (nunca en texto plano);
- bloqueo temporal después de 5 intentos fallidos y límite de solicitudes de login por IP;
- tokens firmados con JWT, sesiones almacenadas como hash, expiración de 12 horas y cierre de sesión revocable;
- autorización por rol y permiso de módulo como middleware reutilizable;
- primera migración PostgreSQL y workflow CI para compilar, probar y validar la migración contra PostgreSQL.

Pendiente antes de uso operativo:
- ejecutar y revisar el workflow CI;
- implementar un proceso administrativo seguro para crear el primer establecimiento, CEO, usuarios y dispositivos;
- endpoints de productos, insumos, recetas e inventario;
- ventas/caja con transacciones e idempotencia;
- auditoría, sincronización y pruebas de integración completas;
- despliegue HTTPS y configuración de secretos en el entorno del servidor;
- integración cliente Flutter y pruebas específicas por plataforma.

**Este backend no está listo para producción ni conectado a la aplicación Flutter.** No ejecutar la migración contra la base SQLite actual ni contra datos reales de SUNAT.

## Requisitos

- Node.js 22 o superior
- PostgreSQL 16 o compatible con `pgcrypto`

## Desarrollo local

1. Entrar a esta carpeta.
2. Copiar `.env.example` a `.env`.
3. Crear una base PostgreSQL exclusiva para desarrollo.
4. Configurar `DATABASE_URL` y generar un `JWT_SECRET` aleatorio de al menos 32 caracteres. No usar el valor de ejemplo.
5. Instalar dependencias:

   `npm install`

6. Validar primero la migración en la base vacía de desarrollo:

   `psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`

   En PowerShell, usa la variable de entorno configurada en esa terminal y ejecuta `psql $env:DATABASE_URL -v ON_ERROR_STOP=1 -f migrations/001_initial.sql`.

7. Arrancar el servidor:

   `npm run dev`

8. Ejecutar verificaciones:

   `npm run typecheck`

   `npm run build`

   `npm test`

## Endpoints de autenticación actuales

- `POST /v1/auth/login`: recibe `establishmentId`, `username`, `pin` (exactamente cuatro dígitos) y `deviceId`. Tanto el establecimiento como el usuario y el dispositivo deben existir y estar activos.
- `GET /v1/auth/me`: requiere `Authorization: Bearer <token>`.
- `POST /v1/auth/logout`: requiere token y revoca la sesión.

No existe todavía una ruta pública para registrar usuarios o dispositivos. La creación inicial debe realizarse mediante un procedimiento administrativo controlado, que se implementará antes de conectar clientes reales.

## Principios de seguridad

- Nunca guardar ni registrar PIN en texto plano.
- No incluir secretos, contraseñas ni certificados en Git.
- El JWT requiere un secreto privado fuerte y no debe reutilizarse entre entornos.
- Usar HTTPS en redes externas y no exponer PostgreSQL a internet.
- El limitador de login actual usa memoria local; una instalación con varias réplicas necesitará un almacén compartido y configuración de proxy de confianza revisada.
- El certificado SUNAT no se distribuye a los clientes.
- Las migraciones se validan primero contra una base de pruebas; no se ejecutan automáticamente al iniciar el servidor.
- La SQLite/Drift de Windows sigue siendo la base operativa actual hasta completar la migración multidispositivo de forma controlada.
