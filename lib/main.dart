import 'package:flutter/material.dart';
import 'package:books/screens/login.page.dart';
import 'package:books/screens/register_page.dart'; // Importe a página de registro

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Defina a rota inicial como a página de login
      routes: {
        '/': (context) => LoginPage(), // Rota para a página de login
        '/register': (context) => RegisterPage(), // Rota para a página de registro
      },
    );
  }
}
