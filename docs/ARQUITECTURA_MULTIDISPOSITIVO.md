# AZUL OS — Arquitectura Multidispositivo

## Objetivo

Evolucionar AZUL OS para que una misma operación de Estación Azul pueda utilizarse desde:

- PC Windows
- teléfonos Android (Redmi u otros)
- tablets Android
- futuros dispositivos compatibles

Todos los dispositivos deben trabajar sobre una única fuente empresarial de datos para productos, insumos, recetas, inventario/Kardex, ventas, clientes, pedidos, caja, usuarios/permisos, correlativos, comprobantes y Resúmenes Diarios SUNAT.

La versión Windows actual debe continuar operativa durante toda la migración.

## Estado actual auditado

La aplicación usa Flutter + Drift + SQLite local.

AppDatabase tiene schemaVersion = 35 y contiene las tablas principales del negocio.

AppDatabase acepta una ruta opcional y, cuando no se especifica, abre azul_os.db dentro del directorio de documentos de la aplicación.

Por tanto, cada instalación de AZUL OS tendría actualmente su propia base SQLite.

main.dart instancia AppDatabase() directamente y registra los repositorios/servicios sobre esa base.

## Arquitectura objetivo

                    AZUL OS BACKEND
                 PostgreSQL + API
                         |
              +----------+----------+
              |                     |
       autenticación          reglas transaccionales
              |                     |
              +----------+----------+
                         |
                    API HTTPS
                         |
          +--------------+--------------+
          |              |              |
       Windows          Redmi         Tablet
       Flutter         Flutter        Flutter
          |              |              |
      SQLite/cache   SQLite/cache   SQLite/cache

El servidor será la fuente de verdad empresarial.

SQLite/Drift en cada dispositivo será almacenamiento local de apoyo, cache y, posteriormente, cola offline controlada.

## Reglas de consistencia

### Ventas

Una venta debe ser una operación atómica en el backend:

1. validar usuario y permisos;
2. validar caja/jornada;
3. validar productos y precios;
4. validar disponibilidad de inventario;
5. registrar venta y detalle;
6. registrar movimientos de inventario;
7. registrar movimiento de caja;
8. reservar/usar correlativo;
9. generar el trabajo de facturación electrónica cuando corresponda.

Las operaciones críticas no deben quedar parcialmente aplicadas.

### Inventario

El Kardex central será la fuente de verdad.

Los dispositivos no deben cambiar directamente el stock central. Entradas, salidas, ajustes, producción y consumos por venta deberán pasar por el servicio transaccional de inventario.

### Caja

La caja será central y estará asociada a la jornada/establecimiento y al usuario/dispositivo que ejecuta la operación.

Debe impedir dos cierres incompatibles de la misma caja.

### Correlativos

Los correlativos no pueden ser generados independientemente por PC, Redmi y tablet.

La reserva de numeración debe ser central y transaccional.

### SUNAT

La emisión electrónica debe centralizarse.

Los dispositivos solicitan la emisión al backend; el backend administra XML, firma digital, envío a SUNAT, respuesta SUNAT/CDR, estado del comprobante y trazabilidad.

El certificado digital y credenciales sensibles no deben distribuirse innecesariamente entre todos los dispositivos.

## Identidad global

La base actual utiliza identificadores locales. Para multidispositivo no se debe confiar en un entero local como identificador global.

Durante la migración se incorporará un identificador global estable (UUID) para las entidades sincronizables. Los IDs actuales se conservarán temporalmente para compatibilidad y migración.

Entidades prioritarias:

- producto
- categoría
- insumo
- receta
- receta detalle
- cliente
- venta
- detalle de venta
- movimiento de inventario
- caja
- movimiento de caja
- usuario
- pedido
- comprobante electrónico
- correlativo
- resumen diario

## Estrategia de sincronización

### Fase 1 — Online-first

El dispositivo consulta y escribe contra la API central. Después de cada operación confirmada, la base local se actualiza.

### Fase 2 — Cache local

Los catálogos de lectura frecuente permanecen disponibles localmente.

### Fase 3 — Cola offline controlada

Se podrá incorporar una cola local para operaciones que puedan ejecutarse sin conexión.

No se habilitará offline para operaciones sensibles hasta definir resolución de conflictos, correlativos y facturación.

## Separación de responsabilidades

### Flutter

Responsable de interfaz, navegación, interacción, cache local, impresión según plataforma y comunicación con API.

### Backend

Responsable de autenticación/autorización, reglas empresariales críticas, transacciones, inventario central, caja central, ventas, correlativos, SUNAT, auditoría y sincronización.

### Impresión

La impresión seguirá siendo dependiente del dispositivo.

Windows podrá utilizar su adaptador de impresión actual.

Android podrá incorporar posteriormente impresión Bluetooth/USB/red sin cambiar la fuente de datos empresarial.

## Migración segura

No se debe reemplazar SQLite de producción de golpe.

Orden:

1. crear arquitectura backend;
2. crear esquema central;
3. crear API;
4. crear autenticación;
5. crear capa de acceso remoto en Flutter;
6. probar con datos controlados;
7. importar catálogo y configuraciones;
8. validar inventario;
9. validar ventas;
10. validar caja;
11. validar correlativos;
12. validar SUNAT;
13. ejecutar piloto con un segundo dispositivo;
14. convertir la operación a multidispositivo.

La base de producción actual debe permanecer intacta hasta completar la validación.

## Compatibilidad de dispositivos

AZUL OS seguirá siendo una sola aplicación Flutter con adaptaciones por plataforma.

La misma base de código debe poder generar Windows, Android teléfono y Android tablet.

Las funciones específicas de plataforma deben aislarse mediante adaptadores.

## Criterio de aceptación final

La migración estará terminada únicamente cuando:

- una venta creada desde Redmi aparezca en PC;
- la misma venta afecte el inventario central;
- la misma venta afecte caja;
- la venta quede disponible en reportes;
- un producto creado desde PC aparezca en Redmi y tablet;
- un ajuste de inventario sea visible en los demás dispositivos;
- los correlativos no se dupliquen;
- las boletas/facturas tengan trazabilidad SUNAT central;
- los usuarios y permisos sean consistentes;
- PC + Redmi + tablet puedan operar simultáneamente.

## Restricción de seguridad

No se debe introducir ninguna modificación destructiva sobre la base SQLite de producción durante esta fase.

Toda migración de datos debe ser reversible, auditable y respaldada.
