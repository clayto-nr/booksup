import 'package:flutter/material.dart';

class ContaPage extends StatelessWidget {
  const ContaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conta'),
      ),
      body: const Center(
        child: Text('Página de Conta'),
      ),
    );
  }
}
