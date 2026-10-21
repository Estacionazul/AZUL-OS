# APK de pruebas para Huawei — AZUL OS

## Alcance

Esta rama separa el identificador Android de staging para evitar que el APK de pruebas actualice o sustituya el paquete de producción `com.estacionazul.azul_os`.

- Paquete base de staging: `com.estacionazul.azul_os.staging`.
- Build debug de Flutter añade el sufijo `.debug`; el paquete esperado es `com.estacionazul.azul_os.staging.debug`.
- No contiene cambios en SQLite, ventas, correlativos, certificado ni configuración SUNAT.
- Esta separación de paquete NO significa que el backend centralizado esté listo para ventas reales.
- No usar para emitir comprobantes reales, conectar SUNAT producción ni conectar impresoras de producción.

## Compilación local

Desde la raíz del repositorio:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

APK esperado:

`build\app\outputs\flutter-apk\app-debug.apk`

Antes de instalarlo, verificar el identificador real del APK con Android SDK Build Tools (`apkanalyzer manifest application-id` o `aapt dump badging`) y verificar el paquete instalado en el teléfono con ADB.

## Instalación controlada

Solo tras compilar con éxito y confirmar el identificador:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install .\build\app\outputs\flutter-apk\app-debug.apk
```

No usar `adb install -r` sobre producción, no desinstalar ningún paquete, no usar `pm clear`. No ejecutar compras/ventas reales, cierres de caja reales, ni facturación SUNAT en la instalación de pruebas.

## Bloqueos conocidos de la aplicación

El arranque actual construye `AppDatabase()`, carga `DatosIniciales`, y registra servicios de facturación/SUNAT. El `applicationId` aislado impide reemplazar directamente el paquete de producción, pero la preparación del APK por sí sola NO garantiza un modo demo completo ni desactiva flujos fiscales. Mantener pruebas limitadas hasta una revisión específica de inicialización, datos ficticios, credenciales y rutas SUNAT.
