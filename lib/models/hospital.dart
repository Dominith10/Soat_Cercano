class Hospital {
  final String nombre;
  final String direccion;
  final List<String> especialidades;
  final double latitud;
  final double longitud;

  Hospital({
    required this.nombre,
    required this.direccion,
    required this.especialidades,
    required this.latitud,
    required this.longitud,
  });
}