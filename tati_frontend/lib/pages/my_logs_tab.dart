import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/widgets/form_log.dart';
import 'package:tati_frontend/widgets/my_log.dart';
import '../providers/auth_provider.dart';
import '../providers/log_provider.dart';
import '../utils/app_theme.dart';

class MyLogTab extends StatelessWidget {
  const MyLogTab({super.key});

  // Helper untuk refresh saat ditarik ke bawah
  Future<void> _refresh(BuildContext context) async {
    await Provider.of<LogProvider>(context, listen: false).fetchMyLogs();
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, int logId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Hapus Log?"),
        content: const Text("Log aktivitas ini akan dihapus permanen."),
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
    // Cek apakah user adalah kepala dinas (logic: roleName)
    final isKadis = auth.user?.role == 'Kepala Dinas';

    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        if (provider.myLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                const Text("Belum ada log aktivitas.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          color: AppTheme.primaryBlue,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.myLogs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final log = provider.myLogs[i];

              // Stack digunakan agar tombol Edit/Delete bisa melayang di atas Card
              return Stack(
                children: [
                  LogCardWidget(
                    log: log,
                    isKadis: isKadis, // Sembunyikan status jika Kadis
                  ),
                  
                  // Tombol Aksi (Hanya muncul jika status pending, atau selalu muncul tergantung aturan)
                  // Di sini kita munculkan selalu untuk Staff
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                        ]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // EDIT
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.secondaryBlue),
                            constraints: const BoxConstraints(), // Hapus padding bawaan
                            padding: const EdgeInsets.all(6),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormLogWidget(logToEdit: log),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          // DELETE
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            onPressed: () => _confirmDelete(context, log.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}