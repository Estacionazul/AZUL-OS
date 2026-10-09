# AZUL OS backend — implementación por fases

Este backend se implementará independientemente de Flutter y de SQLite de producción.

## Stack propuesto
- Python 3.12+
- FastAPI
- PostgreSQL 16+
- SQLAlchemy 2
- Alembic
- Pytest

## Puertas de calidad
1. Migraciones reproducibles en una base de prueba vacía.
2. Validación de esquema y claves foráneas.
3. Login con hash de PIN y protección contra fuerza bruta.
4. Autorización de cada operación en el servidor.
5. Inventario con transacciones, locks e idempotencia.
6. Venta atómica con caja, Kardex y correlativo.
7. SUNAT desacoplado mediante outbox transaccional y reintentos idempotentes.
8. Pruebas de concurrencia y restauración de respaldos.
9. Piloto Android con datos ficticios.
10. Migración de producción solamente con respaldo, conciliación y aprobación.

## Restricciones
- Nunca subir certificados, contraseñas, PIN, bases SQLite ni archivos .env.
- No conectar dispositivos reales al backend hasta validar la autenticación.
- No modificar el funcionamiento Windows actual.
- No asumir que un DDL documentado equivale a una migración ejecutada.
- La emisión SUNAT externa no puede ser parte de una transacción SQL: se usa outbox con estados y reconciliación.

## Próxima entrega de código
Esqueleto ejecutable FastAPI, configuración por entorno, conexión PostgreSQL, health checks y tests. Luego migraciones Alembic y módulos de negocio.
