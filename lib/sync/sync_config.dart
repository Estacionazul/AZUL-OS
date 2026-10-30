class SyncConfig {
  static const int port = 8080;
  static const String lanHost = '192.168.1.48';
  static const String tailscaleHost = '100.71.247.103';
  static const List<String> hosts = [lanHost, tailscaleHost];

  // Se inyecta al compilar: --dart-define=AZUL_SYNC_TOKEN=tu_clave_larga
  static const String token =
      String.fromEnvironment('AZUL_SYNC_TOKEN', defaultValue: '');
}