import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/widgets/validation_dialog.dart';
import 'package:tati_frontend/widgets/verification.dart';
import '../providers/log_provider.dart';
import '../utils/app_theme.dart';

class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<LogProvider>(context, listen: false).fetchTeamLogs();
  }

  // Fungsi memanggil Pop Up Validasi
  void _showRejectDialog(BuildContext context, int logId) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) => ValidationDialog(
        onSubmit: (alasan) async {
          // Panggil Provider untuk Reject
          await Provider.of<LogProvider>(context, listen: false).rejectLog(logId, alasan);
          
          // Tampilkan feedback sukses
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Log berhasil ditolak"),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = provider.teamLogs.where((l) => l.status == 'pending').toList();

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  "Semua log bawahan sudah diverifikasi.", 
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          color: AppTheme.primaryBlue,
          child: ListView.builder( 
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              
              // Gunakan VerificationCard yang baru
              return VerificationCard(
                log: log,
                onApprove: () async {
                   await provider.approveLog(log.id);
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text("Log disetujui"),
                         backgroundColor: AppTheme.successGreen,
                         behavior: SnackBarBehavior.floating,
                         duration: Duration(seconds: 1),
                       ),
                     );
                   }
                },
                onReject: () {
                   _showRejectDialog(context, log.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}