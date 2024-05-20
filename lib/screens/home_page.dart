import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_details_page.dart'; // Importando o arquivo das detalhes do livro

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = [];
  List<dynamic> top3Books = [];
  late int userId;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchBooks();
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('https://reabix-api.com/books'));

    if (response.statusCode == 200) {
      setState(() {
        books = jsonDecode(response.body);
        books.sort((a, b) => b['views'].compareTo(a['views']));
        top3Books = books.take(3).toList();
      });
    } else {
      print('Erro ao buscar livros: ${response.statusCode}');
    }
  }

  Future<void> fetchBookDetails(int bookId) async {
    final response = await http.get(Uri.parse('https://reabix-api.com/books/$bookId'));

    if (response.statusCode == 200) {
      final bookDetails = jsonDecode(response.body);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BookDetailsPage(bookDetails: bookDetails),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      print('Erro ao buscar detalhes do livro: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Livros'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Top 3 Livros Mais Vistos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: top3Books.length,
              itemBuilder: (context, index) {
                final book = top3Books[index];
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Todos os Livros:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
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
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}