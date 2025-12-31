import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ValidationDialog extends StatefulWidget {
  final Function(String alasan) onSubmit;

  const ValidationDialog({super.key, required this.onSubmit});

  @override
  State<ValidationDialog> createState() => _ValidationDialogState();
}

class _ValidationDialogState extends State<ValidationDialog> {
  final _reasonController = TextEditingController();
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed),
          SizedBox(width: 10),
          Text("Tolak Log Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Apakah Anda yakin ingin menolak log ini? Silakan masukkan alasannya.",
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            onChanged: (val) => setState(() => _isTyping = val.isNotEmpty),
            decoration: const InputDecoration(
              hintText: "Contoh: Laporan kurang detail...",
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal", style: TextStyle(color: AppTheme.textGrey)),
        ),
        ElevatedButton(
          onPressed: _isTyping 
              ? () {
                  widget.onSubmit(_reasonController.text);
                  Navigator.pop(context);
                }
              : null, // Disable jika alasan kosong
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text("Tolak Log"),
        ),
      ],
    );
  }
}