class Role {
  final int id;
  final String namaRole;

  Role({required this.id, required this.namaRole});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], namaRole: json['nama_role']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama_role': namaRole};
  }
}
