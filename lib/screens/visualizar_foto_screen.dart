import 'package:flutter/material.dart';

class VisualizarFotoScreen extends StatelessWidget {
  final String fotoUrl;

  VisualizarFotoScreen({required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Foto')),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(fotoUrl),
        ),
      ),
    );
  }
}
