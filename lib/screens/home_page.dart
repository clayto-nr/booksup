import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final String token;

  const HomePage({Key? key, required this.userId, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          'Welcome, User ID: $userId, Token: $token',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}