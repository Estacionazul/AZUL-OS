# AZUL OS Backend

Este directorio está reservado para el backend central de AZUL OS.

## Responsabilidad

El backend será la fuente de verdad para la operación multidispositivo de Estación Azul.

Debe centralizar autenticación y permisos, productos e insumos, recetas, inventario/Kardex, ventas, caja, clientes, pedidos, correlativos, comprobantes electrónicos, SUNAT, auditoría y sincronización.

## Principios

1. PostgreSQL como base empresarial central.
2. API HTTPS para los clientes Flutter.
3. Transacciones para operaciones críticas.
4. UUID como identificador global.
5. Auditoría de cambios.
6. Idempotencia para operaciones que puedan reintentarse.
7. El certificado SUNAT no se distribuye a los clientes.
8. SQLite/Drift en Flutter queda como cache/local store, no como fuente empresarial.

## Estado

Inicializado como espacio arquitectónico. La implementación del servidor se hará después de definir el esquema central y el contrato de API, sin modificar todavía la base de producción Windows.
