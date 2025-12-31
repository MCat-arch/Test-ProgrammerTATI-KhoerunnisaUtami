import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/logs_model.dart';
import '../utils/app_theme.dart';

class VerificationCard extends StatelessWidget {
  final LogsModel log;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const VerificationCard({
    super.key,
    required this.log,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: PROFIL PEGAWAI ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Avatar Inisial
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    log.pegawai?.nama.substring(0, 1).toUpperCase() ?? "U",
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nama & Jabatan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.pegawai?.nama ?? "Nama Tidak Diketahui",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        log.pegawai?.jabatan ?? "Jabatan -",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge Tanggal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    DateFormat('dd MMM').format(log.tanggal),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 24),
          ),

          // --- BODY: AKTIVITAS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Aktivitas:",
                  style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  log.aktivitas,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),

          // --- FOOTER: ACTION BUTTONS (Full Width) ---
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 147, 166, 195),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)!)),
            ),
            child: Row(
              children: [
                // Tombol TOLAK
                Expanded(
                  child: InkWell(
                    onTap: onReject,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, size: 18, color: AppTheme.errorRed),
                          SizedBox(width: 8),
                          Text(
                            "Tolak",
                            style: TextStyle(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Garis Pemisah Vertikal
                Container(width: 1, height: 48, color: Colors.grey[300]),
                
                // Tombol SETUJUI
                Expanded(
                  child: InkWell(
                    onTap: onApprove,
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 18, color: AppTheme.successGreen),
                          SizedBox(width: 8),
                          Text(
                            "Setujui",
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}