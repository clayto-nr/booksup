import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removendo a definição do título da barra de navegação
      appBar: AppBar(
        // Removendo o título da barra de navegação
        title: null,
      ),
      body: Center(
        child: Text('Página de HomePage'),
      ),
    );
  }
}
