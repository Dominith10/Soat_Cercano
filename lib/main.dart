import 'package:flutter/material.dart';
import 'pages/inicio_page.dart';

void main() {
  runApp(const SoatApp());
}

class SoatApp extends StatelessWidget {
  const SoatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOAT Cercano',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
      ),
      home: const InicioPage(),
    );
  }
}
//hola