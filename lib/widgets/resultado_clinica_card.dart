import 'package:flutter/material.dart';

class ResultadoClinicaCard extends StatelessWidget {
  final String nombre;
  final String direccion;
  final String distancia;
  final VoidCallback onMaps;
  final VoidCallback onProbar;

  const ResultadoClinicaCard({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.distancia,
    required this.onMaps,
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