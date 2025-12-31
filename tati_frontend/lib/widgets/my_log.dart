import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tati_frontend/models/logs_model.dart';
import '../utils/app_theme.dart';

class LogCardWidget extends StatelessWidget {
  final LogsModel log;
  final bool isAtasanView; // True jika card ini dilihat di tab "Verifikasi Tim"
  final bool isKadis;      // True jika yang login adalah Kepala Dinas
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit; // Fitur edit (opsional)

  const LogCardWidget({
    super.key,
    required this.log,
    this.isAtasanView = false,
    this.isKadis = false,
    this.onApprove,
    this.onReject,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Helper warna status
    Color statusColor;
    IconData statusIcon;
    
    switch (log.status) {
      case 'approved':
      case 'disetujui':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
      case 'ditolak':
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.accentOrange;
        statusIcon = Icons.hourglass_top;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Tanggal & Badge Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppTheme.textGrey),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMM y').format(log.tanggal),
                      style: const TextStyle(
                        color: AppTheme.textGrey, 
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
                // Hide status badge jika User adalah Kadis (karena dia tertinggi)
                if (!isKadis || isAtasanView) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          log.status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // BODY: Nama (Jika view atasan) & Aktivitas
            if (isAtasanView && log.pegawai != null) ...[
               Text(
                log.pegawai!.nama,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 4),
            ],

            Text(
              log.aktivitas,
              style: const TextStyle(fontSize: 15, height: 1.4, color: AppTheme.textDark),
            ),

            // FOOTER: Alasan Penolakan (Jika ada)
            if (log.status == 'rejected' || log.status == 'ditolak') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Catatan Penolakan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.errorRed)),
                    Text(log.catatan ?? '-', style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
                  ],
                ),
              ),
            ],

            // ACTION BUTTONS (Khusus View Atasan & Status Pending)
            if (isAtasanView && (log.status == 'pending')) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Tolak"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Setujui"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
