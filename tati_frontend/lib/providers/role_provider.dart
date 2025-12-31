import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleService _service = RoleService();

  List<Role> _roles = [];
  bool _isLoading = false;

  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;

  // Fetch Data (Biasanya dipanggil saat buka menu 'Kelola User' atau 'Kelola Role')
  Future<void> fetchRoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await _service.getRoles();
      _roles = rawData.map((json) => Role.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching roles: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah Role
  Future<void> addRole(String namaRole) async {
    try {
      await _service.createRole(namaRole);
      await fetchRoles(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  // Edit Role
  Future<void> editRole(int id, String namaRole) async {
    try {
      await _service.updateRole(id, namaRole);
      await fetchRoles();
    } catch (e) {
      rethrow;
    }
  }

  // Hapus Role
  Future<void> deleteRole(int id) async {
    try {
      await _service.deleteRole(id);
      _roles.removeWhere((role) => role.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}