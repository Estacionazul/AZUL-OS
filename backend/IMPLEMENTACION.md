# AZUL OS Backend — implementación por fases

El backend se desarrolla independientemente de Flutter y de la base SQLite de producción.

## Stack vigente
- Node.js 22 y TypeScript
- Express para la API HTTP
- PostgreSQL 16+
- Migración SQL versionada en `migrations/`
- Node.js Test Runner para pruebas
- GitHub Actions con PostgreSQL efímero para validar esquema y pruebas

## Implementado en esta rama
1. API con configuración validada, CORS por lista permitida y endpoints de salud.
2. Migración PostgreSQL para establecimientos, dispositivos, usuarios, permisos, catálogos, recetas, clientes, inventario, caja, ventas, comprobantes y sincronización.
3. Autenticación por establecimiento, usuario, PIN de cuatro dígitos y dispositivo registrado.
4. Hash de PIN, bloqueo tras intentos fallidos, limitación de solicitudes y sesiones revocables.
5. Autorización backend por rol y permiso de módulo.
6. Lectura paginada de productos, categorías e insumos.
7. Consulta de stock y Kardex, más registro transaccional de movimientos con idempotencia, rechazo de stock negativo y bloqueo de movimientos manuales en productos de receta.
8. Bootstrap inicial del CEO y dispositivo, permitido solo en una base vacía.
9. Pruebas automatizadas y workflow para compilar y validar la migración en PostgreSQL.

## Puertas de calidad antes de producción
1. Revisar un resultado real de CI; no marcar compilación o pruebas como aprobadas sin evidencia.
2. Ampliar pruebas de integración de concurrencia, permisos y consultas.
3. Completar operaciones administrativas de productos, insumos y recetas con auditoría.
4. Implementar movimientos de inventario, ventas y caja en transacciones idempotentes con bloqueo de filas.
5. Procesar SUNAT con outbox transaccional, estados y reconciliación; una llamada externa no puede formar parte de una transacción SQL.
6. Implementar sincronización incremental y resolución explícita de conflictos.
7. Probar restauración de copias, despliegue HTTPS, secretos administrados y acceso a PostgreSQL restringido.
8. Ejecutar piloto Android con datos ficticios antes de habilitar operaciones reales.

## Restricciones
- No subir certificados, contraseñas, PIN, bases SQLite ni archivos `.env`.
- No conectar dispositivos reales hasta validar autenticación, autorización y sincronización.
- No modificar el funcionamiento Windows que actualmente opera en producción.
- No ejecutar esta migración sobre SQLite ni sobre datos reales de SUNAT.
- Las migraciones se validan primero en una base PostgreSQL aislada.
