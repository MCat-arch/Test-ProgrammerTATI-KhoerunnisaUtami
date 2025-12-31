import 'package:flutter/material.dart';
import 'package:tati_frontend/services/auth_service.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final AuthService _userService = AuthService();
  
  List<User> _users = []; // Menyimpan daftar semua pegawai (untuk dilihat Kadis)
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  // 1. FETCH ALL USERS (GET)
  // Dipanggil saat Kadis membuka menu "Kelola Pegawai"
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawData = await _userService.getAllUsers();
      // Convert List Mentah -> List<User> Model
      _users = rawData.map((item) => User.fromJson(item)).toList();
    } catch (e) {
      // Handle error diam-diam atau rethrow jika butuh Snackbar
      print("Error fetching users: $e"); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREATE USER BARU (POST)
  Future<void> addUser({
    required String email,
    required String password,
    required int roleId,
    required String nama,
    required String jabatan,
    int? atasanId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.createUser(
        email: email,
        password: password,
        roleId: roleId,
        nama: nama,
        jabatan: jabatan,
        atasanId: atasanId,
      );
      
      // Jika sukses, refresh list user agar data baru muncul
      await fetchUsers(); 
      
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Lempar error ke UI agar muncul Alert/Snackbar
    }
  }

  // 3. UPDATE USER (PUT)
  Future<void> editUser({
    required int id,
    String? email,
    String? password,
    int? roleId,
    String? nama,
    String? jabatan,
    int? atasanId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(
        id: id,
        email: email,
        password: password,
        roleId: roleId,
        nama: nama,
        jabatan: jabatan,
        atasanId: atasanId,
      );

      // Refresh list setelah update
      await fetchUsers();

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}