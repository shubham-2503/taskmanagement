import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = value;

    // Convert DateTime to milliseconds since epoch and save as int
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    await prefs.setBool('isLoggedIn', value);
    await prefs.setInt('lastInteractionTimeMillis', currentTimeMillis);

    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove all stored data

    _isLoggedIn = false;
    notifyListeners();
  }
}
