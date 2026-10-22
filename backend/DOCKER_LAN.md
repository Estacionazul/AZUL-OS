# AZUL OS — Docker local + Android LAN (DESARROLLO)

> Esta configuración crea una base PostgreSQL NUEVA para staging/pruebas. No migra ni conecta el SQLite productivo de Windows. No es autorización para producción ni para emitir SUNAT.

## 1. Preparar secretos
Desde PowerShell, en la raíz del repositorio:
```powershell
Copy-Item backend/.env.example backend/.env
```
Edita `backend/.env` localmente y reemplaza `POSTGRES_PASSWORD` por una contraseña larga alfanumérica y `JWT_SECRET` por un secreto aleatorio de al menos 32 caracteres. Conserva `MIGRATIONS_CONFIRM=APPLY_AZUL_MIGRATIONS`, `RUN_MIGRATIONS=true`, `HOST=0.0.0.0`. Nunca subas ni compartas `.env`.

## 2. Arrancar y comprobar
```powershell
docker compose --env-file backend/.env -f backend/docker-compose.yml config
docker compose --env-file backend/.env -f backend/docker-compose.yml up -d --build
docker compose --env-file backend/.env -f backend/docker-compose.yml ps
docker compose --env-file backend/.env -f backend/docker-compose.yml logs --tail 150 api
Invoke-RestMethod http://localhost:8080/health/live
Invoke-RestMethod http://localhost:8080/health/ready
```
El runner existente aplica migraciones versionadas solo con la confirmación explícita y se niega a adoptar una base que ya tenga tablas sin historial de migraciones. PostgreSQL no publica el puerto 5432 a la LAN. No borres el volumen para solucionar errores.
Parar sin borrar datos: `docker compose --env-file backend/.env -f backend/docker-compose.yml down`. No uses `down -v`.

## 3. Acceso desde Huawei en la LAN
1. Conecta PC y teléfono a la misma Wi-Fi privada (no red de invitados).
2. En Windows, ejecuta `ipconfig` y anota la IPv4 del adaptador activo.
3. PowerShell como administrador:
```powershell
New-NetFirewallRule -DisplayName "AZUL OS API 8080 LAN (DEV)" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow -Profile Private
```
4. En el navegador del Huawei abre `http://IP_REAL_DEL_PC:8080/health/ready`. Debe responder status ready y database connected. Sustituye por la IP real, no copies literalmente el ejemplo.
5. En el teléfono, `localhost` y `127.0.0.1` apuntan al teléfono, no al PC. `10.0.2.2` es especial para emuladores, no para un teléfono físico.

## 4. HTTPS y Flutter
El cliente Flutter de esta rama exige HTTPS de forma predeterminada; la excepción HTTP actual solo permite loopback, no una IP LAN. Para probar el APK actual, usa un túnel HTTPS temporal de un proveedor confiable (p. ej. ngrok), configura el URL HTTPS asignado en **Conexión multidispositivo** y detén el túnel al terminar. Usa datos ficticios y protege la URL del túnel.
Para HTTP directo por LAN, implementa una variante exclusivamente debug: manifest de debug con `android:usesCleartextTraffic="true"` y validación del cliente que permita HTTP con IP privada solo cuando `kDebugMode` sea true. No relajes la validación del APK release. Los certificados autofirmados requieren instalar/confiar una CA en el teléfono; no basta con generar el certificado.

## 5. Ventas e integridad offline/online
El cliente del PR #15 conserva la solicitud central pendiente y su clave idempotente cuando el resultado de red es ambiguo. Reintenta exactamente la misma clave y el mismo cuerpo; nunca crees una clave nueva para el mismo cobro. La API central ya procesa ventas con transacción, idempotencia y validación de stock.
Política segura inicial: online, enviar una vez con UUID idempotente y recuperar resultado si se pierde la respuesta; offline, dejar la venta marcada como pendiente y no afirmar que se confirmó centralmente; conflicto de clave/cuerpo, caja cerrada, producto/precio cambiado o stock insuficiente, poner en revisión y no sobrescribir estado central. No existe todavía sincronización general offline ni reconciliación automática de SQLite histórico. Eso requiere diseño/versionado de eventos, caja, stock, precios y documentos fiscales antes de activarse.

## 6. Diagnóstico
```powershell
docker compose --env-file backend/.env -f backend/docker-compose.yml logs -f api
docker compose --env-file backend/.env -f backend/docker-compose.yml logs -f db
Test-NetConnection IP_REAL_DEL_PC -Port 8080
```
CI verde no sustituye validación física, backups, TLS, pruebas de permisos/caja/stock ni firma/envío/conciliación SUNAT. No conectes la base productiva ni alteres el SQLite local de producción.
