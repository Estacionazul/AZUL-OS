import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

class BluetoothPrinterTest {
  static final CentralManager _central = CentralManager();

  static const String printerName = 'HL200B_0000';

  static const String targetServiceUuid =
      '000018f0-0000-1000-8000-00805f9b34fb';

  static const String targetCharacteristicUuid =
      '00002af1-0000-1000-8000-00805f9b34fb';

  static Future<void> ejecutar() async {
    StreamSubscription<DiscoveredEventArgs>? subscription;

    print('');
    print('==============================================');
    print('       AZUL OS - PRUEBA IMPRESION BLE');
    print('==============================================');

    try {
      // =====================================================
      // 1. ESTADO BLUETOOTH
      // =====================================================

      final state = _central.state;

      print('');
      print('🔵 Estado Bluetooth: $state');

      // En Windows puede aparecer UNKNOWN aunque BLE funcione.
      // Ya comprobamos anteriormente que la PC puede detectar
      // y conectar la impresora.
      if (state == BluetoothLowEnergyState.poweredOff) {
        print('❌ Bluetooth está apagado.');
        return;
      }

      print('✅ Continuamos con la prueba BLE.');

      // =====================================================
      // 2. PREPARAR RECEPTOR DE DESCUBRIMIENTO
      // =====================================================

      final completer = Completer<DiscoveredEventArgs>();

      print('');
      print('📡 Registrando receptor de dispositivos BLE...');

      subscription = _central.discovered.listen(
            (event) {
          final name = event.advertisement.name ?? '';

          print(
            '📡 BLE detectado: '
                '${name.isEmpty ? "(sin nombre)" : name} '
                '| RSSI: ${event.rssi}',
          );

          if (name == printerName && !completer.isCompleted) {
            print('');
            print('🎯 ¡HL200B_0000 ENCONTRADA!');

            completer.complete(event);
          }
        },
        onError: (error) {
          print('');
          print('❌ Error durante descubrimiento BLE: $error');

          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );

      print('✅ Receptor BLE registrado.');

      // Damos tiempo al plugin de Windows para registrar
      // correctamente el controlador nativo antes de iniciar
      // el observador.
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      // =====================================================
      // 3. INICIAR BÚSQUEDA
      // =====================================================

      print('');
      print('🔎 Iniciando búsqueda BLE...');
      print('🎯 Buscando: $printerName');

      await _central.startDiscovery();

      // =====================================================
      // 4. ESPERAR IMPRESORA
      // =====================================================

      final event = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'No se encontró $printerName durante el escaneo.',
          );
        },
      );

      // Detener búsqueda inmediatamente después de encontrarla.
      try {
        await _central.stopDiscovery();
      } catch (_) {}

      await subscription.cancel();

      // =====================================================
      // 5. IMPRESORA ENCONTRADA
      // =====================================================

      final peripheral = event.peripheral;

      print('');
      print('==============================================');
      print('✅ IMPRESORA ENCONTRADA');
      print('==============================================');

      print(
        'Nombre: '
            '${event.advertisement.name ?? "(sin nombre)"}',
      );

      print('UUID: ${peripheral.uuid}');
      print('RSSI: ${event.rssi}');

      // =====================================================
      // 6. CONECTAR
      // =====================================================

      print('');
      print('🔌 Conectando a $printerName...');

      await _central.connect(peripheral);

      print('✅ CONEXIÓN BLE ESTABLECIDA');

      // =====================================================
      // 7. DESCUBRIR GATT
      // =====================================================

      print('');
      print('==============================================');
      print('🔍 DESCUBRIENDO SERVICIOS GATT');
      print('==============================================');

      final services = await _central.discoverGATT(peripheral);

      print('Servicios encontrados: ${services.length}');

      // =====================================================
      // 8. BUSCAR CANAL DE ESCRITURA
      // =====================================================

      GATTCharacteristic? printerCharacteristic;

      for (final service in services) {
        print('');
        print('----------------------------------------------');
        print('SERVICIO');
        print('UUID: ${service.uuid}');
        print('Primario: ${service.isPrimary}');
        print(
          'Características: '
              '${service.characteristics.length}',
        );

        for (final characteristic in service.characteristics) {
          print('');
          print('   CARACTERÍSTICA');
          print('   UUID: ${characteristic.uuid}');
          print(
            '   Propiedades: '
                '${characteristic.properties}',
          );

          final serviceMatches =
              service.uuid.toString().toLowerCase() ==
                  targetServiceUuid.toLowerCase();

          final characteristicMatches =
              characteristic.uuid.toString().toLowerCase() ==
                  targetCharacteristicUuid.toLowerCase();

          if (serviceMatches && characteristicMatches) {
            printerCharacteristic = characteristic;

            print('');
            print('   🎯 ¡CARACTERÍSTICA DE IMPRESIÓN ENCONTRADA!');
          }
        }
      }

      // =====================================================
      // 9. COMPROBAR CANAL
      // =====================================================

      if (printerCharacteristic == null) {
        print('');
        print('==============================================');
        print('❌ NO ENCONTRAMOS EL CANAL DE IMPRESIÓN');
        print('==============================================');

        print('Servicio buscado:');
        print(targetServiceUuid);

        print('');
        print('Característica buscada:');
        print(targetCharacteristicUuid);

        await _central.disconnect(peripheral);

        return;
      }

      print('');
      print('==============================================');
      print('✅ CANAL DE IMPRESIÓN ENCONTRADO');
      print('==============================================');

      print('Servicio: $targetServiceUuid');
      print('Característica: $targetCharacteristicUuid');
      print(
        'Propiedades: '
            '${printerCharacteristic.properties}',
      );

      // =====================================================
// 10. PREPARAR PRUEBA ESC/POS
// =====================================================

      final List<int> bytes = [
        // ESC @ - Inicializar impresora
        0x1B,
        0x40,

        // Texto de prueba
        ...'AZUL OS\n'.codeUnits,
        ...'PRUEBA BLE\n'.codeUnits,
        ...'ESTACION AZUL\n'.codeUnits,
        ...'--------------------\n'.codeUnits,
        ...'IMPRESION CORRECTA\n'.codeUnits,

        // Avance de papel
        0x0A,
        0x0A,
        0x0A,
      ];

      final data = Uint8List.fromList(bytes);

      print('');
      print('📦 Bytes preparados: ${data.length}');


// =====================================================
// 11. CONSULTAR TAMAÑO MAXIMO DE ESCRITURA
// =====================================================

      print('');
      print('==============================================');
      print('📏 CONSULTANDO TAMAÑO MAXIMO BLE');
      print('==============================================');

      final maxWriteLength = await _central.getMaximumWriteLength(
        peripheral,
        type: GATTCharacteristicWriteType.withoutResponse,
      );

      print('📏 Máximo sin respuesta: $maxWriteLength bytes');


// =====================================================
// 12. ENVIAR DATOS POR BLOQUES
// =====================================================

      print('');
      print('==============================================');
      print('🖨️ ENVIANDO PRUEBA DE IMPRESIÓN');
      print('==============================================');

      try {
        int enviados = 0;

        while (enviados < data.length) {
          final fin = (enviados + maxWriteLength > data.length)
              ? data.length
              : enviados + maxWriteLength;

          final bloque = data.sublist(enviados, fin);

          print(
            '📤 Enviando bytes '
                '${enviados + 1}-$fin '
                '(${bloque.length} bytes)...',
          );

          await _central.writeCharacteristic(
            peripheral,
            printerCharacteristic,
            value: Uint8List.fromList(bloque),
            type: GATTCharacteristicWriteType.withoutResponse,
          );

          enviados = fin;

          // Pequeña pausa para darle tiempo a la impresora
          await Future<void>.delayed(
            const Duration(milliseconds: 50),
          );
        }

        print('');
        print('==============================================');
        print('✅ DATOS ENVIADOS COMPLETAMENTE');
        print('==============================================');
        print('📦 Total enviado: ${data.length} bytes');
      } catch (writeError, writeStack) {
        print('');
        print('==============================================');
        print('❌ ERROR ENVIANDO DATOS');
        print('==============================================');

        print('ERROR WRITE: $writeError');
        print('');
        print(writeStack);
      }


// =====================================================
// 13. ESPERAR A QUE LA IMPRESORA PROCESE
// =====================================================

      print('');
      print('⏳ Esperando procesamiento de la impresora...');

      await Future<void>.delayed(
        const Duration(seconds: 3),
      );

      print('✅ Tiempo de procesamiento terminado.');

      // Esperar antes de desconectar.
      await Future<void>.delayed(
        const Duration(seconds: 2),
      );

      // =====================================================
      // 12. DESCONECTAR
      // =====================================================

      await _central.disconnect(peripheral);

      print('');
      print('🔌 BLE desconectado.');
      print('');
      print('🏁 PRUEBA TERMINADA.');
    } catch (e, stackTrace) {
      print('');
      print('==============================================');
      print('❌ ERROR EN PRUEBA DE IMPRESIÓN BLE');
      print('==============================================');

      print('ERROR: $e');
      print('');
      print(stackTrace);
    } finally {
      if (subscription != null) {
        await subscription.cancel();
      }

      try {
        await _central.stopDiscovery();
      } catch (_) {}
    }
  }
}