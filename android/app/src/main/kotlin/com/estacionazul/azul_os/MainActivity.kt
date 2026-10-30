package com.estacionazul.azul_os

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress

class MainActivity : FlutterActivity() {
    private val dnsChannel = "com.estacionazul.azul_os/dns"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            dnsChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "resolveHost" -> {
                    val host = call.argument<String>("host")
                    if (host.isNullOrBlank() ||
                        host.contains('/') ||
                        host.contains(':') ||
                        host.any { it.isWhitespace() }
                    ) {
                        result.error("INVALID_HOST", "El nombre del servidor no es válido.", null)
                    } else {
                        try {
                            val addresses = InetAddress.getAllByName(host)
                                .mapNotNull { it.hostAddress }
                                .distinct()
                            if (addresses.isEmpty()) {
                                result.error(
                                    "DNS_NO_ADDRESSES",
                                    "Android no devolvió direcciones para el servidor.",
                                    null,
                                )
                            } else {
                                result.success(addresses)
                            }
                        } catch (error: Exception) {
                            result.error(
                                "DNS_LOOKUP_FAILED",
                                error.message ?: "No se pudo resolver el servidor.",
                                null,
                            )
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
