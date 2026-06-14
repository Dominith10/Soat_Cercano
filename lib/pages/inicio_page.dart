import '../data/clinicas.dart';
import '../models/clinica.dart';
import '../services/maps_service.dart';
import '../services/ubicacion_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultadoClinicaCard extends StatelessWidget {
  final String nombre;
  final String direccion;
  final String distancia;
  final VoidCallback onMaps;
  final VoidCallback onWaze;
  final VoidCallback onProbar;

  const ResultadoClinicaCard({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.distancia,
    required this.onMaps,
    required this.onWaze,
    required this.onProbar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(direccion),
            const SizedBox(height: 10),
            Text(distancia),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: onMaps,
              icon: const Icon(Icons.map),
              label: const Text('Ir con Google Maps'),
            ),

            ElevatedButton(
              onPressed: onProbar,
              child: const Text('Probar clínicas'),
            ),
          ],
        ),
      ),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  String? seguroSeleccionado;
  String ubicacion = "Ubicación no obtenida";

  double? latitudUsuario;
  double? longitudUsuario;

  List<Clinica> clinicasOrdenadas = [];

  String nombreClinica = "";
  String direccionClinica = "";
  String distanciaClinica = "";

  double? latitudClinica;
  double? longitudClinica;

  Future<void> buscarClinicas() async {

  Position? posicion =
      await UbicacionService.obtenerUbicacion();

  if (posicion == null) return;

  latitudUsuario = posicion.latitude;
  longitudUsuario = posicion.longitude;

  List<Clinica> clinicasFiltradas = clinicas
      .where((c) => c.seguro.contains(seguroSeleccionado!))
      .toList();

  clinicasFiltradas.sort((a, b) {

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

  setState(() {
    clinicasOrdenadas = clinicasFiltradas;
  });
}

Future<void> abrirWaze(
  double latitud,
  double longitud,
) async {

  final Uri url = Uri.parse(
    'https://waze.com/ul?ll=$latitud,$longitud&navigate=yes',
  );

  await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  );
}

  Future<void> obtenerUbicacion() async {

  bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();

  

  if (!servicioHabilitado) {
      return;
    }

  LocationPermission permiso = await Geolocator.checkPermission();


  if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

  if (permiso == LocationPermission.deniedForever) {
    setState(() {
      ubicacion = "Permiso denegado permanentemente";
    });
    return;
  }

  Position posicion =
        await Geolocator.getCurrentPosition();

  setState(() {
  latitudUsuario = posicion.latitude;
  longitudUsuario = posicion.longitude;

  ubicacion =
      "${posicion.latitude}, ${posicion.longitude}";
  });
}

  final seguros = [
    'Rímac',
    'Pacífico',
    'Mapfre',
    'La Positiva',
    'Interseguro',
    'AFOCAT'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOAT Cercano'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.local_hospital,
              size: 100,
            ),

            const SizedBox(height: 20),

            const Text(
              'Seleccione su seguro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButton<String>(
              isExpanded: true,
              value: seguroSeleccionado,
              hint: const Text("Elegir seguro"),
              items: seguros.map((seguro) {
                return DropdownMenuItem(
                  value: seguro,
                  child: Text(seguro),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  seguroSeleccionado = valor;
                });
              },
            ),

            const SizedBox(height: 30),
ElevatedButton(
  onPressed: () async {

    if (seguroSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un seguro'),
        ),
      );
      return;
    }

    await buscarClinicas();

  },
  child: const Text('Buscar clínica'),
),

const SizedBox(height: 20),

//Text(
//  ubicacion,
//  textAlign: TextAlign.center,
//),
//const SizedBox(height: 20),

if (clinicasOrdenadas.isNotEmpty)
  SizedBox(
    height: 1000,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: clinicasOrdenadas.length,
      itemBuilder: (context, index) {

        final clinica = clinicasOrdenadas[index];

        double distancia = Geolocator.distanceBetween(
          latitudUsuario!,
          longitudUsuario!,
          clinica.latitud,
          clinica.longitud,
        );

        return SizedBox(
          width: 320,
          child: Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Text(
                    clinica.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(clinica.direccion),

                  const SizedBox(height: 10),

                  Text(
                    "${(distancia / 1000).toStringAsFixed(2)} km",
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      MapsService.abrirGoogleMaps(
                        clinica.latitud,
                        clinica.longitud,
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text("Ir con Google Maps"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () {
                      abrirWaze(
                        clinica.latitud,
                        clinica.longitud,
                      );
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text("Ir con Waze"),
                  ),
                  const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        abrirWaze(
                          clinica.latitud,
                          clinica.longitud,
                        );
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text("Ir con Waze"),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  )


          ],
        ),
      ),
    );
  }
}