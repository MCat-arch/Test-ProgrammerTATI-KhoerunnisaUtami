import 'package:flutter/material.dart';
import '../models/pegawai_model.dart';
import '../services/pegawai_service.dart';

class PegawaiProvider with ChangeNotifier {
  final PegawaiService _service = PegawaiService();

  List<PegawaiModel> _pegawais = [];
  bool _isLoading = false;

  List<PegawaiModel> get pegawais => _pegawais;
  bool get isLoading => _isLoading;

  // FETCH DATA
  // Otomatis menyesuaikan role:
  // - Kalau Kadis login -> dapet semua data
  // - Kalau Kabid login -> dapet data bawahan + diri sendiri
  // - Kalau Staff login -> dapet data diri sendiri
  Future<void> fetchPegawais() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await _service.getPegawais();
      _pegawais = rawData.map((json) => PegawaiModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetch pegawais: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE DATA
  Future<void> editPegawai(int id, String nama, String jabatan, int? atasanId) async {
    try {
      await _service.updatePegawai(
        id: id, 
        nama: nama, 
        jabatan: jabatan, 
        atasanId: atasanId
      );
      // Refresh data setelah update sukses
      await fetchPegawais(); 
    } catch (e) {
      rethrow;
    }
  }

  // DELETE DATA
  Future<void> removePegawai(int id) async {
    try {
      await _service.deletePegawai(id);
      _pegawais.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}