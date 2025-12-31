import 'package:flutter/material.dart';
import 'package:tati_frontend/models/pegawai_model.dart';

class LogsModel {
  final int id;
  final int pegawaiId;
  final String aktivitas;
  final DateTime tanggal;
  final String status;
  final String? catatan;
  final PegawaiModel? pegawai;

  LogsModel({
    required this.id,
    required this.pegawaiId,
    required this.aktivitas,
    required this.tanggal,
    required this.status,
    this.catatan,
    this.pegawai,
  });

  factory LogsModel.fromJson(Map<String, dynamic> json) {
    return LogsModel(
      id: json['id'],
      pegawaiId: json['pegawai_id'],
      aktivitas: json['aktivitas'],
      tanggal: DateTime.parse(json['tanggal']), 
      status: json['status'],
      catatan: json['catatan'],
      pegawai: json['pegawai'] != null ? PegawaiModel.fromJson(json['pegawai']) : null,
    );
  }

  // 1. Ambil Warna Status
  Color get statusColor {
    switch (status) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  // 2. Ambil Text Status yang rapi
  String get statusText {
    switch (status) {
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      case 'pending': return 'Menunggu';
      default: return status;
    }
  }

}
