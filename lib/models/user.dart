import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String? _name;
  String? _email;
  bool _isLoggedIn = false;

  String get name => _name ?? 'Guest';
  String get email => _email ?? '';
  bool get isLoggedIn => _isLoggedIn;

  void login(String name, String email) {
    _name = name;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _name = null;
    _email = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}