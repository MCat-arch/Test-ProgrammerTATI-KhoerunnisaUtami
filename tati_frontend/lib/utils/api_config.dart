class ApiConfig {
  // Ganti 10.0.2.2 jika pakai Android Emulator
  // Ganti IP LAN (192.168.x.x) jika debug pakai HP asli
  static const String baseUrl = "http://127.0.0.1:8080/api";

  static const String login = "$baseUrl/login";
  static const String logs = "$baseUrl/logs";
  static const String logsBawahan = "$baseUrl/logs-bawahan";
  static const String register = "$baseUrl/users";
  static const String pegawai = "$baseUrl/pegawais";
  static const String roles = "$baseUrl/roles";
}
