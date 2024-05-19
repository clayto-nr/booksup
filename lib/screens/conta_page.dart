import 'package:flutter/material.dart';

class ContaPage extends StatefulWidget {
  final String token; // Adicione o token como atributo

  ContaPage({required this.token}); // Modifique o construtor para receber o token

  @override
  _ContaPageState createState() => _ContaPageState();
}

class _ContaPageState extends State<ContaPage> {
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token; // Atribua o token recebido ao atributo _token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Conta'),
      ),
      body: Center(
        child: Text('Token: $_token'),
      ),
    );
  }
}
