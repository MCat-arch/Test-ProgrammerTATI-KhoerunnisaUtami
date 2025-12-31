import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tati_frontend/utils/api_config.dart';

class LogService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getMyLogs() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.logs);

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat log harian');
    }
  }

  Future<void> createLog(String aktivitas, String tanggal) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.logs);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'aktivitas': aktivitas, 'tanggal': tanggal}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal menyimpan log');
    }
  }

  Future<void> updateLog(int id, String aktivitas, String tanggal) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.logs}/$id");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'aktivitas': aktivitas, 'tanggal': tanggal}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update log');
    }
  }

  Future<List<dynamic>> getTeamLogs() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.logsBawahan);

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception("gagal memuat log tim");
    }
  }

  Future<void> verifyLog(int id, String status, String? catatan) async {
    final token = await _getToken();
    final url = Uri.parse("${ApiConfig.logs}/$id/verifikasi");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status, 'catatan': catatan}),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal verifikasi');
    }
  }

  Future<void> deleteLogs(int id) async {
    final token = _getToken();
    final url = Uri.parse("${ApiConfig.logs}/$id");

    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal menghapus log');
    }
  }
}
