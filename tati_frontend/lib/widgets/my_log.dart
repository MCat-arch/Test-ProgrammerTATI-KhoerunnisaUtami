import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/logs_model.dart';
import '../utils/app_theme.dart';

class LogCardWidget extends StatelessWidget {
  final LogsModel log;
  final bool isAtasanView; 
  final bool isKadis;      
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;   // Callback baru
  final VoidCallback? onDelete; // Callback baru

  const LogCardWidget({
    super.key,
    required this.log,
    this.isAtasanView = false,
    this.isKadis = false,
    this.onApprove,
    this.onReject,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan Warna Status
    Color statusColor;
    Color bgColor;
    String statusText;

    switch (log.status) {
      case 'approved':
      case 'disetujui':
        statusColor = AppTheme.successGreen;
        bgColor = Colors.green.shade50;
        statusText = "DISETUJUI";
        break;
      case 'rejected':
      case 'ditolak':
        statusColor = AppTheme.errorRed;
        bgColor = Colors.red.shade50;
        statusText = "DITOLAK";
        break;
      default:
        statusColor = AppTheme.accentOrange;
        bgColor = Colors.orange.shade50;
        statusText = "MENUNGGU";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. STRIP WARNA KIRI (Indikator Cepat)
              Container(
                width: 6,
                color: statusColor,
              ),

              // 2. KONTEN UTAMA
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER CARD: Tanggal & Badge Status ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('dd MMM yyyy').format(log.tanggal),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          
                          // Badge Status (Hanya tampil jika bukan Kadis/Atasan View)
                          if (!isKadis || isAtasanView)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 12),

                      // --- BODY: Nama & Aktivitas ---
                      if (isAtasanView && log.pegawai != null) ...[
                        Text(
                          log.pegawai!.nama,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      Text(
                        log.aktivitas,
                        style: const TextStyle(
                          fontSize: 15, 
                          color: AppTheme.textDark, 
                          height: 1.5 // Jarak antar baris text agar nyaman dibaca
                        ),
                      ),

                      // Jika Ditolak, Tampilkan Alasan
                      if (log.status == 'rejected' || log.status == 'ditolak') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppTheme.errorRed),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Catatan: ${log.catatan ?? '-'}",
                                  style: const TextStyle(fontSize: 12, color: AppTheme.errorRed),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // --- FOOTER: ACTION BUTTONS ---
                      // Area ini muncul jika ada tombol Edit/Delete (Log Saya) atau Approve/Reject (Atasan)
                      if (onEdit != null || onDelete != null || onApprove != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Tombol Edit & Delete (Untuk Staff)
                            if (onEdit != null && (log.status == 'pending')) 
                              _buildActionButton(
                                icon: Icons.edit_outlined, 
                                color: AppTheme.secondaryBlue, 
                                label: "Edit",
                                onTap: onEdit!
                              ),
                            
                            if (onDelete != null && (log.status == 'pending')) ...[
                              const SizedBox(width: 12),
                              _buildActionButton(
                                icon: Icons.delete_outline, 
                                color: AppTheme.errorRed, 
                                label: "Hapus",
                                onTap: onDelete!
                              ),
                            ],

                            // Tombol Approve & Reject (Untuk Atasan)
                            if (isAtasanView && (log.status == 'pending')) ...[
                              _buildActionButton(
                                icon: Icons.close, 
                                color: AppTheme.errorRed, 
                                label: "Tolak",
                                onTap: onReject!
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: onApprove,
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text("Setujui"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk Tombol Kecil (Edit/Hapus/Tolak)
  Widget _buildActionButton({
    required IconData icon, 
    required Color color, 
    required String label, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label, 
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}