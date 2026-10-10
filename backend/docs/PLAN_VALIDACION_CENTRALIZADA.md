# Plan de validación de operación centralizada — AZUL OS

## Estado y alcance

Este documento es una puerta de control para la siguiente fase de AZUL OS. La arquitectura y los flujos centrales están integrados en `main`, pero eso **no autoriza su uso para ventas reales**. La versión estable de Windows debe continuar trabajando con su SQLite local hasta completar las pruebas de aceptación y aprobar una migración por separado.

**Entorno permitido:** desarrollo y staging aislados, con una base PostgreSQL nueva y exclusiva para pruebas y datos ficticios.

**Fuera de alcance:** conectar o modificar la base SQLite productiva; migrar ventas, caja, clientes, inventario o correlativos históricos; emitir comprobantes reales; cambiar SUNAT, certificados, impresora térmica o la versión estable de la laptop.

## Puertas de salida obligatorias

No se avanza a la puerta siguiente si existe un fallo sin resolver.

| Puerta | Validación | Evidencia requerida | Estado |
|---|---|---|---|
| G0 — Código | Backend typecheck/build/tests; Flutter analyze/tests; compilación Windows y Android | CI verde para el SHA exacto que se revisa | Aprobado en el SHA fusionado de PR #2; repetir por cada cambio posterior |
| G1 — Entorno aislado | PostgreSQL de staging vacío, migraciones versionadas, secretos fuera del repo y HTTPS para acceso por red | Registro de entorno y comprobación de health/live y health/ready | Pendiente |
| G2 — Identidad y permisos | CEO, cajero, dispositivo activo/inactivo, sesión revocada y permisos por módulo | Casos positivos y negativos por rol/dispositivo | Pendiente |
| G3 — Integridad de datos | Aislamiento por establecimiento, catálogo, inventario, caja, ventas y pagos mixtos | Pruebas automatizadas y conciliación de saldos/movimientos | Parcialmente cubierto por pruebas de integración; falta aceptación multidispositivo |
| G4 — Fallos de red | Reintento con la misma clave de idempotencia para venta, movimiento de inventario, movimiento de caja y cierre de caja | Reintento tras respuesta perdida; exactamente una operación persistida | Hay protecciones y pruebas de idempotencia; validar el flujo completo entre dispositivos |
| G5 — Dispositivos | Windows, Android/Redmi y tableta contra la misma API de staging | Lista de casos ejecutados, resultados y evidencias sin secretos | Pendiente |
| G6 — Conciliación | Comparar ventas, pagos, movimientos de stock, caja y correlativos en staging | Totales de origen y destino coincidentes, con explicación de diferencias | Pendiente |
| G7 — Aprobación productiva | Revisión de seguridad, respaldo verificado, plan de migración/reversión y aprobación expresa | Acta de aceptación separada | **Bloqueado** |

## Casos de aceptación en staging

Usar establecimiento, usuarios, productos, importes y UUID ficticios. No copiar credenciales ni datos personales reales.

### 1. Identidad y aislamiento
- Un usuario solo accede al establecimiento asignado en su sesión.
- Un dispositivo desactivado y una sesión revocada no pueden realizar peticiones protegidas.
- Un cajero no puede ejecutar rutas exclusivas de CEO ni permisos de módulos que no tenga asignados.
- IDs de productos, clientes, cajas y ventas de otro establecimiento no pueden leerse ni usarse en escrituras.

### 2. Inventario
- Consultar stock y movimientos; comprobar que el stock se deriva de los movimientos.
- Repetir el mismo movimiento con la misma `Idempotency-Key` y cuerpo: debe devolver el resultado original sin duplicar el movimiento.
- Reutilizar esa clave con un cuerpo distinto: debe responder conflicto.
- Una salida que deje stock negativo debe rechazarse sin guardar cambios parciales.
- Una venta que falle por falta de stock no debe dejar venta, pago, caja ni movimientos de inventario parciales.

### 3. Caja y ventas
- No permitir dos cajas abiertas para el mismo establecimiento.
- Verificar efectivo inicial, ingresos/egresos, pagos en efectivo y mixtos, efectivo esperado, efectivo contado y diferencia.
- Reintentar una venta o cierre después de simular una respuesta HTTP perdida: se debe recuperar la misma operación con la misma clave y el mismo cuerpo.
- Una clave de idempotencia reutilizada con datos, usuario o dispositivo incompatibles debe rechazarse; no se debe cerrar la siguiente caja por accidente.
- Verificar que una venta y su desglose de pagos coincidan exactamente con el total, con tolerancia monetaria de cero céntimos de diferencia.
- Confirmar que una operación rechazada no consume correlativos ni deja datos parciales.

### 4. Prueba con varios dispositivos
- Registrar por separado el dispositivo Windows de pruebas, el Android/Redmi y la tableta en staging.
- Iniciar sesión y comprobar permisos en cada uno.
- Crear una venta ficticia en un dispositivo y comprobar su aparición en el historial central de los otros.
- Registrar un movimiento de inventario y comprobar que todos muestran el mismo stock tras refrescar.
- Abrir y cerrar caja de prueba en un dispositivo; comprobar que los demás ven el estado actualizado y no permiten una segunda apertura.
- Repetir las pruebas con pérdida temporal de red y reinicio de la app; recuperar solicitudes pendientes antes de permitir nuevas operaciones.
- Confirmar que ningún flujo de staging altera la base local de producción.

### 5. Límites fiscales y periféricos
- La aceptación de esta fase **no incluye** emisión, firma, envío ni reconciliación de comprobantes SUNAT desde el backend.
- No copiar certificados SUNAT a los dispositivos ni al repositorio.
- No conectar ni cambiar la impresora POS-58 de producción.
- La emisión SUNAT y la impresión local actuales deben seguir en la aplicación estable, sin cambios, durante toda esta validación.

## Reglas de bloqueo inmediato

Detener las pruebas de escritura y conservar los registros de staging si ocurre cualquiera de estos casos:
- una operación se duplica después de un reintento;
- un dispositivo accede a datos de otro establecimiento;
- una venta y sus pagos/stock/caja quedan parcialmente persistidos;
- los correlativos no son únicos dentro del establecimiento;
- el estado de caja diverge entre dispositivos;
- una solicitud pendiente se intenta repetir contra otro servidor o establecimiento;
- una prueba alcanza la base productiva, SUNAT real o la impresora de producción.

No borrar la solicitud pendiente para “desbloquear” el dispositivo hasta reconciliar el resultado con el historial del servidor original.

## Criterio para continuar

La siguiente etapa solo puede declararse aceptada cuando G1–G6 estén documentadas y verdes en el mismo candidato, los totales de staging estén conciliados y no existan defectos críticos o altos abiertos. La aprobación de G7 será independiente; hasta entonces no se conecta la operación real al backend ni se ejecutan migraciones productivas.
