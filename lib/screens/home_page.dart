import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('https://reabix-api.com/books'));

    if (response.statusCode == 200) {
      setState(() {
        books = jsonDecode(response.body);
      });
    } else {
      print('Erro ao buscar livros: ${response.statusCode}');
    }
  }

  Future<void> fetchBookDetails(int bookId) async {
    final response = await http.get(Uri.parse('https://reabix-api.com/books/$bookId'));

    if (response.statusCode == 200) {
      final bookDetails = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(bookDetails['name']),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Descrição: ${bookDetails['description']}'),
                Text('Visualizações: ${bookDetails['views']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await incrementViews(bookId);
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          );
        },
      );
    } else {
      print('Erro ao buscar detalhes do livro: ${response.statusCode}');
    }
  }

  Future<void> incrementViews(int bookId) async {
    final response = await http.put(Uri.parse('https://reabix-api.com/books/$bookId/views'));

    if (response.statusCode == 200) {
      print('Visualização incrementada com sucesso para o livro de ID $bookId');
      // Atualizar a lista de livros após incrementar as visualizações
      fetchBooks();
    } else {
      print('Erro ao incrementar visualizações para o livro de ID $bookId: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Bem-vindo à página inicial!'),
            SizedBox(height: 20),
            Text(
              'Lista de Livros:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => fetchBooks(),
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      title: Text(book['name']),
                      subtitle: Text('Visualizações: ${book['views']}'),
                      onTap: () {
                        fetchBookDetails(book['id']);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
