import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/widgets/my_log.dart';
import 'package:tati_frontend/widgets/validation_dialog.dart';
import '../providers/log_provider.dart';

class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<LogProvider>(context, listen: false).fetchTeamLogs();
  }

  // Fungsi memanggil Pop Up Validasi
  void _showRejectDialog(BuildContext context, int logId) {
    showDialog(
      context: context,
      builder: (ctx) => ValidationDialog(
        onSubmit: (alasan) async {
          await Provider.of<LogProvider>(context, listen: false).rejectLog(logId, alasan);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());

        final logs = provider.teamLogs;

        if (logs.isEmpty) {
          return const Center(
            child: Text("Tidak ada log bawahan yang perlu diverifikasi.", 
              style: TextStyle(color: Colors.grey)
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final log = logs[i];
              
              return LogCardWidget(
                log: log,
                isAtasanView: true, // Mode Atasan: Munculkan nama bawahan & Tombol Aksi
                
                // Hubungkan tombol aksi dari Card ke Provider
                onApprove: () async {
                   await provider.approveLog(log.id);
                   // Opsi: Tampilkan snackbar sukses
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