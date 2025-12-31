import 'package:tati_frontend/models/pegawai_model.dart';
import 'package:tati_frontend/models/role_model.dart';

class User {
  final int id;
  final String email;
  final Role? role;
  final PegawaiModel? pegawai;

  User({required this.id, required this.email, this.role, this.pegawai});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      pegawai: json['pegawai'] != null
          ? PegawaiModel.fromJson(json['pegawai'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role?.toJson(),
      'pegawai': pegawai?.toJson(),
    };
  }
}
