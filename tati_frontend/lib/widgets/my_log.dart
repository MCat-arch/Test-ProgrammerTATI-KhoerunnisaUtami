import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tati_frontend/providers/log_provider.dart';


class MyLogTab extends StatefulWidget {
  const MyLogTab({super.key});

  @override
  State<MyLogTab> createState() => _MyLogTabState();
}

class _MyLogTabState extends State<MyLogTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LogProvider>(
      builder: (ctx, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.myLogs.isEmpty) return const Center(child: Text("Belum ada log aktivitas"));

        return RefreshIndicator(
          onRefresh: () => provider.fetchMyLogs(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.myLogs.length,
            itemBuilder: (ctx, i) {
              final log = provider.myLogs[i];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: log.statusColor,
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                  title: Text(log.aktivitas, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(DateFormat('EEEE, d MMMM y').format(log.tanggal)),
                      if (log.status == 'rejected')
                        Text(
                          "Alasan: ${log.catatan ?? '-'}",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  trailing: Text(
                    log.statusText.toUpperCase(),
                    style: TextStyle(color: log.statusColor, fontWeight: FontWeight.bold, fontSize: 12),
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
