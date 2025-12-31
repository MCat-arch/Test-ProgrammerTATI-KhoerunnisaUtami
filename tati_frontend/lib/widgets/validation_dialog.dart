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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Tolak Log Harian", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Masukkan alasan penolakan agar pegawai dapat memperbaikinya.",
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            onChanged: (val) => setState(() => _isTyping = val.trim().isNotEmpty),
            decoration: InputDecoration(
              hintText: "Contoh: Deskripsi kurang jelas, lampiran tidak ada...",
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.errorRed),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.all(16),
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
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Tolak Log"),
        ),
      ],
    );
  }
}