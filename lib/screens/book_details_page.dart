import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bookDetails;

  const BookDetailsPage({Key? key, required this.bookDetails}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<dynamic> comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBookComments();
  }

  Future<void> fetchBookComments() async {
    final response = await http.get(Uri.parse('https://reabix-api.com/comment/${widget.bookDetails['id']}'));

    if (response.statusCode == 200) {
      setState(() {
        comments = jsonDecode(response.body);
      });
    } else {
      print('Erro ao buscar comentários: ${response.statusCode}');
    }
  }

  Future<void> addComment() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final response = await http.post(
      Uri.parse('https://reabix-api.com/comment/${widget.bookDetails['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': _commentController.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        comments.add({'comment': _commentController.text, 'username': 'Você'});
        _commentController.clear();
      });
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
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Adicione um comentário',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: addComment,
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}