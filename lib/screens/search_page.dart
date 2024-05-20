import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> users = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      searchUsers(_searchController.text);
    } else {
      setState(() {
        users.clear();
      });
    }
  }

  Future<void> searchUsers(String query) async {
    final response = await http.get(Uri.parse('https://reabix-api.com/users?username=$query'));

    if (response != null && response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
      });
    } else if (response != null && response.statusCode == 404) {
      setState(() {
        users.clear();
      });
    } else {
      print('Erro ao buscar usuários: ${response?.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: users.isEmpty
                  ? _searchController.text.isNotEmpty
                  ? Center(
                child: Text(
                  'Nenhum usuário encontrado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox()
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GestureDetector(
                    onTap: () => _navigateToUserDetails(context, user['id']),
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user['username'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUserDetails(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage(userId: userId),
      ),
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final int userId;

  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  List<dynamic> books = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
  }

  Future<void> fetchUserBooks() async {
    final response = await http.get(Uri.parse('https://reabix-api.com/user/${widget.userId}/books'));

    if (response != null && response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      if (body != null) {
        setState(() {
          books = body;
          loading = false;
        });
      }
    } else {
      print('Erro ao buscar livros do usuário: ${response?.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livros do Usuário'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : books.isEmpty
            ? Center(child: Text('Nenhum livro disponível para este usuário'))
            : ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(
                  book['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  book['description'],
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchPage(),
  ));
}
