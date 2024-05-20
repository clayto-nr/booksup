import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
        MaterialPageRoute(
          builder: (context) => BookDetailsPage(bookDetails: bookDetails),
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

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bookDetails;

  const BookDetailsPage({Key? key, required this.bookDetails}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<dynamic> comments = [];
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    fetchBookComments();
    commentController = TextEditingController();
  }

  Future<void> fetchBookComments() async {
    final response = await http.get(Uri.parse('https://reabix-api.com/books/${widget.bookDetails['id']}/comments'));

    if (response.statusCode == 200) {
      setState(() {
        comments = jsonDecode(response.body);
      });
    } else {
      print('Erro ao buscar comentários: ${response.statusCode}');
    }
  }

  Future<void> postComment(String comment) async {
    final response = await http.post(
      Uri.parse('https://reabix-api.com/books/${widget.bookDetails['id']}/comments'),
      body: {'comment': comment},
    );

    if (response.statusCode == 200) {
      // Atualiza a lista de comentários
      fetchBookComments();
    } else {
      print('Erro ao adicionar comentário: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookDetails['name']),
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
            Text(widget.bookDetails['description']),
            SizedBox(height: 16),
            Text(
              'Visualizações: ${widget.bookDetails['views']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Comentários:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    title: Text(comment['comment']),
                    subtitle: Text('Usuário: ${comment['username']}'),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Digite seu comentário...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                postComment(commentController.text);
              },
              child: Text('Comentar'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
