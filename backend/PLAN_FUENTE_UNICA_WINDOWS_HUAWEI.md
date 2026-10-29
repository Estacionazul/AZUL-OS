# Plan seguro: fuente única Windows + Huawei

Estado: propuesta técnica; no autoriza despliegue, migración ni cambio de operación.

## Objetivo

Permitir que Windows y el Huawei consulten y operen sobre un estado central consistente sin reinstalar el APK actual durante esta fase de preparación y sin perder la base SQLite productiva, caja, ventas, correlativos, comprobantes SUNAT ni impresión de Windows.

## Hechos verificados en el repositorio

- El APK instalado corresponde a `main` en `f78fb80`; ese commit contiene `AzulApiClient`, `ApiConnectionScreen` y pantallas centrales de catálogo, inventario y POS.
- El cliente Android guarda la URL, UUID del establecimiento y UUID del dispositivo en almacenamiento seguro y exige HTTPS para una dirección remota.
- El backend de la rama de desarrollo utiliza PostgreSQL y ofrece endpoints centrales, pero la documentación declara que sus pantallas operativas no sincronizan el SQLite local ni emiten comprobantes SUNAT.
- La base de datos local de Windows sigue siendo la fuente productiva conocida. No se debe asumir que el PostgreSQL de staging contiene el catálogo real ni los datos de caja/ventas.
- El servicio local de impresión y la firma/envío SUNAT existentes no se deben mover a Android ni sustituir sin una fase específica y aprobada.

## Arquitectura de transición

1. **Preservar producción.** No ejecutar migraciones, bootstrap, reset, importación ni cambios sobre la base productiva SQLite. Generar y verificar una copia de seguridad independiente antes de cualquier futuro piloto.
2. **Validar el servidor de staging.** Confirmar identidad de la base PostgreSQL, versión de esquema/migraciones, health checks, configuración de secretos, logs, copias y restauración. La respuesta `/health/ready` solo demuestra que PostgreSQL responde; no certifica que la base contenga datos correctos.
3. **Inventariar datos desde Windows en solo lectura.** Obtener conteos y relaciones de categorías, productos, insumos, recetas, existencias, clientes, ventas, cajas, comprobantes y correlativos. No exportar PIN, contraseñas, certificados ni claves SOL. La exportación se prepara como artefacto revisable, no se importa automáticamente.
4. **Definir mapeo y reconciliación.** Documentar IDs, SKU/códigos, precios, IGV, unidades, recetas, stock inicial y referencias históricas. No reescribir los números de comprobante ni cargar ventas históricas como si fueran ventas nuevas.
5. **Elegir una única autoridad por fase.** Durante el piloto, el sistema Windows actual mantiene autoridad para ventas reales, caja y SUNAT. El Huawei solo usa el flujo central con datos ficticios o consultas aprobadas. No permitir que ambos sistemas descuente stock por separado.
6. **Crear un puente explícito.** La integración de Windows debe usar un servicio/repository de aplicación con contrato y modo de operación definidos; no hacer que dos bases se sincronicen mediante escrituras SQL directas. Las operaciones de venta requieren idempotencia, transacción, control de concurrencia y registro auditable.
7. **Puerta de SUNAT.** Hasta implementar y probar outbox, estados, firma/envío/reconciliación y recuperación de errores, la emisión legal continúa exclusivamente en el flujo Windows existente. Nunca copiar el certificado o claves SOL al Huawei.
8. **Piloto cerrado.** Con catálogo de prueba y dispositivos registrados, comprobar inicio de sesión, permisos, actualización de catálogo, concurrencia, ventas repetidas, pérdida de red, caja, movimientos y restauración. No habilitar venta real hasta que todas las pruebas y conciliaciones cuadren.
9. **Activación gradual y reversión.** Requiere aprobación explícita, backup restaurable, ventana de mantenimiento, responsable de conciliación y procedimiento de rollback. No fusionar esta rama ni desplegar automáticamente.

## Bloqueadores antes de conectar datos reales

- Identificar con evidencia cuál base PostgreSQL está activa y si es staging.
- Obtener un inventario de solo lectura de la base productiva SQLite y comparar el modelo con PostgreSQL.
- Decidir si se construye una importación inicial revisable o una sincronización incremental; no hacer ambas de forma implícita.
- Completar la integración del cliente Windows con la API central sin romper su flujo local ni la impresión.
- Resolver la estrategia de autoridad para stock, caja, correlativos y comprobantes.
- Ejecutar CI y pruebas de integración reales y documentar sus resultados.
- Proveer HTTPS válido y accesible desde la red del Huawei; no usar IP privada/HTTP como configuración de producción.

## Criterios de aceptación

- [ ] Backup de SQLite validado mediante restauración en una ubicación aislada.
- [ ] Inventario de datos reconciliado antes de cualquier importación.
- [ ] No se alteran ventas históricas, caja, correlativos ni comprobantes existentes.
- [ ] El mismo producto/stock no se contabiliza dos veces.
- [ ] Reintentar una venta tras pérdida de red no duplica la venta ni el cobro.
- [ ] La operación Windows actual y la impresora POS-58-Series siguen funcionando.
- [ ] No se emiten comprobantes SUNAT desde Android.
- [ ] HTTPS, permisos, registro de dispositivos, backups y rollback probados.
- [ ] Aprobación explícita antes de habilitar ventas reales.

## Próxima acción operativa

Primero se necesita una auditoría de solo lectura de la configuración actual del backend y un inventario de la SQLite productiva, sin mostrar valores secretos ni modificar archivos de datos. Después se prepara el mapeo y se revisa en PR antes de ejecutar cualquier carga.
