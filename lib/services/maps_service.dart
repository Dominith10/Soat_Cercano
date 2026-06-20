import 'package:url_launcher/url_launcher.dart';

class MapsService {
  static Future<void> abrirGoogleMaps(
    double latitud,
    double longitud,
  ) async {

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('No se pudo abrir Google Maps');
    }
  }
  static Future<void> abrirWaze(
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
}