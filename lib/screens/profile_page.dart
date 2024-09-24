import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.name}'),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
            const SizedBox(height: 16),
            ElevatedButton(
              child: Text(user.isLoggedIn ? 'Logout' : 'Login'),
              onPressed: () {
                if (user.isLoggedIn) {
                  user.logout();
                } else {
                  user.login('John Doe', 'john@example.com');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
