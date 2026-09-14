import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/usuarios_repository.dart';
import '../../services/sesion_service.dart';

class AutorizacionCeoDialog {
  AutorizacionCeoDialog._();

  static Future<bool> verificar(BuildContext context) async {
    if (SesionService.instancia.esCEO) {
      return true;
    }

    final pinController = TextEditingController();
    bool mostrarPin = false;
    bool verificando = false;

    final autorizado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> autorizar() async {
              final pin = pinController.text.trim();

              if (pin.length != 4) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('El PIN CEO debe tener 4 dígitos.'),
                  ),
                );
                return;
              }

              setState(() {
                verificando = true;
              });

              try {
                final repository = context.read<UsuariosRepository>();
                final usuarios = await repository.obtenerUsuariosActivos();

                final existeCeoAutorizado = usuarios.any(
                  (usuario) =>
                      usuario.rol.toUpperCase() == 'CEO' &&
                      usuario.activo &&
                      usuario.pin == pin,
                );

                if (!dialogContext.mounted) return;

                if (existeCeoAutorizado) {
                  Navigator.of(dialogContext).pop(true);
                  return;
                }

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('PIN CEO incorrecto.'),
                  ),
                );
              } catch (e) {
                if (!dialogContext.mounted) return;

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se pudo verificar la autorización: $e',
                    ),
                  ),
                );
              } finally {
                if (dialogContext.mounted) {
                  setState(() {
                    verificando = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Autorización CEO'),
                  ),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Esta acción requiere autorización del CEO.',
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pinController,
                      autofocus: true,
                      obscureText: !mostrarPin,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      onSubmitted: (_) {
                        if (!verificando) {
                          autorizar();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'PIN CEO',
                        hintText: '••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          tooltip: mostrarPin
                              ? 'Ocultar PIN'
                              : 'Mostrar PIN',
                          onPressed: () {
                            setState(() {
                              mostrarPin = !mostrarPin;
                            });
                          },
                          icon: Icon(
                            mostrarPin
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: verificando
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('CANCELAR'),
                ),
                ElevatedButton.icon(
                  onPressed: verificando ? null : autorizar,
                  icon: verificando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.verified_user_rounded),
                  label: Text(
                    verificando ? 'VERIFICANDO...' : 'AUTORIZAR',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();

    return autorizado == true;
  }
}
