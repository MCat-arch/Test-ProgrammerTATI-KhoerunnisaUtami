import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tati_frontend/utils/api_config.dart';

class RoleService {
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. GET ALL ROLES
  Future<List<dynamic>> getRoles() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.roles);

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; 
    } else {
      throw Exception('Gagal memuat data role');
    }
  }

  // 2. CREATE ROLE
  Future<void> createRole(String namaRole) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.roles);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_role': namaRole,
      }),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal membuat role');
    }
  }

  // 3. UPDATE ROLE
  Future<void> updateRole(int id, String namaRole) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.roles}/$id");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_role': namaRole,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal update role');
    }
  }

  // 4. DELETE ROLE
  Future<void> deleteRole(int id) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.roles}/$id");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
       throw Exception('Gagal menghapus role');
    }
  }
}