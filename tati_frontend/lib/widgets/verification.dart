import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/providers/log_provider.dart';
import 'package:intl/intl.dart';

class VerificationTab extends StatelessWidget {
  const VerificationTab({super.key});

  void _showRejectDialog(BuildContext context, int logId) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tolak Log Harian"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: "Alasan Penolakan"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (noteController.text.isEmpty) return;
              Provider.of<LogProvider>(context, listen: false)
                  .rejectLog(logId, noteController.text)
                  .then((_) => Navigator.pop(ctx));
            },
            child: const Text("Tolak"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        // Filter: Hanya tampilkan yang Pending agar list bersih
        // Atau tampilkan semua tapi urutkan pending paling atas (sudah dihandle backend)
        final logs = provider.teamLogs; 
        
        if (logs.isEmpty) return const Center(child: Text("Tidak ada log bawahan"));

        return RefreshIndicator(
          onRefresh: () => provider.fetchTeamLogs(),
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return Card(
                color: log.status == 'pending' ? Colors.yellow[50] : Colors.white, // Highlight pending
                child: ListTile(
                  title: Text(log.pegawai?.nama ?? 'Bawahan'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.aktivitas),
                      Text(DateFormat('dd MMM y').format(log.tanggal), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: log.status == 'pending' 
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => provider.approveLog(log.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _showRejectDialog(context, log.id),
                        ),
                      ],
                    )
                  : Text(
                      log.statusText, 
                      style: TextStyle(color: log.statusColor, fontWeight: FontWeight.bold),
                    ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}