import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.page.dart';

class LivrosPage extends StatefulWidget {
  @override
  _LivrosPageState createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  Future<void> createBook(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      final String apiUrl = 'https://reabix-api.com/books';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'user_id': int.parse(_userIdController.text),
          }),
        );

        if (response.statusCode == 200) {
          print('Livro criado com sucesso');
          // Faça o que for necessário após criar o livro com sucesso
        } else {
          print('Erro ao criar o livro: ${response.statusCode}');
          // Trate o erro de acordo com sua lógica de aplicativo
        }
      } catch (error) {
        print('Erro ao criar o livro: $error');
        // Trate o erro de acordo com sua lógica de aplicativo
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Livros'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Livro',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ID do Usuário',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => createBook(context),
              child: Text('Adicionar Livro'),
            ),
          ],
        ),
      ),
    );
  }
}
