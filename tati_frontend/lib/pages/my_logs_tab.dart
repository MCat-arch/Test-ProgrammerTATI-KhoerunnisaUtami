import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/widgets/my_log.dart';
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/form_log.dart'; // Ganti nama file sesuai project Anda
import '../utils/app_theme.dart';

class MyLogTab extends StatelessWidget {
  const MyLogTab({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<LogProvider>(context, listen: false).fetchMyLogs();
  }

  void _confirmDelete(BuildContext context, int logId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Log?"),
        content: const Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              await Provider.of<LogProvider>(context, listen: false).deleteLog(logId);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isKadis = auth.user?.role == 'Kepala Dinas';

    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        if (provider.myLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("Belum ada log aktivitas.", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView.builder( // Gunakan builder biasa, margin sudah dihandle card
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: provider.myLogs.length,
            itemBuilder: (ctx, i) {
              final log = provider.myLogs[i];

              // Panggil LogCardWidget TANPA Stack
              return LogCardWidget(
                log: log,
                isKadis: isKadis,
                
                // Pass fungsi Edit & Delete kesini agar muncul di Footer Card
                onEdit: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormLogWidget(logToEdit: log),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, log.id),
              );
            },
          ),
        );
      },
    );
  }
}