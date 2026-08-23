class DashboardResumen {
  final double ventasHoy;
  final double ventasMes;

  final int ticketsHoy;
  final int ticketsMes;

  final int clientesHoy;
  final int clientesMes;

  final int alertas;

  const DashboardResumen({
    required this.ventasHoy,
    required this.ventasMes,
    required this.ticketsHoy,
    required this.ticketsMes,
    required this.clientesHoy,
    required this.clientesMes,
    required this.alertas,
  });
}