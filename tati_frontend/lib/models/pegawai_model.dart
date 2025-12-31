class PegawaiModel {
  final int id;
  final String nama;
  final String jabatan;
  final int? atasanId;

  PegawaiModel({
    required this.id,
    required this.nama,
    required this.jabatan,
    this.atasanId,
  });

  factory PegawaiModel.fromJson(Map<String, dynamic> json) {
    return PegawaiModel(
      id: json['id'],
      nama: json['nama'],
      jabatan: json['jabatan'],
      atasanId: json['atasan_id'], // Bisa null untuk Kadis
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'jabatan': jabatan, 'atasan_id': atasanId};
  }
}
