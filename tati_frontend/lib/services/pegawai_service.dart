import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tati_frontend/utils/api_config.dart';


class PegawaiService {
  
  // Helper Token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. GET ALL PEGAWAI (Filter otomatis dari Backend)
  Future<List<dynamic>> getPegawais() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.pegawai); 

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Mengembalikan List mentah
    } else {
      throw Exception('Gagal memuat data pegawai');
    }
  }

  // 2. UPDATE PROFIL PEGAWAI
  Future<void> updatePegawai({
    required int id,
    String? nama,
    String? jabatan,
    int? atasanId,
  }) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.pegawai}/$id");

    // Body dinamis (hanya kirim yang diedit)
    Map<String, dynamic> body = {};
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
      throw Exception('Gagal update pegawai');
    }
  }

  // 3. DELETE PEGAWAI
  Future<void> deletePegawai(int id) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.pegawai}/$id");

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pegawai');
    }
  }
}