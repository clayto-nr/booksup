import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MeusLivrosPage extends StatefulWidget {
  @override
  _MeusLivrosPageState createState() => _MeusLivrosPageState();
}

class _MeusLivrosPageState extends State<MeusLivrosPage> {
  List<dynamic> _userBooks = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserBooks();
  }

  Future<void> _getUserBooks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final String apiUrl = 'https://reabix-api.com/books/my-books';

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _userBooks = jsonDecode(response.body);
          });
        } else {
          print('Erro ao obter os livros do usuário: ${response.statusCode}');
        }
      } catch (error) {
        print('Erro ao obter os livros do usuário: $error');
        // Trate o erro de acordo com sua lógica de aplicativo
      }
    }
  }

  Future<void> _createBook() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final String apiUrl = 'https://reabix-api.com/books/create';

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
          }),
        );

        if (response.statusCode == 200) {
          // Livro criado com sucesso, você pode lidar com a resposta se necessário
          // Por exemplo, atualizar a lista de livros chamando _getUserBooks() novamente
          _getUserBooks();
          // Limpar os campos do formulário após a criação do livro
          _nameController.clear();
          _descriptionController.clear();
        } else {
          print('Erro ao criar o livro: ${response.statusCode}');
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Livro',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição do Livro',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _createBook,
            child: Text('Criar Livro'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _userBooks.length,
              itemBuilder: (context, index) {
                final book = _userBooks[index];
                return ListTile(
                  title: Text(book['name']),
                  subtitle: Text('Visualizações: ${book['views']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
