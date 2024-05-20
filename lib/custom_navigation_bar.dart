import 'package:flutter/material.dart';
import 'package:booksup/screens/home_page.dart';
import 'package:booksup/screens/conta_page.dart';
import 'package:booksup/screens/search_page.dart'; // Importe a tela de pesquisa
import 'package:booksup/screens/livros_page.dart';

class CustomNavigationBar extends StatefulWidget {
  final ValueChanged<int> onItemTapped;
  final int selectedIndex;

  const CustomNavigationBar({
    Key? key,
    required this.onItemTapped,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    MeusLivrosPage(), // Adicionando a tela de "Meus Livros" aqui
    ContaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[widget.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: widget.selectedIndex == 0 ? Colors.blue : Colors.grey), // ícone cinza ou azul dependendo da seleção
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: widget.selectedIndex == 1 ? Colors.blue : Colors.grey), // ícone cinza ou azul dependendo da seleção
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: widget.selectedIndex == 2 ? Colors.blue : Colors.grey), // ícone cinza ou azul dependendo da seleção
            label: 'Meus Livros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: widget.selectedIndex == 3 ? Colors.blue : Colors.grey), // ícone cinza ou azul dependendo da seleção
            label: 'Perfil',
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: Colors.blue, // cor do ícone selecionado
        onTap: widget.onItemTapped,
      ),
    );
  }
}
