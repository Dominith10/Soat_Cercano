import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/hospitales.dart';
import '../models/hospital.dart';
import '../services/maps_service.dart';
import '../services/ubicacion_service.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({super.key});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  String? especialidadSeleccionada;

  double? latitudUsuario;
  double? longitudUsuario;

  List<Hospital> hospitalesOrdenados = [];

  final especialidades = hospitales
    .expand((h) => h.especialidades)
    .toSet()
    .toList()
  ..sort();

  Future<void> buscarHospitales() async {
    Position? posicion = await UbicacionService.obtenerUbicacion();

    if (posicion == null) return;

    latitudUsuario = posicion.latitude;
    longitudUsuario = posicion.longitude;

    List<Hospital> hospitalesFiltrados = hospitales
        .where(
        (h) => h.especialidades.contains(
          especialidadSeleccionada,
        ),
       )
        .toList();

    hospitalesFiltrados.sort((a, b) {
      double distanciaA = Geolocator.distanceBetween(
        latitudUsuario!,
        longitudUsuario!,
        a.latitud,
        a.longitud,
      );

      double distanciaB = Geolocator.distanceBetween(
        latitudUsuario!,
        longitudUsuario!,
        b.latitud,
        b.longitud,
      );

      return distanciaA.compareTo(distanciaB);
    });

    hospitalesFiltrados.removeWhere((hospital) {
      double distancia = Geolocator.distanceBetween(
        latitudUsuario!,
        longitudUsuario!,
        hospital.latitud,
        hospital.longitud,
      );

      return distancia > 10000;
    });

    if (hospitalesFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se encontraron hospitales de $especialidadSeleccionada a menos de 10 km',
          ),
        ),
      );
      return;
    }

    setState(() {
      hospitalesOrdenados = hospitalesFiltrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda por Hospital'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Tipo de especialidad',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButton<String>(
              isExpanded: true,
              value: especialidadSeleccionada,
              hint: const Text('Elegir especialidad'),
              items: especialidades.map((especialidad) {
                return DropdownMenuItem(
                  value: especialidad,
                  child: Text(especialidad),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  especialidadSeleccionada = valor;
                  hospitalesOrdenados = [];
                });
              },
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                if (especialidadSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seleccione una especialidad'),
                    ),
                  );
                  return;
                }

                await buscarHospitales();
              },
              child: const Text('Buscar hospital'),
            ),

            const SizedBox(height: 20),

            if (hospitalesOrdenados.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: hospitalesOrdenados.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitalesOrdenados[index];

                    double distancia = Geolocator.distanceBetween(
                      latitudUsuario!,
                      longitudUsuario!,
                      hospital.latitud,
                      hospital.longitud,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              hospital.nombre,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              hospital.direccion,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '${(distancia / 1000).toStringAsFixed(2)} km',
                              style: const TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 15),

                            ElevatedButton.icon(
                              onPressed: () {
                                MapsService.abrirGoogleMaps(
                                  hospital.latitud,
                                  hospital.longitud,
                                );
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('Ir con Google Maps'),
                            ),

                            const SizedBox(height: 10),

                            ElevatedButton.icon(
                              onPressed: () {
                                MapsService.abrirWaze(
                                  hospital.latitud,
                                  hospital.longitud,
                                );
                              },
                              icon: const Icon(Icons.navigation),
                              label: const Text('Ir con Waze'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}