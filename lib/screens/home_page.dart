import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = [];
  List<dynamic> top3Books = [];

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
        // Ordenar os livros por visualizações em ordem decrescente
        books.sort((a, b) => b['views'].compareTo(a['views']));
        // Obter os 3 primeiros livros da lista ordenada (os mais vistos)
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
      // Incrementando as visualizações localmente
      bookDetails['views']++;
      // Atualizando a lista de livros com as visualizações atualizadas
      updateBookInList(bookDetails);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsPage(bookDetails: bookDetails),
        ),
      );
    } else {
      print('Erro ao buscar detalhes do livro: ${response.statusCode}');
    }
  }

  void updateBookInList(Map<String, dynamic> updatedBook) {
    final int index = books.indexWhere((book) => book['id'] == updatedBook['id']);
    if (index != -1) {
      setState(() {
        books[index] = updatedBook;
        // Atualizar a lista top 3 também
        top3Books = books.take(3).toList();
      });
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

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookDetails;

  const BookDetailsPage({Key? key, required this.bookDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookDetails['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descrição:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(bookDetails['description']),
            SizedBox(height: 16),
            Text(
              'Visualizações: ${bookDetails['views']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
