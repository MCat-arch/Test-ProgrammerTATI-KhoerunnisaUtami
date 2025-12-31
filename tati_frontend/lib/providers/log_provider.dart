import 'package:flutter/material.dart';
import 'package:tati_frontend/models/logs_model.dart';
import 'package:tati_frontend/services/log_service.dart';

class LogProvider with ChangeNotifier {
  final LogService service = LogService();

  List<LogsModel> _myLogs = [];
  List<LogsModel> _teamLogs = []; //for team verif
  bool _isLoading = false;

  List<LogsModel> get myLogs => _myLogs;
  List<LogsModel> get teamLogs => _teamLogs;
  bool get isLoading => _isLoading;

  // untuk staff

  //read
  Future<void> fetchMyLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await service.getMyLogs();
      _myLogs = rawData.map((m) => LogsModel.fromJson(m)).toList();
    } catch (e) {
      print("Error fetch logs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //create
  Future<void> addLog(String aktivitas, DateTime date) async {
    try {
      String dateString = date.toIso8601String().split('T')[0];
      await service.createLog(aktivitas, dateString);

      await fetchMyLogs();
    } catch (e) {
      rethrow;
    }
  }

  //update
  Future<void> editLog(int id, String aktivitas, DateTime date) async {
    try {
      String dateString = date.toIso8601String().split('T')[0];
      await service.updateLog(id, aktivitas, dateString);
      await fetchMyLogs();
    } catch (e) {
      rethrow;
    }
  }

  //delete
  Future<void> deleteLog(int id) async {
    try {
      await service.deleteLogs(id);
      _myLogs.removeWhere((l) => l.id == id);
      await fetchMyLogs();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch Log Bawahan
  Future<void> fetchTeamLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawData = await service.getTeamLogs();
      _teamLogs = rawData.map((json) => LogsModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetch team logs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verifikasi Log (Setuju)
  Future<void> approveLog(int id) async {
    try {
      await service.verifyLog(id, 'approved', null);

      await fetchTeamLogs();
    } catch (e) {
      rethrow;
    }
  }

  // Verifikasi Log (Tolak)
  Future<void> rejectLog(int id, String alasan) async {
    try {
      await service.verifyLog(id, 'rejected', alasan);
      await fetchTeamLogs();
    } catch (e) {
      rethrow;
    }
  }
}
