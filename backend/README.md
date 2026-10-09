# AZUL OS Backend (fase inicial)

Backend TypeScript + Express + PostgreSQL para la futura operación multidispositivo de Estación Azul.

## Estado actual

Incluye:
- configuración de entorno validada;
- pool PostgreSQL;
- endpoints de salud liveness/readiness;
- cabeceras de seguridad con Helmet;
- límite de tamaño de JSON;
- respuestas JSON controladas para rutas inexistentes y errores internos;
- Dockerfile inicial.

Aún NO incluye autenticación funcional, endpoints empresariales, autorización, migrador automatizado, sincronización ni conexión desde Flutter. No desplegar en producción todavía.

## Requisitos

- Node.js 22 o superior
- PostgreSQL compatible con `pgcrypto`

## Desarrollo local

1. Copiar `.env.example` como `.env`.
2. Configurar `DATABASE_URL` con una base de desarrollo vacía.
3. Instalar dependencias:

   `npm install`

4. Ejecutar modo desarrollo:

   `npm run dev`

5. Verificar:
   - `GET /health/live`
   - `GET /health/ready` (requiere PostgreSQL disponible)

## Compilar

`npm run build`

## Seguridad y despliegue

- No subir `.env`, contraseñas, claves ni certificados.
- Usar TLS/HTTPS en cualquier entorno accesible desde internet.
- No exponer PostgreSQL públicamente.
- Restringir CORS a los orígenes realmente usados.
- Configurar secretos mediante el gestor del proveedor de despliegue.
- Ejecutar migraciones solo en una base central de desarrollo hasta completar revisión y pruebas.
- No conectar aún la base SQLite de producción ni la integración SUNAT.

## Siguiente fase

1. Hacer reproducible la instalación con lockfile.
2. implementar migraciones versionadas y seguras.
3. autenticar usuarios con hashes de credenciales, sesiones y tokens revocables.
4. validar permisos en servidor.
5. implementar catálogos con paginación y validación.
6. implementar movimientos de inventario y ventas transaccionales e idempotentes.
7. añadir pruebas de integración con PostgreSQL.
