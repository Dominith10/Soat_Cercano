import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import '../data/clinicas.dart'; 
import '../models/clinica.dart';

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

  double? latitudClinica;
  double? longitudClinica;

  List<Clinica> clinicasOrdenadas = [];

  Future<void> buscarClinicas() async {

  await obtenerUbicacion();

  if (latitudUsuario == null || longitudUsuario == null) return;

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

  clinicasFiltradas.removeWhere((clinica) {

  double distancia = Geolocator.distanceBetween(
    latitudUsuario!,
    longitudUsuario!,
    clinica.latitud,
    clinica.longitud,
  );

  return distancia > 10000; // más de 10 km
});

if (clinicasFiltradas.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'No se encontraron clínicas a menos de 10 km',
      ),
    ),
  );
  return;
}

  setState(() {
    clinicasOrdenadas = clinicasFiltradas;
  });
}

Future<void> abrirGoogleMaps(
  double latitud,
  double longitud,
) async {

  final Uri url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
  );

  await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  );
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
  actions: [
    PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'comentarios') {
          final Uri email = Uri(
            scheme: 'mailto',
            path: 'antonbejarano.richard.b36.ivcd@gmail.com',
            query:
                'subject=Comentarios sobre SOAT Cercano',
          );

          await launchUrl(email);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'comentarios',
          child: Text('Enviar comentarios'),
        ),
      ],
    ),
  ],
),
      
      body: Stack(
  children: [
    SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
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

if (clinicasOrdenadas.isNotEmpty)
SizedBox(
  height: 310,
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
        width: 350,
        child: Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                Text(
                  clinica.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(clinica.direccion),

                const SizedBox(height: 10),

                Text(
                  "${(distancia / 1000).toStringAsFixed(2)} km",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    abrirGoogleMaps(
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
    ),

    const Positioned(
      bottom: 10,
      right: 10,
      child: Text(
        'Hecho por Secc. CBP Dominith Anton B36',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    ),


  ],
),
    );
  }
}