import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LivrosPage extends StatefulWidget {
  @override
  _LivrosPageState createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Livro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            ElevatedButton(
              onPressed: () => _createBook(context),
              child: Text('Adicionar Livro'),
            ),
            SizedBox(height: 40),
            Text(
              'Meus Livros',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: LivrosList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBook(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      // Se o token não estiver disponível, redirecione para a página de login
      Navigator.pushReplacementNamed(context, '/login');
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
}

class LivrosList extends StatefulWidget {
  @override
  _LivrosListState createState() => _LivrosListState();
}

class _LivrosListState extends State<LivrosList> {
  List<dynamic> _userBooks = [];

  @override
  void initState() {
    super.initState();
    _getUserBooks();
  }

  Future<void> _getUserBooks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      // Se o token não estiver disponível, redirecione para a página de login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final String apiUrl = 'https://reabix-api.com/my-books';

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
          // Trate o erro de acordo com sua lógica de aplicativo
        }
      } catch (error) {
        print('Erro ao obter os livros do usuário: $error');
        // Trate o erro de acordo com sua lógica de aplicativo
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _userBooks.map<Widget>((book) {
          return LivroContainer(
            title: book['name'],
            views: book['views'].toString(),
          );
        }).toList(),
      ),
    );
  }
}

class LivroContainer extends StatelessWidget {
  final String title;
  final String views;

  LivroContainer({
    required this.title,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 200, // Largura do contêiner do livro
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Visualizações: $views',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
