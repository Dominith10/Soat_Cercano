import 'package:geolocator/geolocator.dart';

class UbicacionService {
  static Future<Position?> obtenerUbicacion() async {

    bool servicio =
        await Geolocator.isLocationServiceEnabled();

    if (!servicio) return null;

    LocationPermission permiso =
        await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}