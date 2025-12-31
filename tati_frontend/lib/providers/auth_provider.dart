import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart'; // Import Service

class AuthProvider with ChangeNotifier {
  // Dependency Injection (Bisa juga dipanggil langsung)
  final AuthService _authService = AuthService();

  String? _token;
  User? _user;
  bool _isLoading = false; // Tambahan state loading

  bool get isAuth => _token != null;
  User? get user => _user;
  bool get isLoading => _isLoading;

  bool get isAtasan {
    if (_user?.role?.namaRole == null) return false;
    return _user!.role!.namaRole != 'Staff';
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // UI berubah jadi Loading Spinner

    try {
      // Panggil Service (Tugas Berat diserahkan ke Service)
      final responseData = await _authService.login(email, password);

      // Provider hanya mengurus Logic Penyimpanan State
      _token = responseData['access_token'];
      _user = User.fromJson(responseData['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners(); // UI stop loading, pindah halaman
      return true;

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Lempar error ke UI untuk jadi Snackbar
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
    }
    
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    _token = prefs.getString('token');
    
    // Load data user lengkap dari cache
    if (prefs.containsKey('user_data')) {
      final userDataMap = jsonDecode(prefs.getString('user_data')!);
      _user = User.fromJson(userDataMap);
    }

    notifyListeners();
    return true;
  }
  
}