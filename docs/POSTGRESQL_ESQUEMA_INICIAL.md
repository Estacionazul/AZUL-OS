# AZUL OS — Esquema inicial PostgreSQL

Este documento conserva las convenciones de diseño del modelo central. El DDL autoritativo de desarrollo se encuentra en [backend/migrations/001_initial.sql](../backend/migrations/001_initial.sql).

## Convenciones

- UUID para identificadores globales.
- `timestamptz` para fechas.
- `numeric(12,2)` para dinero.
- `numeric(14,4)` para cantidades de inventario.
- `jsonb` para snapshots y auditoría.
- Claves únicas para códigos y correlativos.
- Restricciones `CHECK` para invariantes simples.
- Claves foráneas para integridad referencial.

## Precaución

La migración es un borrador de desarrollo. Debe probarse en una instancia PostgreSQL limpia, revisar sus restricciones y agregar un mecanismo de versionado antes de cualquier despliegue. No ejecutarla sobre la base SQLite de producción de Estación Azul.
