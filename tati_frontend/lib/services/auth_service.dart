import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tati_frontend/utils/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<void> createUser({
    required String email,
    required String password,
    required int roleId,
    required String nama,
    required String jabatan,
    int? atasanId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.register);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'role_id': roleId,
        'nama': nama,
        'jabatan': jabatan,
        'atasan_id': atasanId,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat user');
    }
  }

  // 2. UPDATE USER (Edit)
  Future<void> updateUser({
    required int id,
    String? email,
    String? password,
    int? roleId,
    String? nama,
    String? jabatan,
    int? atasanId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.baseUrl}/users/$id");

    // Buat body dinamis (hanya kirim yang tidak null)
    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (roleId != null) body['role_id'] = roleId;
    if (nama != null) body['nama'] = nama;
    if (jabatan != null) body['jabatan'] = jabatan;
    if (atasanId != null) body['atasan_id'] = atasanId;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal update user');
    }
  }

  // 3. GET LIST USER (Untuk Admin melihat daftar pegawai)
  Future<List<dynamic>> getAllUsers() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.register);

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  // Return tipe User jika sukses, throw Exception jika gagal
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.login);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _saveToken(data['access_token']);
      return data; // Kembalikan mentahan JSON response
    } else {
      throw Exception(data['message'] ?? 'Login Gagal');
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/logout");
    try {
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      await _removeToken();
    } catch (e) {
      rethrow;
    }
  }
}
