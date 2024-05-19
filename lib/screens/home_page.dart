import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final String token;

  HomePage({required this.userId, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, User ID: $userId',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement logout logic here
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
