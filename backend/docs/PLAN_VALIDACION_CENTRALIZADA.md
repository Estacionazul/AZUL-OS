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


## Preparar staging aislado en Windows (PowerShell)

El repositorio incluye `docker-compose.staging.yml` y `staging.env.example`. Esta pila usa una base PostgreSQL exclusiva, una red Docker propia y publica la API únicamente en `127.0.0.1:18080`; PostgreSQL no publica puertos al equipo anfitrión. No apunta a SQLite ni a una base externa.

### A. Preparar secretos locales

Desde PowerShell, entra a `backend` y crea el archivo local ignorado por Git:

```powershell
Copy-Item .\staging.env.example .\.env.staging
node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
notepad .\.env.staging
```

Usa la primera cadena aleatoria como `STAGING_DB_PASSWORD` y la segunda como `STAGING_JWT_SECRET`. En el mismo archivo establece un PIN de CEO de staging de cuatro dígitos que no sea obvio y cambia `BOOTSTRAP_CONFIRM` a `CREATE_INITIAL_CEO_AND_DEVICE`. No reutilices secretos ni PIN de producción y no compartas el archivo. Las contraseñas generadas en formato base64url evitan caracteres problemáticos en la URL de conexión.

### B. Validar configuración antes de levantar contenedores

```powershell
docker compose --env-file .env.staging -f docker-compose.staging.yml config --quiet
```

Si este comando falla, detente y corrige la configuración antes de continuar. Nunca sustituyas las variables por credenciales de producción.

### C. Crear únicamente la base de staging

```powershell
docker compose --env-file .env.staging -f docker-compose.staging.yml up -d db
docker compose --env-file .env.staging -f docker-compose.staging.yml --profile tools run --rm -e MIGRATIONS_CONFIRM=APPLY_AZUL_MIGRATIONS migrate
docker compose --env-file .env.staging -f docker-compose.staging.yml --profile tools run --rm bootstrap
docker compose --env-file .env.staging -f docker-compose.staging.yml up -d --build backend
Invoke-RestMethod http://127.0.0.1:18080/health/live
Invoke-RestMethod http://127.0.0.1:18080/health/ready
```

Las migraciones y el bootstrap se ejecutan como tareas puntuales contra el servicio PostgreSQL llamado `db` de esta composición. Si cualquiera de esas tareas falla, no sigas a la siguiente; conserva el error y revisa solo esta pila de staging. No cambies la URL de conexión para apuntar a una base existente.

### D. Aceptación funcional

- Configura un cliente de pruebas con URL `http://127.0.0.1:18080` solo para esta prueba local; el cliente debe habilitar explícitamente HTTP únicamente para loopback. No configures una IP de red ni una URL pública con HTTP.
- Inicia sesión con el CEO de staging y registra usuarios/dispositivos ficticios de prueba.
- Ejecuta los casos G2–G6 de este plan con productos y cantidades ficticias; conserva los resultados y compara historial, pagos, movimientos de inventario y conciliación de caja.
- Para probar Android/tableta en la misma red se requiere HTTPS y una configuración de staging dedicada; no abras este puerto HTTP en la LAN.
- No conectes la aplicación productiva ni importes datos reales en esta base.

Para apagar los contenedores al terminar, sin borrar el volumen de pruebas:

```powershell
docker compose --env-file .env.staging -f docker-compose.staging.yml down
```

No ejecutes `down -v` salvo que se haya verificado expresamente que el proyecto seleccionado es esta pila desechable y se autorice eliminar todos sus datos de prueba.

### Alcance real de CI

El workflow valida tipos, compilación, migraciones y pruebas de backend, y ahora valida la sintaxis de Compose y construye la imagen del backend de staging sin levantar una instancia accesible. Esto **no sustituye** ejecutar la aceptación funcional anterior ni demuestra que Windows, Android y la tableta estén conciliados entre sí.

## Registro de evidencia ejecutada en staging — 2026-10-14

Esta evidencia corresponde exclusivamente a la base PostgreSQL local de staging; no es una venta productiva ni un comprobante SUNAT.

### Venta ficticia de extremo a extremo

- Producto: `PRODUCTO FICTICIO - NO VENDER` (`TEST-STAGING-001`).
- Venta: `V000001`, ID `d04338c4-0808-477a-9066-0f126c37f1d4`.
- Importe y pago en efectivo: S/ 1.00.
- Movimiento de caja: ingreso de S/ 1.00 asociado a la venta.
- Movimiento de inventario: salida de 1 unidad asociada a la venta.
- Conciliación observada: 1 venta; total de ventas S/ 1.00; pagos S/ 1.00; ingreso de caja S/ 1.00; stock final 0.
- Caja de staging: permaneció abierta; monto inicial S/ 20.00.
- Stock inicial de prueba: 1 unidad, registrada por una entrada previa; stock final cero tras la venta.

### Alcance de esta evidencia

Esto valida una operación individual de venta, pago, caja e inventario en staging. **No** demuestra todavía pruebas físicas multidispositivo, recuperación de una respuesta HTTP perdida, cierre y conciliación final de caja, HTTPS, emisión SUNAT ni autorización para producción. La venta ficticia debe conservarse como evidencia; no borrarla ni reutilizar el producto de prueba para nuevas ventas sin reponer stock mediante un movimiento de entrada identificado como prueba.

### Seguridad de datos

No registrar en este documento PIN, tokens, contraseñas, archivos `.env`, certificados, ni datos personales reales. Mantener SQLite productivo, ventas históricas, correlativos, SUNAT y la impresora sin cambios hasta la aprobación separada de G7.



## Evidencia CI de seguridad — 2026-10-14

- Commit revisado: `d588e5f47cb5cfff6a20f8d25cc7e16619f4d22d`.
- Ejecución Backend CI #257: https://github.com/Estacionazul/AZUL-OS/actions/runs/38603234553
- Resultado observado: trabajo `backend` completado con `success`; instalación, type-check, compilación, ensayo de salvaguardas de migración, validación de migraciones, pruebas automatizadas, validación de Compose/build y limpieza del entorno CI completados.
- Las pruebas de sesión incluyen aislamiento de establecimiento en el inicio de sesión, permisos de cajero, revocación de dispositivo, cierre de sesión e invalidación inmediata al desactivar el usuario.
- La prueba de inventario existente cubre repetición idempotente, conflicto al reutilizar clave con datos distintos, prevención de stock negativo, restricción de movimientos manuales para productos de receta y aislamiento entre establecimientos.
- Esta evidencia demuestra el resultado de CI para este commit, no la aceptación física multidispositivo ni la seguridad HTTPS en una red real.

**Estado de salida:** CI del commit aprobado. G1 y G5 siguen pendientes por configuración/aceptación en entorno aislado con dispositivos; G3, G4 y G6 siguen pendientes de pruebas completas y conciliación documentada. G7 continúa bloqueado. No se autoriza producción, fusión automática ni cambios a SQLite, SUNAT, correlativos o impresora productiva.
